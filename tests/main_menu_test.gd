extends SceneTree
var failures: int = 0
func _initialize() -> void:
	_run.call_deferred()
func _check(ok: bool, label: String) -> void:
	print("PASS: " if ok else "FAIL: ", label)
	if not ok: failures += 1
func _capture(label: String) -> void:
	if not OS.get_cmdline_user_args().has("--capture-ui"):
		return
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/results/ui-%s.png" % label)
func _run() -> void:
	var store: Node = root.get_node("SaveStore")
	store.storage_directory = OS.get_user_data_dir().path_join("menu_test_%d" % Time.get_ticks_usec())
	store.load_data()
	var menu: Control = load("res://scenes/ui/main_menu.tscn").instantiate()
	root.add_child(menu)
	current_scene = menu
	_check(menu.start_button.text == "进入林地", "TC-016 start button exists")
	_check(menu.record_label.text.contains("0/0"), "TC-016 fresh records displayed")
	await _capture("menu")
	menu.start_button.pressed.emit()
	menu.start_button.pressed.emit()
	await scene_changed
	var arena: WoodcallerArena = current_scene
	_check(arena != null and arena.wave_director.active, "TC-016 start creates arena once")
	await _capture("arena")
	arena.progression.add_experience(10)
	await _capture("upgrade")
	arena.run_ui.buttons[0].pressed.emit()
	arena.get_node("Player").take_damage(10000)
	_check(arena.run_ended and arena.run_ui.result_panel.visible, "TC-016 result is accessible")
	await _capture("result")
	arena.run_ui.menu_requested.emit()
	await scene_changed
	_check(current_scene is Control and not paused, "TC-016 return to unpaused menu")
	_check(current_scene.record_label.text.contains("0/1"), "TC-016 menu reflects saved result")
	current_scene.queue_free()
	await process_frame
	var path: String = store.get_save_path()
	for suffix: String in ["", ".bak", ".tmp"]:
		if FileAccess.file_exists(path + suffix): DirAccess.remove_absolute(path + suffix)
	DirAccess.remove_absolute(path.get_base_dir())
	print("RESULT: ", failures, " failure(s)")
	quit(1 if failures else 0)
