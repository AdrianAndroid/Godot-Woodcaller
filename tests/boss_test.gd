extends SceneTree
var failures: int = 0
var wins: int = 0
var rages: int = 0
func _initialize() -> void:
	_run.call_deferred()
func _check(ok: bool, label: String) -> void:
	print("PASS: " if ok else "FAIL: ", label)
	if not ok: failures += 1
func _run() -> void:
	var store: Node = root.get_node("SaveStore")
	store.storage_directory = OS.get_user_data_dir().path_join("boss_test_%d" % Time.get_ticks_usec())
	store.load_data()
	var arena: WoodcallerArena = load("res://scenes/game/arena.tscn").instantiate()
	root.add_child(arena)
	root.get_node("WaveDirector").set_physics_process(false)
	for summon: Node in get_nodes_in_group("summon"): summon.attacks_enabled = false
	for enemy: Node in get_nodes_in_group("enemy"): enemy.movement_enabled = false
	arena.run_won.connect(func() -> void: wins += 1)
	arena._spawn_boss()
	arena._spawn_boss()
	_check(get_nodes_in_group("boss").size() == 1, "TC-014 only one boss")
	var boss: ForestBoss = get_nodes_in_group("boss")[0]
	boss.set_physics_process(false)
	boss.enraged.connect(func() -> void: rages += 1)
	_check(boss.get_node("Health").current_health == 1200, "TC-014 boss health override")
	boss.take_damage(610)
	boss.take_damage(1)
	_check(boss.is_enraged and boss.move_speed == 85 and rages == 1, "TC-014 enrage once at half health")
	var player: Node2D = arena.get_node("Player")
	player.movement_enabled = false
	boss._pulse_remaining = 0.0
	boss._physics_process(0.016)
	_check(boss._warning.visible, "TC-014 visible warning before pulse")
	player.position += Vector2(100, 0)
	boss._physics_process(1.3)
	_check(player.get_node("Health").current_health == 100, "TC-014 moving out dodges pulse")
	boss._pulse_remaining = 0.0
	boss._physics_process(0.016)
	boss._physics_process(1.3)
	_check(player.get_node("Health").current_health == 80, "TC-014 standing in warning takes damage")
	boss.take_damage(10000)
	boss.take_damage(10000)
	_check(wins == 1, "TC-014 boss death emits victory once")
	arena.queue_free()
	await process_frame
	var save_path: String = store.get_save_path()
	for suffix: String in ["", ".bak", ".tmp"]:
		if FileAccess.file_exists(save_path + suffix):
			DirAccess.remove_absolute(save_path + suffix)
	DirAccess.remove_absolute(save_path.get_base_dir())
	print("RESULT: ", failures, " failure(s)")
	quit(1 if failures else 0)
