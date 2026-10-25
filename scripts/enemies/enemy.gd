class_name WoodcallerEnemy
extends CharacterBody2D
## Straight-line pursuit. Collides with world only; no damage or pathfinding yet.

signal defeated(position: Vector2, experience: int)

@export_range(1, 10000, 1) var experience_reward: int = 5

signal target_changed(target: Node2D)
signal movement_changed(is_moving: bool)

@export_range(0.0, 1000.0, 1.0) var move_speed: float = 65.0
@export_range(0.0, 128.0, 1.0) var stop_distance: float = 20.0
@export_range(0.05, 5.0, 0.05) var target_search_interval: float = 0.25
@export var target_group: StringName = &"player"
@export var movement_enabled: bool = true:
	set(value):
		movement_enabled = value
		if not value:
			_stop_movement()

@export_range(0.0, 1000.0, 1.0) var contact_damage: float = 8.0
@export_range(0.1, 10.0, 0.1) var contact_interval: float = 1.0
var _contact_remaining: float = 0.0

var _target: Node2D
var _had_target: bool = false
var _search_remaining: float = 0.0
var _is_moving: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	_contact_remaining = maxf(_contact_remaining - delta, 0.0)
	if not movement_enabled:
		_stop_movement()
		return
	if not _target_is_available():
		if _had_target:
			_target = null
			_had_target = false
			_search_remaining = 0.0
			target_changed.emit(null)
		_search_remaining -= delta
		if _search_remaining <= 0.0:
			_search_remaining = target_search_interval
			_find_target()
	if not _target_is_available():
		_stop_movement()
		return

	var offset: Vector2 = _target.global_position - global_position
	var distance: float = offset.length()
	if distance <= 24.0 and _contact_remaining <= 0.0 and _target.has_method("take_damage"):
		var contact_ray: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(global_position, _target.global_position, 1)
		if get_world_2d().direct_space_state.intersect_ray(contact_ray).is_empty():
			_contact_remaining = contact_interval
			_target.take_damage(contact_damage)
	var remaining_distance: float = maxf(distance - stop_distance, 0.0)
	if remaining_distance <= 0.01:
		_stop_movement()
		return
	# Clamp the last step to the stopping radius, even at high speed/low tick rate.
	velocity = offset / distance * minf(maxf(move_speed, 0.0), remaining_distance / delta)
	if not is_zero_approx(velocity.x):
		animated_sprite.flip_h = velocity.x < 0.0
	move_and_slide()
	_set_moving(not get_real_velocity().is_zero_approx())


func _target_is_available() -> bool:
	return is_instance_valid(_target) and _target.is_inside_tree() \
		and not _target.is_queued_for_deletion() and _target.is_in_group(target_group)


func _find_target() -> void:
	for candidate: Node in get_tree().get_nodes_in_group(target_group):
		if candidate is Node2D and candidate != self and not candidate.is_queued_for_deletion():
			_target = candidate as Node2D
			_had_target = true
			target_changed.emit(_target)
			return


func _stop_movement() -> void:
	velocity = Vector2.ZERO
	_set_moving(false)


func _set_moving(value: bool) -> void:
	if _is_moving == value:
		return
	_is_moving = value
	if is_instance_valid(animated_sprite):
		var frames: SpriteFrames = animated_sprite.sprite_frames
		var animation_name: StringName = &"walk" if value else &"idle"
		if frames != null and frames.has_animation(animation_name) \
				and frames.get_frame_count(animation_name) > 0:
			animated_sprite.play(animation_name)
		else:
			animated_sprite.stop()
	movement_changed.emit(value)


func _ready() -> void:
	$Health.died.connect(_on_died)
	if is_instance_valid(animated_sprite):
		var frames: SpriteFrames = animated_sprite.sprite_frames
		if frames != null and frames.has_animation(&"idle") \
				and frames.get_frame_count(&"idle") > 0:
			animated_sprite.play(&"idle")


func take_damage(amount: float) -> void:
	($Health as CombatHealth).take_damage(amount)


func _on_died() -> void:
	movement_enabled = false
	remove_from_group("enemy")
	defeated.emit(global_position, experience_reward)
	var sfx: Node = get_node_or_null("/root/Sfx")
	if sfx != null:
		sfx.play(&"enemy_die")
	queue_free()
