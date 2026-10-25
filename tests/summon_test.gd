extends SceneTree
var failures: int = 0
var attacks: int = 0
var deaths: int = 0
func _initialize() -> void:
	_run.call_deferred()
func _check(ok: bool, label: String) -> void:
	print("PASS: " if ok else "FAIL: ", label)
	if not ok: failures += 1
func _tick(count: int = 3) -> void:
	for index: int in range(count):
		await physics_frame
		await process_frame
func _run() -> void:
	var arena: Node2D = load("res://scenes/test/player_movement_test.tscn").instantiate()
	root.add_child(arena)
	var player: Node2D = arena.get_node("Player")
	player.movement_enabled = false
	var enemy: Node2D = load("res://scenes/enemies/enemy.tscn").instantiate()
	enemy.position = Vector2(300, 180)
	enemy.movement_enabled = false
	enemy.defeated.connect(func(_position: Vector2, _experience: int) -> void: deaths += 1)
	arena.add_child(enemy)
	var summon: Node2D = load("res://scenes/summons/summon.tscn").instantiate()
	summon.orbit_speed = 0.0
	summon.attacked.connect(func(_target: Node2D, _damage: float) -> void: attacks += 1)
	arena.add_child(summon)
	await _tick()
	_check(enemy.get_node("Health").current_health == 20.0, "TC-010 summon damages enemy")
	_check(attacks == 1, "TC-010 no per-frame attacks")
	_check(is_equal_approx(summon.global_position.distance_to(player.global_position), 30.0), "TC-010 follows owner orbit")
	await _tick(95)
	_check(deaths == 1 and not is_instance_valid(enemy), "TC-010 enemy dies exactly once")
	_check(attacks == 3, "TC-010 cooldown and three-hit kill")
	var wall_enemy: Node2D = load("res://scenes/enemies/enemy.tscn").instantiate()
	wall_enemy.position = Vector2(490, 180)
	wall_enemy.movement_enabled = false
	arena.add_child(wall_enemy)
	player.position = Vector2(370, 180)
	await _tick(50)
	_check(wall_enemy.get_node("Health").current_health == 30.0, "TC-010 wall blocks attack")
	player.position = Vector2(100, 100)
	await _tick(50)
	_check(wall_enemy.get_node("Health").current_health == 30.0, "TC-010 out of range is safe")
	player.queue_free()
	await _tick()
	_check(is_instance_valid(summon), "TC-010 missing owner is safe")
	arena.queue_free()
	await process_frame
	print("RESULT: ", failures, " failure(s)")
	quit(1 if failures else 0)
