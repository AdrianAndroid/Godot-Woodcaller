extends SceneTree
var failures: int = 0
func _initialize() -> void:
	_run.call_deferred()
func _check(ok: bool, label: String) -> void:
	print("PASS: " if ok else "FAIL: ", label)
	if not ok: failures += 1
func _run() -> void:
	var store: Node = root.get_node("SaveStore")
	store.storage_directory = OS.get_user_data_dir().path_join("end_test_%d" % Time.get_ticks_usec())
	store.load_data()
	var arena: WoodcallerArena = load("res://scenes/game/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	arena.wave_director.elapsed = 123.0
	arena.progression.add_experience(10)
	_check(paused and arena.run_ui.panel.visible, "TC-015 upgrade initially paused")
	# A directory at the temporary-file path simulates a real write failure.
	DirAccess.make_dir_recursive_absolute(store.get_save_path() + ".tmp")
	arena.get_node("Player").take_damage(1000)
	_check(not arena._result_saved and store.data.runs == 0 and arena.run_ui.retry_save_button.visible, "TC-015 save failure preserves data and offers retry")
	DirAccess.remove_absolute(store.get_save_path() + ".tmp")
	arena.run_ui.retry_save_button.pressed.emit()
	_check(arena._result_saved and not arena.run_ui.retry_save_button.visible, "TC-015 retry saves after filesystem recovery")
	_check(arena.run_ended and paused and not arena.wave_director.active, "TC-015 death ends and stops waves")
	_check(arena.run_ui.result_panel.visible and not arena.run_ui.panel.visible and arena.pending_levels.is_empty(), "TC-015 result supersedes upgrade")
	_check(store.data.runs == 1 and store.data.wins == 0 and store.data.best_seconds == 123.0, "TC-015 defeat saved once")
	arena._on_player_died()
	arena._on_boss_defeated()
	arena._retry_save()
	_check(store.data.runs == 1 and store.data.wins == 0, "TC-015 duplicate events do not resave")
	arena.run_ui.buttons[0].pressed.emit()
	_check(arena.get_node("Summon").damage == 10.0, "TC-015 stale upgrade cannot apply")
	arena.run_ui.restart_button.pressed.emit()
	await scene_changed
	var fresh: WoodcallerArena = current_scene
	_check(not paused and not fresh.run_ended and fresh.wave_director.active, "TC-015 restart active and unpaused")
	_check(fresh.progression.level == 1 and fresh.get_node("Player/Health").current_health == 100, "TC-015 restart resets player and level")
	_check(get_nodes_in_group("summon").size() == 1 and get_nodes_in_group("enemy").size() == 3, "TC-015 restart clears old entities")
	fresh._spawn_boss()
	var boss: ForestBoss = get_nodes_in_group("boss")[0]
	boss.take_damage(10000)
	_check(fresh.run_ended and fresh._result_won and paused, "TC-015 boss kill wins")
	_check(store.data.runs == 2 and store.data.wins == 1, "TC-015 victory persisted")
	_check(fresh.run_ui.result_label.text.contains("林地获救"), "TC-015 victory UI")
	fresh.queue_free()
	await process_frame
	_check(not paused, "TC-015 leaving arena clears pause")
	var path: String = store.get_save_path()
	for suffix: String in ["", ".bak", ".tmp"]:
		if FileAccess.file_exists(path + suffix): DirAccess.remove_absolute(path + suffix)
	DirAccess.remove_absolute(path.get_base_dir())
	print("RESULT: ", failures, " failure(s)")
	quit(1 if failures else 0)
