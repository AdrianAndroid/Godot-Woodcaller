extends SceneTree
func _initialize() -> void:
	var text: String = "Woodcaller — Engine and third-party notices\n\nGodot Engine\n" + Engine.get_license_text()
	text += "\n\nThird-party copyright notices\n" + JSON.stringify(Engine.get_copyright_info(), "  ")
	var licenses: Dictionary = Engine.get_license_info()
	for name: String in licenses:
		text += "\n\n" + name + "\n" + str(licenses[name])
	var file: FileAccess = FileAccess.open("res://THIRD_PARTY_NOTICES.txt", FileAccess.WRITE)
	if file == null:
		push_error("Cannot write notices")
		quit(1)
		return
	file.store_string(text)
	file.close()
	quit(0)
