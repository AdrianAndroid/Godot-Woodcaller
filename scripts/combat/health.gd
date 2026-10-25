class_name CombatHealth
extends Node

signal health_changed(current: float, maximum: float)
signal died

@export_range(1.0, 100000.0, 1.0) var max_health: float = 30.0
var current_health: float = 0.0
var is_dead: bool = false

func _ready() -> void:
	current_health = maxf(max_health, 1.0)
	health_changed.emit(current_health, max_health)

func take_damage(amount: float) -> void:
	if is_dead or amount <= 0.0 or not is_finite(amount):
		return
	current_health = maxf(current_health - amount, 0.0)
	health_changed.emit(current_health, max_health)
	if current_health <= 0.0:
		is_dead = true
		died.emit()

func heal(amount: float) -> void:
	if is_dead or amount <= 0.0 or not is_finite(amount):
		return
	current_health = minf(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)

func increase_max_health(amount: float) -> void:
	if is_dead or amount <= 0.0 or not is_finite(amount):
		return
	max_health += amount
	health_changed.emit(current_health, max_health)
