extends SceneTree
var failures: int = 0
func _initialize() -> void:
	_run.call_deferred()
func _check(ok: bool, label: String) -> void:
	print("PASS: " if ok else "FAIL: ", label)
	if not ok: failures += 1
func _run() -> void:
	var arena: WoodcallerArena = load("res://scenes/game/arena.tscn").instantiate()
	root.add_child(arena)
	for enemy: Node in get_nodes_in_group("enemy"):
		enemy.movement_enabled = false
	for summon: Node in get_nodes_in_group("summon"):
		summon.attacks_enabled = false
	arena.forced_choices = [&"power", &"swift", &"bond"]
	arena.progression.add_experience(-1)
	_check(arena.progression.experience == 0, "TC-011 negative XP ignored")
	arena.progression.add_experience(25)
	_check(arena.progression.level == 3 and arena.progression.experience == 0, "TC-011 multi-level XP accounting")
	_check(paused and arena.pending_levels.size() == 2 and arena.run_ui.panel.visible, "TC-011 queued choices pause world")
	var original: float = arena.get_node("Summon").damage
	arena.run_ui.buttons[0].pressed.emit()
	_check(arena.get_node("Summon").damage == original + 5.0, "TC-011 power applies once")
	_check(paused and arena.pending_levels.size() == 1, "TC-011 pending level stays paused")
	arena.run_ui.buttons[2].pressed.emit()
	_check(not paused and get_nodes_in_group("summon").size() == 2, "TC-011 summon choice completes queue")
	_check(get_nodes_in_group("summon")[1].damage == original + 5.0, "TC-011 new summon inherits power")
	arena.run_ui.buttons[2].pressed.emit()
	_check(get_nodes_in_group("summon").size() == 2, "TC-011 duplicate selection ignored")
	var enemy: Node2D = get_nodes_in_group("enemy")[0]
	enemy.position = Vector2(100, 100)
	enemy.take_damage(1000)
	await process_frame
	await process_frame
	_check(get_nodes_in_group("experience_orb").size() == 1, "TC-011 enemy death creates XP orb")
	var orb: ExperienceOrb = get_nodes_in_group("experience_orb")[0]
	orb._on_body_entered(arena.get_node("World"))
	_check(arena.progression.experience == 0, "TC-011 non-player cannot collect")
	orb._on_body_entered(arena.get_node("Player"))
	orb._on_body_entered(arena.get_node("Player"))
	_check(arena.progression.experience == 5, "TC-011 one-time collection")
	arena.progression.add_experience(15)
	arena.run_ui.buttons[1].pressed.emit()
	_check(is_equal_approx(arena.get_node("Player").move_speed, 132.0), "TC-011 movement upgrade")
	arena.queue_free()
	await process_frame
	print("RESULT: ", failures, " failure(s)")
	quit(1 if failures else 0)
