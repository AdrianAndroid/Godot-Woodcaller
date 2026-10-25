extends SceneTree

var failures: int = 0
var targets: int = 0
var movements: int = 0

func _initialize() -> void:
	_run.call_deferred()

func _check(condition: bool, label: String) -> void:
	print("PASS: " if condition else "FAIL: ", label)
	if not condition:
		failures += 1

func _tick(count: int = 3) -> void:
	for index: int in range(count):
		await physics_frame
		await process_frame

func _run() -> void:
	var scene: Node2D = load("res://scenes/test/player_movement_test.tscn").instantiate()
	root.add_child(scene)
	var player: CharacterBody2D = scene.get_node("Player")
	player.movement_enabled = false
	player.remove_from_group("player")
	var enemy: CharacterBody2D = load("res://scenes/enemies/enemy.tscn").instantiate()
	enemy.position = Vector2(100, 180)
	enemy.target_changed.connect(func(_target: Node2D) -> void: targets += 1)
	enemy.movement_changed.connect(func(_moving: bool) -> void: movements += 1)
	scene.add_child(enemy)
	await _tick()
	_check(enemy.velocity.is_zero_approx() and targets == 0, "TC-008 no target stays idle")
	player.add_to_group("player")
	await _tick(20)
	_check(enemy.position.x > 100 and is_equal_approx(enemy.velocity.length(), 65.0), "TC-007 late player acquisition and speed")
	_check(targets == 1, "TC-008 acquisition emits once")
	var count: int = movements
	await _tick()
	_check(movements == count and targets == 1, "TC-008 stable state emits no duplicate signals")
	player.position = Vector2(240, 80)
	await _tick()
	_check(enemy.velocity.y < 0 and is_equal_approx(enemy.velocity.length(), 65.0), "TC-007 follows changed position at diagonal speed")
	enemy.move_speed = 10000.0
	await _tick(5)
	_check(absf(enemy.position.distance_to(player.position) - 20.0) < 0.05, "TC-007 high speed stops at radius without overshoot")
	_check(enemy.velocity.is_zero_approx(), "TC-007 arrival becomes idle")
	enemy.position = player.position
	await _tick()
	_check(enemy.velocity.is_zero_approx() and enemy.position.is_finite(), "TC-007 coincident target is safe")
	enemy.move_speed = 65.0
	enemy.position = Vector2(100, 100)
	enemy.movement_enabled = false
	await _tick()
	_check(enemy.position.is_equal_approx(Vector2(100, 100)), "TC-008 disable movement")
	enemy.movement_enabled = true
	await _tick()
	_check(enemy.position.x > 100, "TC-008 reenable movement")
	player.queue_free()
	await _tick()
	_check(enemy.velocity.is_zero_approx() and targets == 2, "TC-008 freed target clears safely and emits once")
	var replacement: Node2D = Node2D.new()
	replacement.position = Vector2(550, 180)
	replacement.add_to_group("player")
	scene.add_child(replacement)
	enemy.position = Vector2(400, 180)
	await _tick(30)
	_check(targets == 3 and enemy.position.x > 400, "TC-008 replacement acquired")
	await _tick(30)
	_check(enemy.position.x <= 408.1 and enemy.position.x >= 407.0, "TC-009 obstacle blocks pursuit")
	replacement.position = Vector2(550, 80)
	var wall_y: float = enemy.position.y
	await _tick(5)
	_check(enemy.position.y < wall_y, "TC-009 slides along obstacle")
	enemy.position = Vector2(610, 100)
	replacement.position = Vector2(700, 100)
	await _tick(20)
	_check(enemy.position.x <= 616.1, "TC-009 world boundary blocks pursuit")
	var sprite: AnimatedSprite2D = enemy.get_node("AnimatedSprite2D")
	for animation: StringName in [&"idle", &"walk"]:
		sprite.sprite_frames.add_frame(animation, GradientTexture2D.new())
	enemy.movement_enabled = false
	await _tick()
	enemy.position = Vector2(240, 100)
	replacement.position = Vector2(80, 100)
	enemy.movement_enabled = true
	await _tick()
	_check(sprite.animation == &"walk" and sprite.is_playing() and sprite.flip_h, "TC-009 walk animation and left facing")
	replacement.position = Vector2(320, 100)
	await _tick()
	_check(not sprite.flip_h, "TC-009 right facing")
	enemy.movement_enabled = false
	await _tick()
	_check(sprite.animation == &"idle" and sprite.is_playing(), "TC-009 idle animation")
	scene.queue_free()
	await process_frame
	var demo: Node2D = load("res://scenes/test/enemy_chase_test.tscn").instantiate()
	root.add_child(demo)
	await _tick()
	_check(get_nodes_in_group("enemy").size() == 3, "TC-009 demo contains three active enemies")
	for node: Node in get_nodes_in_group("enemy"):
		_check((node as CharacterBody2D).velocity.length() > 0, "TC-009 demo enemy pursues")
	demo.queue_free()
	await process_frame
	print("RESULT: ", failures, " failure(s)")
	quit(1 if failures > 0 else 0)
