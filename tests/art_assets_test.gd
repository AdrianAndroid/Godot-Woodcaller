extends SceneTree
## TC-018: pixel-art assets load, animations play, debug placeholders hidden.
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

func _check_frames(sprite: AnimatedSprite2D, animations: Array[StringName], label: String) -> void:
	if not _check_node(sprite, label):
		return
	_check(sprite.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, label + " nearest filter")
	var frames: SpriteFrames = sprite.sprite_frames
	_check(frames != null, label + " has SpriteFrames")
	if frames == null:
		return
	for animation_name: StringName in animations:
		var ok: bool = frames.has_animation(animation_name) and frames.get_frame_count(animation_name) > 0
		if ok:
			var texture: Texture2D = frames.get_frame_texture(animation_name, 0)
			ok = texture != null and texture.get_width() == 32 and texture.get_height() == 32
		_check(ok, label + " animation '" + animation_name + "' has 32x32 frames")

func _check_node(sprite: AnimatedSprite2D, label: String) -> bool:
	_check(sprite != null, label + " AnimatedSprite2D exists")
	return sprite != null

func _run() -> void:
	var art_dir: String = "res://assets/art"
	_check(DirAccess.dir_exists_absolute(art_dir), "TC-018 assets/art directory exists")
	_check(FileAccess.file_exists("res://assets/ART_CREDITS.md"), "TC-018 license registry exists")

	# Spread entities and disable combat so observation stays side-effect free.
	var player: Node2D = load("res://scenes/player/player.tscn").instantiate()
	player.position = Vector2(64, 64)
	player.movement_enabled = false
	root.add_child(player)
	_check_frames(player.get_node_or_null("AnimatedSprite2D"), [&"idle", &"walk"], "TC-018 player")
	_check(not player.get_node("DebugBody").visible, "TC-018 player debug body hidden")

	var enemy: Node2D = load("res://scenes/enemies/enemy.tscn").instantiate()
	enemy.position = Vector2(640, 64)
	enemy.movement_enabled = false
	root.add_child(enemy)
	_check_frames(enemy.get_node_or_null("AnimatedSprite2D"), [&"idle", &"walk"], "TC-018 enemy slime")
	_check(not enemy.get_node("DebugBody").visible, "TC-018 enemy debug body hidden")

	var summon: Node2D = load("res://scenes/summons/summon.tscn").instantiate()
	summon.attacks_enabled = false
	root.add_child(summon)
	_check_frames(summon.get_node_or_null("AnimatedSprite2D"), [&"idle", &"walk"], "TC-018 summon wolf")
	_check(not summon.get_node("DebugBody").visible, "TC-018 summon debug body hidden")

	var boss: Node2D = load("res://scenes/bosses/forest_boss.tscn").instantiate()
	boss.position = Vector2(640, 480)
	boss.movement_enabled = false
	root.add_child(boss)
	_check_frames(boss.get_node_or_null("AnimatedSprite2D"), [&"idle", &"walk"], "TC-018 boss treant")
	_check(boss.get_node("AnimatedSprite2D").scale == Vector2(2, 2), "TC-018 boss sprite 2x scale")
	var boss_shape: CollisionShape2D = boss.get_node("CollisionShape2D")
	_check(is_equal_approx((boss_shape.shape as CircleShape2D).radius, 16.0), "TC-018 boss collision radius")

	var orb: Node2D = load("res://scenes/pickups/experience_orb.tscn").instantiate()
	orb.position = Vector2(64, 480)
	root.add_child(orb)
	_check_frames(orb.get_node_or_null("AnimatedSprite2D"), [&"idle"], "TC-018 experience orb")
	var orb_sprite: AnimatedSprite2D = orb.get_node("AnimatedSprite2D")
	_check(orb_sprite.is_playing(), "TC-018 orb autoplays pulse")

	# Terrain sprites replace geometry placeholders in the arena base scene.
	var base: Node2D = load("res://scenes/test/player_movement_test.tscn").instantiate()
	root.add_child(base)
	var floor_sprite: Sprite2D = base.get_node_or_null("FloorSprite")
	_check(floor_sprite != null and floor_sprite.texture != null
			and floor_sprite.texture.get_width() == 640, "TC-018 arena floor sprite")
	_check(not base.get_node("Floor").visible, "TC-018 floor placeholder hidden")
	var obstacle_sprite: Sprite2D = base.get_node_or_null("World/ObstacleSprite")
	_check(obstacle_sprite != null and obstacle_sprite.texture != null
			and obstacle_sprite.texture.get_height() == 80, "TC-018 obstacle tree sprite")
	_check(not base.get_node("World/ObstacleVisual").visible, "TC-018 obstacle placeholder hidden")
	base.queue_free()

	# Idle animation plays from spawn and keeps playing while the world runs.
	await _tick(40)
	var player_sprite: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
	_check(player_sprite.is_playing(), "TC-018 player animation playing")

	for node: Node in [player, enemy, summon, boss, orb] as Array:
		if is_instance_valid(node):
			node.queue_free()
	await process_frame
	print("RESULT: ", failures, " failure(s)")
	quit(1 if failures else 0)
