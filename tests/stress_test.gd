extends SceneTree
## TC-021: high-load combat (enemy cap swarm) and simulated full-length run.
var failures: int = 0

func _initialize() -> void:
	_run.call_deferred()

func _check(ok: bool, label: String) -> void:
	print("PASS: " if ok else "FAIL: ", label)
	if not ok: failures += 1

func _run() -> void:
	var store: Node = root.get_node("SaveStore")
	store.storage_directory = OS.get_user_data_dir().path_join("stress_test_%d" % Time.get_ticks_usec())
	store.load_data()
	var arena: WoodcallerArena = load("res://scenes/game/arena.tscn").instantiate()
	root.add_child(arena)
	await physics_frame
	await process_frame
	var director: Node = root.get_node("WaveDirector")
	director.set_physics_process(false)
	director.enemy_cap = 120
	director.elapsed = 600.0
	var player: Node2D = arena.get_node("Player")
	var health: CombatHealth = player.get_node("Health")
	health.max_health = 100000.0
	health.current_health = 100000.0
	while get_nodes_in_group("summon").size() < 5:
		arena._apply_upgrade(&"bond")
	for index: int in range(4):
		arena._apply_upgrade(&"power")
	_check(get_nodes_in_group("summon").size() == 5, "TC-021 five summons fielded")

	var spawned: int = 0
	while get_nodes_in_group("enemy").size() < 120 and spawned < 400:
		if director.spawn_enemy() != null:
			spawned += 1
	_check(get_nodes_in_group("enemy").size() == 120, "TC-021 swarm at population cap")

	var kills_before: int = arena.enemies_defeated
	var t0: int = Time.get_ticks_usec()
	for frame: int in range(300):
		await physics_frame
	var avg_ms: float = (Time.get_ticks_usec() - t0) / 1000.0 / 300.0
	print("INFO: average physics frame %.2f ms with %d enemies" % [avg_ms, get_nodes_in_group("enemy").size()])
	_check(arena.enemies_defeated > kills_before, "TC-021 summons kill under load")
	_check(get_nodes_in_group("experience_orb").size() > 0, "TC-021 orbs drop under load")
	_check(get_nodes_in_group("enemy").size() <= 120, "TC-021 population stays within cap")
	_check(avg_ms < 33.0, "TC-021 frame budget holds under load")
	_check(not arena.run_ended, "TC-021 run survives swarm")

	# Fast-forward the director through a full 30-minute run to the boss.
	director.elapsed = 1799.0
	director._physics_process(1.0)
	director._physics_process(1.0)
	_check(director.elapsed == 1800.0 and not director.active, "TC-021 full duration elapses")
	_check(arena.boss_spawned and get_nodes_in_group("boss").size() == 1, "TC-021 boss arrives after long run")
	await physics_frame
	await process_frame
	var boss: Node = get_nodes_in_group("boss")[0]
	boss.take_damage(100000.0)
	await process_frame
	_check(arena.run_ended and paused and arena.run_ui.result_panel.visible, "TC-021 long run ends in victory")
	_check(store.data.get("wins", 0) >= 1, "TC-021 victory recorded")

	arena.queue_free()
	await process_frame
	var path: String = store.get_save_path()
	for suffix: String in ["", ".bak", ".tmp"]:
		if FileAccess.file_exists(path + suffix): DirAccess.remove_absolute(path + suffix)
	DirAccess.remove_absolute(path.get_base_dir())
	print("RESULT: ", failures, " failure(s)")
	quit(1 if failures else 0)
