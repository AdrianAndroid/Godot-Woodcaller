class_name RunProgression
extends Node
signal experience_changed(level: int, current: int, required: int)
signal level_gained(level: int)
@export_range(1, 1000) var base_requirement: int = 10
@export_range(0, 1000) var requirement_growth: int = 5
var level: int = 1
var experience: int = 0
func required_experience() -> int:
	return base_requirement + (level - 1) * requirement_growth
func add_experience(amount: int) -> void:
	if amount <= 0:
		return
	experience += amount
	while experience >= required_experience():
		experience -= required_experience()
		level += 1
		level_gained.emit(level)
	experience_changed.emit(level, experience, required_experience())
