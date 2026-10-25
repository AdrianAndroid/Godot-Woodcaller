extends SceneTree
var failures: int = 0
var bosses: int = 0
func _initialize() -> void:
	_run.call_deferred()
func _check(ok: bool, label: String) -> void:
	print("PASS: " if ok else "FAIL: ", label)
	if not ok: failures += 1
func _run() -> void:
	var arena: Node2D = load("res://scenes/test/player_movement_test.tscn").instantiate()
	root.add_child(arena)
	var director: Node = root.get_node("WaveDirector")
	director.set_physics_process(false)
	director.start_run(arena)
	director.boss_due.connect(func() -> void: bosses += 1)
	await physics_frame
	await process_frame
	var spawned: Node2D = director.spawn_enemy()
	_check(spawned != null, "TC-012 spawn valid enemy")
	_check(spawned.position.distance_to(arena.get_node("Player").position) >= 110, "TC-012 safe spawn distance")
	director.enemy_cap = 1
	_check(director.spawn_enemy() == null, "TC-012 population cap")
	director.enemy_cap = 60
	director.elapsed = 600.0
	var stronger: Node2D = director.spawn_enemy()
	_check(stronger.get_node("Health").max_health > spawned.get_node("Health").max_health and stronger.move_speed > spawned.move_speed, "TC-012 difficulty scales")
	director.elapsed = 1799.9
	director._physics_process(0.2)
	director._physics_process(1.0)
	_check(bosses == 1 and not director.active and director.elapsed == 1800.0, "TC-012 boss threshold once")
	director.start_run(arena)
	_check(director.elapsed == 0 and director.active, "TC-012 restart resets timer")
	var player: Node = arena.get_node("Player")
	player.take_damage(8.0)
	player.take_damage(8.0)
	_check(player.get_node("Health").current_health == 92.0, "TC-012 player hurt immunity")
	player._hurt_remaining = 0.0
	spawned.position = player.position + Vector2(20, 0)
	spawned._physics_process(0.016)
	_check(player.get_node("Health").current_health == 84.0, "TC-012 enemy contact damage")
	director.stop_run()
	arena.queue_free()
	await process_frame
	print("RESULT: ", failures, " failure(s)")
	quit(1 if failures else 0)
