class_name ForestBoss
extends WoodcallerEnemy
signal enraged
signal boss_defeated
@export_range(1.0, 1000.0, 1.0) var rage_speed: float = 85.0
@export_range(1.0, 30.0, 0.1) var pulse_interval: float = 5.0
@export_range(0.2, 5.0, 0.1) var warning_duration: float = 1.2
@export_range(8.0, 128.0, 1.0) var pulse_radius: float = 42.0
@export_range(1.0, 1000.0, 1.0) var pulse_damage: float = 20.0
var is_enraged: bool = false
var _pulse_remaining: float = 3.0
var _warning_remaining: float = 0.0
var _marked_position: Vector2
var _warning: Polygon2D
func _ready() -> void:
	super._ready()
	$Health.health_changed.connect(_on_health_changed)
	_warning = Polygon2D.new()
	var points: PackedVector2Array = PackedVector2Array()
	for index: int in range(16):
		points.append(Vector2.from_angle(TAU * index / 16.0) * pulse_radius)
	_warning.polygon = points
	_warning.color = Color(0.7, 0.18, 0.12, 0.45)
	_warning.z_index = -1
	add_child(_warning)
	_warning.hide()
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if not movement_enabled or not _target_is_available():
		_warning.hide()
		_warning_remaining = 0.0
		return
	if _warning_remaining > 0.0:
		_warning.global_position = _marked_position
		_warning_remaining -= delta
		if _warning_remaining <= 0.0:
			_warning.hide()
			if _target.global_position.distance_to(_marked_position) <= pulse_radius and _target.has_method("take_damage"):
				_target.take_damage(pulse_damage)
		return
	_pulse_remaining -= delta
	if _pulse_remaining <= 0.0:
		_pulse_remaining = pulse_interval
		_warning_remaining = warning_duration
		_marked_position = _target.global_position
		_warning.global_position = _marked_position
		_warning.show()
func _on_health_changed(current: float, maximum: float) -> void:
	if current > 0.0 and current <= maximum * 0.5 and not is_enraged:
		is_enraged = true
		move_speed = rage_speed
		$DebugBody.color = Color(0.7, 0.25, 0.15, 1)
		enraged.emit()
func _on_died() -> void:
	boss_defeated.emit()
	super._on_died()
