extends Node
## Pooled one-shot sound effects. Registered as the Sfx autoload.
## Safe to call during pause; unknown names warn instead of crashing.

signal played(sound: StringName)

const SOUNDS: Dictionary = {
	&"attack": "res://assets/audio/sfx/attack.wav",
	&"enemy_die": "res://assets/audio/sfx/enemy_die.wav",
	&"pickup": "res://assets/audio/sfx/pickup.wav",
	&"levelup": "res://assets/audio/sfx/levelup.wav",
	&"hurt": "res://assets/audio/sfx/hurt.wav",
	&"win": "res://assets/audio/sfx/win.wav",
	&"lose": "res://assets/audio/sfx/lose.wav",
	&"ui_click": "res://assets/audio/sfx/ui_click.wav",
}

@export_range(1, 32, 1) var pool_size: int = 8

var _streams: Dictionary = {}
var _players: Array[AudioStreamPlayer] = []
var _next: int = 0
# The headless dummy audio driver never releases playback instances at exit,
# which trips the no-ERROR gate in tests. Skip real playback there; the
# played signal still fires so gameplay wiring stays testable.
var _headless: bool = DisplayServer.get_name() == "headless"

func _ready() -> void:
	for sound: StringName in SOUNDS:
		var stream: AudioStream = load(SOUNDS[sound])
		if stream == null:
			push_warning("sfx failed to load: %s" % SOUNDS[sound])
		_streams[sound] = stream
	for index: int in range(pool_size):
		var player := AudioStreamPlayer.new()
		add_child(player)
		_players.append(player)

func _exit_tree() -> void:
	# Release pooled streams before teardown so headless runs exit cleanly.
	for player: AudioStreamPlayer in _players:
		player.stop()
		player.stream = null
	_streams.clear()

func has_sound(sound: StringName) -> bool:
	return _streams.get(sound) != null

func play(sound: StringName, volume_db: float = 0.0, pitch_jitter: float = 0.05) -> void:
	var stream: AudioStream = _streams.get(sound)
	if stream == null:
		push_warning("unknown sfx: %s" % sound)
		return
	if _headless:
		played.emit(sound)
		return
	var player: AudioStreamPlayer = _players[_next]
	_next = (_next + 1) % _players.size()
	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = 1.0 + randf_range(-pitch_jitter, pitch_jitter)
	player.play()
	played.emit(sound)
