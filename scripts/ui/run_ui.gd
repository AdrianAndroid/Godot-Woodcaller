class_name RunUI
extends CanvasLayer
signal upgrade_selected(choice: int)
signal menu_requested
signal restart_requested
signal retry_save_requested
var result_panel: PanelContainer
var result_label: Label
var save_label: Label
var restart_button: Button
var retry_save_button: Button
var boss_label: Label
var health_label: Label
var timer_label: Label
var status_label: Label
var panel: PanelContainer
var heading: Label
var buttons: Array[Button] = []
var _can_choose: bool = false
var _choice_count: int = 0
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	boss_label = Label.new()
	boss_label.position = Vector2(230, 320)
	add_child(boss_label)
	health_label = Label.new()
	health_label.position = Vector2(24, 42)
	add_child(health_label)
	timer_label = Label.new()
	timer_label.position = Vector2(520, 20)
	add_child(timer_label)
	status_label = Label.new()
	status_label.position = Vector2(24, 20)
	status_label.add_theme_font_size_override("font_size", 14)
	add_child(status_label)
	panel = PanelContainer.new()
	panel.position = Vector2(150, 85)
	panel.custom_minimum_size = Vector2(340, 190)
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	panel.add_child(box)
	heading = Label.new()
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(heading)
	for index: int in range(3):
		var button: Button = Button.new()
		button.custom_minimum_size.y = 38
		button.pressed.connect(_choose.bind(index))
		box.add_child(button)
		buttons.append(button)
	add_child(panel)
	panel.hide()
	_build_result_panel()
func update_experience(level: int, current: int, required: int) -> void:
	status_label.text = "等级 %d  经验 %d/%d" % [level, current, required]
func show_choices(level: int, labels: Array[String]) -> void:
	heading.text = "等级 %d · 选择强化" % level
	_choice_count = mini(labels.size(), buttons.size())
	for index: int in range(buttons.size()):
		var button: Button = buttons[index]
		if index < _choice_count:
			button.text = "%d  %s" % [index + 1, labels[index]]
			button.show()
		else:
			button.hide()
	_can_choose = _choice_count > 0
	panel.show()
	buttons[0].grab_focus()
func _choose(choice: int) -> void:
	if not _can_choose or choice < 0 or choice >= _choice_count:
		return
	_can_choose = false
	panel.hide()
	_play_sfx(&"levelup")
	upgrade_selected.emit(choice)
func _unhandled_key_input(event: InputEvent) -> void:
	if not _can_choose or not event is InputEventKey or not event.is_pressed() or event.is_echo():
		return
	var code: int = (event as InputEventKey).physical_keycode
	if code >= KEY_1 and code <= KEY_3:
		_choose(code - KEY_1)
		get_viewport().set_input_as_handled()

func update_health(current: float, maximum: float) -> void:
	health_label.text = "生命 %d/%d" % [ceili(current), ceili(maximum)]
func update_time(seconds: float) -> void:
	timer_label.text = "%02d:%02d" % [int(seconds) / 60, int(seconds) % 60]

func update_boss_health(current: float, maximum: float) -> void:
	boss_label.text = "林地守卫 %d/%d" % [ceili(current), ceili(maximum)]

func _build_result_panel() -> void:
	result_panel = PanelContainer.new()
	result_panel.position = Vector2(140, 62)
	result_panel.custom_minimum_size = Vector2(360, 240)
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	result_panel.add_child(box)
	result_label = Label.new()
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(result_label)
	save_label = Label.new()
	save_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(save_label)
	retry_save_button = Button.new()
	retry_save_button.text = "重试保存"
	retry_save_button.pressed.connect(func() -> void: _play_sfx(&"ui_click"); retry_save_requested.emit())
	box.add_child(retry_save_button)
	restart_button = Button.new()
	restart_button.text = "再来一局"
	restart_button.custom_minimum_size.y = 38
	restart_button.pressed.connect(_request_restart)
	box.add_child(restart_button)
	var menu_button: Button = Button.new()
	menu_button.text = "返回主菜单"
	menu_button.pressed.connect(func() -> void: _play_sfx(&"ui_click"); menu_requested.emit())
	box.add_child(menu_button)
	var quit_button: Button = Button.new()
	quit_button.text = "退出游戏"
	quit_button.custom_minimum_size.y = 38
	quit_button.pressed.connect(func() -> void: _play_sfx(&"ui_click"); get_tree().quit())
	box.add_child(quit_button)
	add_child(result_panel)
	result_panel.hide()

func show_result(won: bool, seconds: float, level: int, kills: int, saved_ok: bool) -> void:
	_can_choose = false
	panel.hide()
	result_label.text = "%s\n存活 %02d:%02d  等级 %d\n击败 %d" % ["林地获救" if won else "旅途结束", int(seconds) / 60, int(seconds) % 60, level, kills]
	update_save_status(saved_ok)
	result_panel.show()
	restart_button.disabled = false
	restart_button.grab_focus()
	_play_sfx(&"win" if won else &"lose")

func _play_sfx(sound: StringName) -> void:
	var sfx: Node = get_node_or_null("/root/Sfx")
	if sfx != null:
		sfx.play(sound)

func update_save_status(saved_ok: bool) -> void:
	save_label.text = "成绩已保存" if saved_ok else "保存失败 · 可重试"
	retry_save_button.visible = not saved_ok

func _request_restart() -> void:
	if restart_button.disabled:
		return
	restart_button.disabled = true
	_play_sfx(&"ui_click")
	restart_requested.emit()
