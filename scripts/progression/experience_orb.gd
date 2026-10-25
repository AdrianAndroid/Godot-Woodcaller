class_name ExperienceOrb
extends Area2D
signal collected(amount: int)
@export_range(1, 10000) var amount: int = 5
var _collected: bool = false
func _ready() -> void:
	body_entered.connect(_on_body_entered)
func _on_body_entered(body: Node2D) -> void:
	if _collected or not body.is_in_group("player"):
		return
	_collected = true
	collected.emit(amount)
	var sfx: Node = get_node_or_null("/root/Sfx")
	if sfx != null:
		sfx.play(&"pickup")
	queue_free()
