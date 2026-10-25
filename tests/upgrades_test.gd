extends SceneTree
## TC-020: expanded upgrade pool, random distinct choices, availability caps.
var failures: int = 0

func _initialize() -> void:
	_run.call_deferred()

func _check(ok: bool, label: String) -> void:
	print("PASS: " if ok else "FAIL: ", label)
	if not ok: failures += 1

func _tick(count: int = 3) -> void:
	for index: int in range(count):
		await physics_frame
		await process_frame

func _pool_ids(arena: WoodcallerArena) -> Array:
	var ids: Array = []
	for entry: Dictionary in arena._upgrade_pool():
		if entry["open"]:
			ids.append(entry["id"])
	return ids

func _run() -> void:
	var store: Node = root.get_node("SaveStore")
	store.storage_directory = OS.get_user_data_dir().path_join("upg_test_%d" % Time.get_ticks_usec())
	store.load_data()
	var arena: WoodcallerArena = load("res://scenes/game/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	await _tick()
	var player: CharacterBody2D = arena.get_node("Player")

	# Level-up offers three distinct choices with numbered labels.
	arena.progression.add_experience(10)
	_check(paused and arena.run_ui.panel.visible, "TC-020 upgrade pauses and shows panel")
	_check(arena.current_choices.size() == 3, "TC-020 three choices offered")
	var unique: Dictionary = {}
	for id: StringName in arena.current_choices:
		unique[id] = true
	_check(unique.size() == 3, "TC-020 choices are distinct")
	_check(arena.run_ui.buttons[0].text.begins_with("1  "), "TC-020 numbered label")

	# Apply through the UI: the pick is random, so later checks stay relative.
	arena.run_ui.buttons[0].pressed.emit()
	_check(not paused and arena.pending_levels.is_empty(), "TC-020 selection resumes world")
	var summon: WoodcallerSummon = get_nodes_in_group("summon")[0]

	# Direct application of every upgrade id (relative to whatever the UI pick did).
	var before: float = summon.damage
	arena._apply_upgrade(&"power")
	_check(is_equal_approx(summon.damage, before + 5.0), "TC-020 power boosts summon damage")

	var pack_before: Array[Node] = get_nodes_in_group("summon")
	var expected_damage: float = 10.0 + arena.summon_damage_bonus
	arena._apply_upgrade(&"bond")
	var pack_after: Array[Node] = get_nodes_in_group("summon")
	_check(pack_after.size() == pack_before.size() + 1, "TC-020 bond adds summon")
	var newcomer: WoodcallerSummon = null
	for member: Node in pack_after:
		if not pack_before.has(member):
			newcomer = member
	_check(newcomer != null and is_equal_approx(newcomer.damage, expected_damage), "TC-020 new summon inherits power")

	before = player.move_speed
	arena._apply_upgrade(&"swift")
	_check(is_equal_approx(player.move_speed, minf(before * 1.1, 300.0)), "TC-020 swift scales speed")

	before = arena.summon_interval_scale
	arena._apply_upgrade(&"haste")
	_check(is_equal_approx(arena.summon_interval_scale, before * 0.9), "TC-020 haste scales interval")
	_check(is_equal_approx(summon.attack_interval, 0.7 * arena.summon_interval_scale), "TC-020 haste applies to summons")

	var health: CombatHealth = player.get_node("Health")
	health.take_damage(30.0)
	var hp_before: float = health.current_health
	var max_before: float = health.max_health
	arena._apply_upgrade(&"vitality")
	_check(is_equal_approx(health.max_health, max_before + 20.0)
			and is_equal_approx(health.current_health, hp_before + 20.0), "TC-020 vitality raises max and heals")

	before = arena.summon_reach_scale
	arena._apply_upgrade(&"reach")
	_check(is_equal_approx(arena.summon_reach_scale, before * 1.2), "TC-020 reach scales up")
	_check(is_equal_approx(summon.attack_range, 120.0 * arena.summon_reach_scale), "TC-020 reach applies to summons")

	var orb: ExperienceOrb = load("res://scenes/pickups/experience_orb.tscn").instantiate()
	arena.add_child(orb)
	before = arena.magnet_scale
	arena._apply_upgrade(&"magnet")
	_check(is_equal_approx(arena.magnet_scale, before * 1.4), "TC-020 magnet scales up")
	var circle: CircleShape2D = orb.get_node("CollisionShape2D").shape as CircleShape2D
	_check(is_equal_approx(circle.radius, 10.0 * arena.magnet_scale), "TC-020 magnet widens existing orb")
	arena._on_enemy_defeated(Vector2(40, 40), 5)
	await _tick()
	var fresh_circle: CircleShape2D = null
	for node: Node in get_nodes_in_group("experience_orb"):
		if node != orb:
			fresh_circle = node.get_node("CollisionShape2D").shape as CircleShape2D
	_check(fresh_circle != null and is_equal_approx(fresh_circle.radius, 10.0 * arena.magnet_scale),
			"TC-020 magnet applies to new orbs")

	# Availability caps remove entries from the pool.
	player.move_speed = 300.0
	arena.summon_interval_scale = 0.1
	arena.summon_reach_scale = 3.0
	arena.magnet_scale = 5.0
	while get_nodes_in_group("summon").size() < 5:
		arena._apply_upgrade(&"bond")
	_check(get_nodes_in_group("summon").size() == 5, "TC-020 summon cap reached")
	var open_ids: Array = _pool_ids(arena)
	_check(not open_ids.has(&"swift") and not open_ids.has(&"bond") and not open_ids.has(&"haste")
			and not open_ids.has(&"reach") and not open_ids.has(&"magnet"), "TC-020 capped upgrades leave pool")
	_check(open_ids.has(&"power") and open_ids.has(&"vitality"), "TC-020 power and vitality always open")

	# With only two entries open, two choices are shown and button 3 is hidden/rejected.
	arena.progression.add_experience(15)
	_check(arena.current_choices.size() == 2, "TC-020 pool smaller than three")
	_check(not arena.run_ui.buttons[2].visible, "TC-020 third button hidden")
	var levels_before: int = arena.pending_levels.size()
	arena._on_upgrade_selected(2)
	_check(arena.pending_levels.size() == levels_before, "TC-020 out-of-range choice rejected")
	arena.run_ui.buttons[0].pressed.emit()
	_check(not paused, "TC-020 final choice resumes world")

	arena.queue_free()
	await process_frame
	var path: String = store.get_save_path()
	for suffix: String in ["", ".bak", ".tmp"]:
		if FileAccess.file_exists(path + suffix): DirAccess.remove_absolute(path + suffix)
	DirAccess.remove_absolute(path.get_base_dir())
	print("RESULT: ", failures, " failure(s)")
	quit(1 if failures else 0)
