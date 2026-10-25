extends SceneTree
## Run: Godot --headless --path . --script tests/player_movement_test.gd

var failures: int = 0
var movement_events: Array[bool] = []
var facing_events: Array[Vector2] = []

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

func _key(code: Key, pressed: bool) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.physical_keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)

func _release() -> void:
	for code: Key in [KEY_A, KEY_D, KEY_W, KEY_S]:
		_key(code, false)

func _run() -> void:
	var scene: Node2D = load("res://scenes/test/player_movement_test.tscn").instantiate()
	root.add_child(scene)
	var player: CharacterBody2D = scene.get_node("Player")
	player.movement_changed.connect(func(value: bool) -> void: movement_events.append(value))
	player.facing_changed.connect(func(value: Vector2) -> void: facing_events.append(value))
	await _tick()
	_check(player.position.is_equal_approx(Vector2(240, 180)), "TC-004 scene loads and idle stays still")
	for code: Key in [KEY_A, KEY_D, KEY_W, KEY_S]:
		var directions: Dictionary = {KEY_A: Vector2.LEFT, KEY_D: Vector2.RIGHT, KEY_W: Vector2.UP, KEY_S: Vector2.DOWN}
		_key(code, true)
		await _tick()
		_check(player.velocity.is_equal_approx(directions[code] * 120.0), "TC-001 physical key %s direction and speed" % code)
		_release()
		await _tick()
		_check(player.velocity.is_zero_approx(), "TC-001 key release stops")
	_key(KEY_W, true)
	_key(KEY_D, true)
	await _tick()
	_check(is_equal_approx(player.velocity.length(), 120.0), "TC-001 diagonal normalized speed")
	var event_count: int = movement_events.size()
	var facing_count: int = facing_events.size()
	await _tick()
	_check(movement_events.size() == event_count and facing_events.size() == facing_count, "TC-003 unchanged state does not repeat signals")
	_release()
	_key(KEY_A, true)
	_key(KEY_D, true)
	await _tick()
	_check(player.velocity.is_zero_approx(), "TC-001 opposing keys cancel")
	_release()
	player.position = Vector2(400, 180)
	_key(KEY_D, true)
	await _tick(20)
	_check(player.position.x <= 408.1 and player.position.x >= 407.0, "TC-002 obstacle stops player")
	_key(KEY_W, true)
	var start_y: float = player.position.y
	await _tick(5)
	_check(player.position.y < start_y and player.position.x <= 408.1, "TC-002 slide along obstacle")
	_release()
	for entry: Array in [[Vector2(30, 100), KEY_A, 0, 24.0], [Vector2(610, 100), KEY_D, 0, 616.0], [Vector2(100, 24), KEY_W, 1, 18.0], [Vector2(100, 324), KEY_S, 1, 330.0]]:
		player.position = entry[0]
		_key(entry[1], true)
		await _tick(15)
		_check(absf(player.position[entry[2]] - entry[3]) < 0.2, "TC-002 boundary %s" % entry[1])
		_release()
		await _tick()
	player.position = Vector2(240, 180)
	_key(KEY_D, true)
	await _tick()
	player.movement_enabled = false
	var stopped_at: Vector2 = player.position
	await _tick()
	_check(player.position.is_equal_approx(stopped_at) and player.velocity.is_zero_approx(), "TC-003 disable movement")
	player.movement_enabled = true
	await _tick()
	_check(player.position.x > stopped_at.x, "TC-003 enable movement")
	player.notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT)
	stopped_at = player.position
	await _tick()
	_check(player.position.is_equal_approx(stopped_at) and player.velocity.is_zero_approx(), "TC-003 simulated focus loss stops")
	_release()
	player.notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN)
	await _tick()
	_check(player.position.is_equal_approx(stopped_at), "TC-003 simulated focus regain stays idle")
	var sprite: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
	var texture: GradientTexture2D = GradientTexture2D.new()
	for animation: StringName in [&"idle", &"walk"]:
		sprite.sprite_frames.add_frame(animation, texture)
	_key(KEY_A, true)
	await _tick()
	_check(sprite.animation == &"walk" and sprite.is_playing() and sprite.flip_h, "TC-004 walk and left flip")
	_release()
	await _tick()
	_check(sprite.animation == &"idle" and sprite.is_playing(), "TC-004 idle animation")
	_key(KEY_D, true)
	await _tick()
	_check(not sprite.flip_h, "TC-004 right flip")
	_release()
	await _tick()
	print("RESULT: ", failures, " failure(s)")
	scene.queue_free()
	await process_frame
	quit(1 if failures > 0 else 0)
