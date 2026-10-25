extends SceneTree
## TC-019: audio autoloads, pooled sfx playback and gameplay wiring.
var failures: int = 0
var heard: Array[StringName] = []

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
	var sfx: Node = root.get_node_or_null("Sfx")
	_check(sfx != null, "TC-019 Sfx autoload exists")
	var music: Node = root.get_node_or_null("Music")
	_check(music != null, "TC-019 Music autoload exists")
	if sfx == null or music == null:
		print("RESULT: ", failures, " failure(s)")
		quit(1)
		return

	for sound: StringName in [&"attack", &"enemy_die", &"pickup", &"levelup", &"hurt", &"win", &"lose", &"ui_click"]:
		if not sfx.has_sound(sound):
			_check(false, "TC-019 sfx registered: " + sound)
	_check(true, "TC-019 all eight sfx registered")
	sfx.played.connect(func(sound: StringName) -> void: heard.append(sound))
	sfx.play(&"ui_click")
	sfx.play(&"attack", -3.0, 0.0)
	sfx.play(&"nonexistent_sound")
	_check(heard == [&"ui_click", &"attack"], "TC-019 play emits, unknown name safe")

	_check(music.stream is AudioStreamOggVorbis, "TC-019 music stream loaded")
	if music.stream is AudioStreamOggVorbis:
		_check(music.stream.loop, "TC-019 music loops")
		_check(music.stream.get_length() > 20.0, "TC-019 music is a full track")

	# Gameplay wiring: attack, enemy death, pickup and player hurt.
	var arena: Node2D = load("res://scenes/test/player_movement_test.tscn").instantiate()
	root.add_child(arena)
	var player: Node2D = arena.get_node("Player")
	var enemy: Node2D = load("res://scenes/enemies/enemy.tscn").instantiate()
	enemy.position = Vector2(300, 180)
	enemy.movement_enabled = false
	arena.add_child(enemy)
	var summon: Node2D = load("res://scenes/summons/summon.tscn").instantiate()
	summon.orbit_speed = 0.0
	arena.add_child(summon)
	await _tick(110)
	_check(heard.count(&"attack") >= 1, "TC-019 summon attack sfx")
	_check(heard.count(&"enemy_die") == 1, "TC-019 enemy death sfx once")

	var orb: Node2D = load("res://scenes/pickups/experience_orb.tscn").instantiate()
	orb.position = player.position
	arena.add_child(orb)
	await _tick()
	_check(heard.count(&"pickup") == 1, "TC-019 pickup sfx once")

	player.take_damage(5.0)
	_check(heard.count(&"hurt") == 1, "TC-019 hurt sfx once")

	arena.queue_free()
	await process_frame
	print("RESULT: ", failures, " failure(s)")
	quit(1 if failures else 0)
