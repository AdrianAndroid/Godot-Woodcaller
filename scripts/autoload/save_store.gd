extends Node
signal save_failed(message: String)
signal saved
const DEFAULT_DATA: Dictionary = {"version": 1, "runs": 0, "wins": 0, "best_seconds": 0.0, "best_level": 1}
var data: Dictionary = DEFAULT_DATA.duplicate()
# Override only for isolated tests. Production always uses OS user data directory.
var storage_directory: String = ""
func _ready() -> void:
	load_data()
func get_save_path() -> String:
	var directory: String = OS.get_user_data_dir() if storage_directory.is_empty() else storage_directory
	return directory.path_join("progress.json")
func _read_valid(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null or file.get_length() > 65536:
		return {}
	var parser: JSON = JSON.new()
	if parser.parse(file.get_as_text()) != OK:
		return {}
	var parsed: Variant = parser.data
	if not parsed is Dictionary:
		return {}
	var result: Dictionary = parsed
	for key: String in DEFAULT_DATA:
		if not result.has(key) or not (result[key] is int or result[key] is float):
			return {}
		if not is_finite(float(result[key])) or float(result[key]) < 0.0 or float(result[key]) > 1000000000.0:
			return {}
	if result.version != 1 or result.wins > result.runs or result.best_level < 1:
		return {}
	return {"version": 1, "runs": int(result.runs), "wins": int(result.wins), "best_seconds": float(result.best_seconds), "best_level": int(result.best_level)}
func load_data() -> void:
	var loaded: Dictionary = _read_valid(get_save_path())
	if loaded.is_empty():
		loaded = _read_valid(get_save_path() + ".bak")
	data = DEFAULT_DATA.duplicate() if loaded.is_empty() else loaded
func record_run(won: bool, seconds: float, level: int) -> bool:
	if not is_finite(seconds) or seconds < 0.0 or level < 1:
		return false
	var next_data: Dictionary = data.duplicate()
	next_data.runs += 1
	next_data.wins += 1 if won else 0
	next_data.best_seconds = maxf(next_data.best_seconds, seconds)
	next_data.best_level = maxi(next_data.best_level, level)
	if not _write_data(next_data):
		return false
	data = next_data
	saved.emit()
	return true
func _write_data(next_data: Dictionary) -> bool:
	var path: String = get_save_path()
	var error: Error = DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	if error != OK:
		return _fail("无法创建存档目录")
	var file: FileAccess = FileAccess.open(path + ".tmp", FileAccess.WRITE)
	if file == null:
		return _fail("无法写入存档")
	file.store_string(JSON.stringify(next_data))
	file.flush()
	var write_error: Error = file.get_error()
	file.close()
	if write_error != OK:
		return _fail("存档写入失败")
	# Rotate only valid data, so a corrupt primary never destroys a valid backup.
	var rotate: bool = not _read_valid(path).is_empty()
	if rotate and DirAccess.rename_absolute(path, path + ".bak") != OK:
		return _fail("无法备份存档")
	if DirAccess.rename_absolute(path + ".tmp", path) != OK:
		if rotate:
			DirAccess.rename_absolute(path + ".bak", path)
		return _fail("无法提交存档")
	return true
func _fail(message: String) -> bool:
	save_failed.emit(message)
	push_warning(message)
	return false
