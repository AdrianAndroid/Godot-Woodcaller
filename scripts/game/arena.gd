class_name WoodcallerArena
extends Node2D
signal run_finished(won: bool)
signal run_won
var run_ended: bool = false
var enemies_defeated: int = 0
var _result_won: bool = false
var _result_seconds: float = 0.0
var _result_level: int = 1
var _result_saved: bool = false
var _restart_pending: bool = false
var boss_spawned: bool = false

const BOSS_SCENE: PackedScene = preload("res://scenes/bosses/forest_boss.tscn")
const ORB_SCENE: PackedScene = preload("res://scenes/pickups/experience_orb.tscn")
const SUMMON_SCENE: PackedScene = preload("res://scenes/summons/summon.tscn")
@onready var save_store: Node = get_node("/root/SaveStore")
@onready var wave_director: Node = get_node("/root/WaveDirector")
@onready var progression: RunProgression = $Progression
@onready var run_ui: RunUI = $RunUI
var pending_levels: Array[int] = []
var summon_damage_bonus: float = 0.0
var summon_interval_scale: float = 1.0
var summon_reach_scale: float = 1.0
var magnet_scale: float = 1.0
var current_choices: Array[StringName] = []
# Tests may pin the offered upgrades; empty keeps the random draw.
var forced_choices: Array[StringName] = []
var _upgrade_rng: RandomNumberGenerator = RandomNumberGenerator.new()
func _ready() -> void:
	$Player/Health.health_changed.connect(run_ui.update_health)
	run_ui.update_health($Player/Health.current_health, $Player/Health.max_health)
	$Player.died.connect(_on_player_died)
	wave_director.time_changed.connect(run_ui.update_time)
	wave_director.boss_due.connect(_spawn_boss)
	wave_director.start_run(self)
	$Instructions.hide()
	progression.experience_changed.connect(run_ui.update_experience)
	progression.level_gained.connect(_on_level_gained)
	run_ui.upgrade_selected.connect(_on_upgrade_selected)
	run_ui.restart_requested.connect(_on_restart_requested)
	run_ui.menu_requested.connect(_on_menu_requested)
	run_ui.retry_save_requested.connect(_retry_save)
	run_ui.update_experience(1, 0, progression.required_experience())
	get_tree().node_added.connect(_on_node_added)
	_upgrade_rng.randomize()
	for enemy: Node in get_tree().get_nodes_in_group("enemy"):
		_register_enemy(enemy)
func _on_node_added(node: Node) -> void:
	if node.is_in_group("enemy"):
		_register_enemy(node)
func _register_enemy(enemy: Node) -> void:
	if is_ancestor_of(enemy) and enemy.has_signal("defeated") and not enemy.defeated.is_connected(_on_enemy_defeated):
		enemy.defeated.connect(_on_enemy_defeated)
func _on_enemy_defeated(at_position: Vector2, reward: int) -> void:
	if run_ended:
		return
	enemies_defeated += 1
	var orb: ExperienceOrb = ORB_SCENE.instantiate()
	orb.amount = reward
	orb.position = to_local(at_position)
	orb.collected.connect(progression.add_experience)
	_apply_magnet_to_orb(orb)
	add_child.call_deferred(orb)
func _on_level_gained(new_level: int) -> void:
	if run_ended:
		return
	pending_levels.append(new_level)
	if pending_levels.size() == 1:
		_present_upgrade()
func _present_upgrade() -> void:
	get_tree().paused = true
	# Offer three distinct upgrades drawn from the currently available pool.
	var pool: Array[Dictionary] = []
	for entry: Dictionary in _upgrade_pool():
		if entry["open"]:
			pool.append(entry)
	current_choices.clear()
	var labels: Array[String] = []
	if forced_choices.is_empty():
		while current_choices.size() < 3 and not pool.is_empty():
			var index: int = _upgrade_rng.randi_range(0, pool.size() - 1)
			current_choices.append(pool[index]["id"])
			labels.append(pool[index]["label"])
			pool.remove_at(index)
	else:
		for entry: Dictionary in pool:
			if forced_choices.has(entry["id"]) and current_choices.size() < 3:
				current_choices.append(entry["id"])
				labels.append(entry["label"])
	run_ui.show_choices(pending_levels[0], labels)

func _upgrade_pool() -> Array[Dictionary]:
	var summon_count: int = get_tree().get_nodes_in_group("summon").size()
	return [
		{"id": &"power", "label": "灵力 +5（召唤物伤害）", "open": true},
		{"id": &"swift", "label": "移速 +10%", "open": $Player.move_speed < 299.0},
		{"id": &"bond", "label": "召唤 +1", "open": summon_count < 5},
		{"id": &"haste", "label": "攻击间隔 -10%", "open": summon_interval_scale > 0.11},
		{"id": &"vitality", "label": "生命上限 +20 并恢复 20", "open": true},
		{"id": &"reach", "label": "攻击范围 +20%", "open": summon_reach_scale < 3.0},
		{"id": &"magnet", "label": "拾取范围 +40%", "open": magnet_scale < 5.0},
	]

