class_name WoodcallerSummon
extends Node2D
## Guardian circles its owner and automatically strikes the nearest visible enemy.

signal attacked(target: Node2D, damage: float)

@export var owner_group: StringName = &"player"
@export_range(1.0, 500.0, 1.0) var attack_range: float = 120.0
@export_range(1.0, 1000.0, 1.0) var damage: float = 10.0
@export_range(0.05, 10.0, 0.05) var attack_interval: float = 0.7
@export_range(0.0, 100.0, 1.0) var orbit_radius: float = 30.0
@export_range(0.0, 10.0, 0.1) var orbit_speed: float = 1.2
@export var initial_angle: float = 0.0
@export var attacks_enabled: bool = true

var _owner_actor: Node2D
var _angle: float = 0.0
var _cooldown: float = 0.0
var _last_position: Vector2

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	_angle = initial_angle
	_last_position = global_position

func _physics_process(delta: float) -> void:
	if not is_instance_valid(_owner_actor) or not _owner_actor.is_inside_tree():
		_owner_actor = get_tree().get_first_node_in_group(owner_group) as Node2D
	if not is_instance_valid(_owner_actor) or _owner_actor.is_queued_for_deletion():
		return
	_angle = fmod(_angle + orbit_speed * delta, TAU)
	global_position = _owner_actor.global_position + Vector2.from_angle(_angle) * orbit_radius
	_update_animation()
	_cooldown = maxf(_cooldown - delta, 0.0)
	if not attacks_enabled or _cooldown > 0.0:
		return
	var target: Node2D = _find_target()
	if target == null:
		return
	_cooldown = attack_interval
	target.take_damage(damage)
	attacked.emit(target, damage)
	var sfx: Node = get_node_or_null("/root/Sfx")
	if sfx != null:
		sfx.play(&"attack")

func _update_animation() -> void:
	var offset: Vector2 = global_position - _last_position
	_last_position = global_position
	if not is_instance_valid(animated_sprite):
		return
	if offset.x != 0.0:
		animated_sprite.flip_h = offset.x < 0.0
	var frames: SpriteFrames = animated_sprite.sprite_frames
	var animation_name: StringName = &"walk" if offset.length_squared() > 0.01 else &"idle"
	if frames != null and frames.has_animation(animation_name) \
			and frames.get_frame_count(animation_name) > 0:
		if animated_sprite.animation != animation_name or not animated_sprite.is_playing():
			animated_sprite.play(animation_name)

func _find_target() -> Node2D:
	var closest: Node2D = null
	var closest_distance: float = attack_range * attack_range
	for node: Node in get_tree().get_nodes_in_group("enemy"):
		var candidate: Node2D = node as Node2D
		if candidate == null or candidate.is_queued_for_deletion() or not candidate.has_method("take_damage"):
			continue
		var health: CombatHealth = candidate.get_node_or_null("Health") as CombatHealth
		if health == null or health.is_dead:
			continue
		var distance: float = global_position.distance_squared_to(candidate.global_position)
		if distance > closest_distance:
			continue
		var ray: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(global_position, candidate.global_position, 1)
		if not get_world_2d().direct_space_state.intersect_ray(ray).is_empty():
			continue
		closest = candidate
		closest_distance = distance
	return closest
