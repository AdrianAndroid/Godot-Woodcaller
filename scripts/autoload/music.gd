extends AudioStreamPlayer
## Looping background music for menu and run. Registered as the Music autoload.

const TRACK: String = "res://assets/audio/music/dark_woods.ogg"
const TRACK_VOLUME_DB: float = -8.0

func _ready() -> void:
	stream = load(TRACK)
	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = true
	volume_db = TRACK_VOLUME_DB
	if stream == null:
		return
	# The headless dummy audio driver never releases long-running playback
	# instances at exit, which trips the no-ERROR gate in tests. Real runs
	# (editor or exported app) always have a working audio server.
	if DisplayServer.get_name() == "headless":
		return
	play()

func _exit_tree() -> void:
	# Release the stream before teardown so headless runs exit cleanly.
	stop()
	stream = null