func _on_upgrade_selected(choice: int) -> void:
	if run_ended or pending_levels.is_empty() or choice < 0 or choice >= current_choices.size():
		return
	_apply_upgrade(current_choices[choice])
	current_choices.clear()
	pending_levels.pop_front()
	if pending_levels.is_empty():
		get_tree().paused = false
	else:
		_present_upgrade()

func _apply_upgrade(id: StringName) -> void:
	match id:
		&"power":
			summon_damage_bonus += 5.0
			for summon: Node in get_tree().get_nodes_in_group("summon"):
				summon.damage += 5.0
		&"swift":
			$Player.move_speed = minf($Player.move_speed * 1.1, 300.0)
		&"bond":
			var summons: Array[Node] = get_tree().get_nodes_in_group("summon")
			var summon: WoodcallerSummon = SUMMON_SCENE.instantiate()
			summon.damage += summon_damage_bonus
			summon.attack_interval = maxf(0.7 * summon_interval_scale, 0.07)
			summon.attack_range *= summon_reach_scale
			summon.initial_angle = TAU * float(summons.size()) / 5.0
			add_child(summon)
		&"haste":
			summon_interval_scale = maxf(summon_interval_scale * 0.9, 0.1)
			for summon: Node in get_tree().get_nodes_in_group("summon"):
				summon.attack_interval = maxf(0.7 * summon_interval_scale, 0.07)
		&"vitality":
			var health: CombatHealth = $Player/Health
			health.increase_max_health(20.0)
			health.heal(20.0)
		&"reach":
			summon_reach_scale = minf(summon_reach_scale * 1.2, 3.0)
			for summon: Node in get_tree().get_nodes_in_group("summon"):
				summon.attack_range = 120.0 * summon_reach_scale
		&"magnet":
			magnet_scale = minf(magnet_scale * 1.4, 5.0)
			for orb: Node in get_tree().get_nodes_in_group("experience_orb"):
				_apply_magnet_to_orb(orb)

func _apply_magnet_to_orb(orb: Node) -> void:
	var shape_node: CollisionShape2D = orb.get_node_or_null("CollisionShape2D")
	if shape_node == null:
		return
	var circle: CircleShape2D = shape_node.shape as CircleShape2D
	if circle == null:
		return
	circle = circle.duplicate() as CircleShape2D
	circle.radius = 10.0 * magnet_scale
	shape_node.shape = circle
func _on_player_died() -> void:
	_finish_run(false)

func _exit_tree() -> void:
	wave_director.stop_run()
	if is_inside_tree():
		get_tree().paused = false

func _spawn_boss() -> void:
	if run_ended or boss_spawned:
		return
	boss_spawned = true
	var boss: ForestBoss = BOSS_SCENE.instantiate()
	var spawn_position: Vector2 = Vector2(80, 80)
	for point: Vector2 in [Vector2(80, 80), Vector2(560, 80), Vector2(80, 280), Vector2(560, 280)]:
		if point.distance_squared_to($Player.position) > spawn_position.distance_squared_to($Player.position):
			spawn_position = point
	boss.position = spawn_position
	boss.boss_defeated.connect(_on_boss_defeated)
	add_child(boss)
	boss.get_node("Health").health_changed.connect(run_ui.update_boss_health)
	run_ui.update_boss_health(boss.get_node("Health").current_health, boss.get_node("Health").max_health)
func _on_boss_defeated() -> void:
	if run_ended:
		return
	# A player already at zero health cannot win a simultaneous trade.
	if ($Player/Health as CombatHealth).is_dead:
		_finish_run(false)
		return
	enemies_defeated += 1
	_finish_run(true)
	run_won.emit()

func _finish_run(won: bool) -> void:
	if run_ended:
		return
	run_ended = true
	_result_won = won
	_result_seconds = wave_director.elapsed
	_result_level = progression.level
	wave_director.stop_run()
	pending_levels.clear()
	current_choices.clear()
	$Player.movement_enabled = false
	get_tree().paused = true
	_result_saved = save_store.record_run(won, _result_seconds, _result_level)
	run_ui.show_result(won, _result_seconds, _result_level, enemies_defeated, _result_saved)
	run_finished.emit(won)

func _retry_save() -> void:
	if not run_ended or _result_saved:
		return
	_result_saved = save_store.record_run(_result_won, _result_seconds, _result_level)
	run_ui.update_save_status(_result_saved)

func _on_restart_requested() -> void:
	if not run_ended or _restart_pending:
		return
	_restart_pending = true
	_restart_scene.call_deferred()

func _restart_scene() -> void:
	get_tree().paused = false
	var error: Error = get_tree().change_scene_to_file("res://scenes/game/arena.tscn")
	if error != OK:
		_restart_pending = false
		get_tree().paused = true
		run_ui.restart_button.disabled = false
		run_ui.save_label.text = "重开失败 · 请重试"


func _on_menu_requested() -> void:
	if not run_ended or _restart_pending:
		return
	_restart_pending = true
	_open_menu.call_deferred()

func _open_menu() -> void:
	get_tree().paused = false
	var error: Error = get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
	if error != OK:
		_restart_pending = false
		get_tree().paused = true
		run_ui.save_label.text = "返回失败 · 请重试"
