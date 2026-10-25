extends Control
var start_button: Button
var record_label: Label
var _starting: bool = false
func _ready() -> void:
	get_tree().paused = false
	var background: TextureRect = TextureRect.new()
	var floor_texture: Texture2D = load("res://assets/art/arena/floor.png")
	if floor_texture != null:
		background.texture = floor_texture
		background.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0.02, 0.03, 0.025, 0.72)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var box: VBoxContainer = VBoxContainer.new()
	box.custom_minimum_size.x = 340
	box.add_theme_constant_override("separation", 16)
	center.add_child(box)
	var title: Label = Label.new()
	title.text = "WOODCALLER\n林地召唤者"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 26)
	box.add_child(title)
	var help_label: Label = Label.new()
	help_label.text = "WASD 移动 · 召唤物自动作战\n收集经验 · 升级三选一 · 击败最终守卫"
	help_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	help_label.add_theme_font_size_override("font_size", 13)
	box.add_child(help_label)
	record_label = Label.new()
	record_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var data: Dictionary = get_node("/root/SaveStore").data
	record_label.text = "胜场 %d/%d  最高等级 %d\n最长存活 %02d:%02d" % [data.wins, data.runs, data.best_level, int(data.best_seconds) / 60, int(data.best_seconds) % 60]
	box.add_child(record_label)
	start_button = Button.new()
	start_button.text = "进入林地"
	start_button.custom_minimum_size.y = 40
	start_button.pressed.connect(_start)
	box.add_child(start_button)
	var quit_button: Button = Button.new()
	quit_button.text = "退出"
	quit_button.pressed.connect(func() -> void: _play_click(); get_tree().quit())
	box.add_child(quit_button)
	start_button.grab_focus()
func _play_click() -> void:
	var sfx: Node = get_node_or_null("/root/Sfx")
	if sfx != null:
		sfx.play(&"ui_click")
func _start() -> void:
	if _starting:
		return
	_starting = true
	start_button.disabled = true
	_play_click()
	_open_arena.call_deferred()
func _open_arena() -> void:
	var error: Error = get_tree().change_scene_to_file("res://scenes/game/arena.tscn")
	if error != OK:
		_starting = false
		start_button.disabled = false
		record_label.text = "无法开始 · 请重试"
