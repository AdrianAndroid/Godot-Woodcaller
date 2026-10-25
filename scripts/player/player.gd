class_name WoodcallerPlayer
extends CharacterBody2D
## Movement only. World collision is layer 1; player occupies layer 2.

signal movement_changed(is_moving: bool)
signal facing_changed(direction: Vector2)

@export_range(0.0, 1000.0, 1.0) var move_speed: float = 120.0
@export var movement_enabled: bool = true:
	set(value):
		movement_enabled = value
		if not movement_enabled:
			_stop_movement()

var facing_direction: Vector2 = Vector2.DOWN
var _is_moving: bool = false
var _has_focus: bool = true

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(_delta: float) -> void:
	_hurt_remaining = maxf(_hurt_remaining - _delta, 0.0)
	if not movement_enabled or not _has_focus:
		_stop_movement()
		return

	var input_direction: Vector2 = Input.get_vector(
		"move_left", "move_right", "move_up", "move_down"
	)
	if not input_direction.is_zero_approx():
		if not input_direction.is_equal_approx(facing_direction):
			facing_direction = input_direction
			facing_changed.emit(facing_direction)
		if not is_zero_approx(input_direction.x):
			animated_sprite.flip_h = input_direction.x < 0.0

	velocity = input_direction * move_speed
	move_and_slide()
	_set_moving(not get_real_velocity().is_zero_approx())


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		_has_focus = false
		for action: StringName in [&"move_left", &"move_right", &"move_up", &"move_down"]:
			Input.action_release(action)
		_stop_movement()
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		_has_focus = true


func _stop_movement() -> void:
	velocity = Vector2.ZERO
	_set_moving(false)


func _set_moving(value: bool) -> void:
	if _is_moving == value:
		return
	_is_moving = value
	_update_animation()
	movement_changed.emit(_is_moving)


func _update_animation() -> void:
	if not is_instance_valid(animated_sprite):
		return
	var frames: SpriteFrames = animated_sprite.sprite_frames
	var animation_name: StringName = &"walk" if _is_moving else &"idle"
	if frames != null and frames.has_animation(animation_name):
		if frames.get_frame_count(animation_name) > 0:
			animated_sprite.play(animation_name)
			return
	animated_sprite.stop()


signal died
@export_range(0.0, 5.0, 0.05) var hurt_invulnerability: float = 0.8
var _hurt_remaining: float = 0.0

func _ready() -> void:
	$Health.died.connect(_on_died)
	_update_animation()

func take_damage(amount: float) -> void:
	if _hurt_remaining > 0.0 or amount <= 0.0 or not is_finite(amount):
		return
	_hurt_remaining = hurt_invulnerability
	($Health as CombatHealth).take_damage(amount)
	var sfx: Node = get_node_or_null("/root/Sfx")
	if sfx != null:
		sfx.play(&"hurt")

func _on_died() -> void:
	movement_enabled = false
	died.emit()
