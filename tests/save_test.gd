extends SceneTree
var failures: int = 0
func _initialize() -> void:
	_run.call_deferred()
func _check(ok: bool, label: String) -> void:
	print("PASS: " if ok else "FAIL: ", label)
	if not ok: failures += 1
func _run() -> void:
	var store: Node = load("res://scripts/autoload/save_store.gd").new()
	store.storage_directory = OS.get_user_data_dir().path_join("isolated_test_%d" % Time.get_ticks_usec())
	root.add_child(store)
	_check(store.data.runs == 0, "TC-013 first run defaults")
	_check(store.get_save_path().begins_with(OS.get_user_data_dir()), "TC-013 user data directory")
	_check(store.record_run(true, 1800.0, 20), "TC-013 write result")
	store.load_data()
	_check(store.data.wins == 1 and store.data.best_level == 20, "TC-013 persisted data reload")
	_check(store.record_run(false, 30.0, 2), "TC-013 second commit")
	_check(store.data.runs == 2 and store.data.best_seconds == 1800.0, "TC-013 max records retained")
	var path: String = store.get_save_path()
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_string("{invalid")
	file.close()
	store.load_data()
	_check(store.data.runs == 1, "TC-013 corrupt primary restores backup")
	_check(store.record_run(false, 60.0, 3), "TC-013 recover and save")
	_check(not store.record_run(true, -1.0, 2), "TC-013 reject invalid result")
	for suffix: String in ["", ".bak", ".tmp"]:
		if FileAccess.file_exists(path + suffix):
			DirAccess.remove_absolute(path + suffix)
	DirAccess.remove_absolute(path.get_base_dir())
	store.queue_free()
	await process_frame
	print("RESULT: ", failures, " failure(s)")
	quit(1 if failures else 0)
