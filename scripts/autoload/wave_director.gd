extends Node
signal time_changed(elapsed: float)
signal boss_due
signal enemy_spawned(enemy: Node2D)
const ENEMY_SCENE: PackedScene = preload("res://scenes/enemies/enemy.tscn")
@export_range(1.0, 3600.0, 1.0) var run_duration: float = 1800.0
@export_range(1, 500) var enemy_cap: int = 60
@export var arena_bounds: Rect2 = Rect2(24, 24, 592, 306)
var elapsed: float = 0.0
var active: bool = false
var _arena: Node2D
var _spawn_cooldown: float = 0.0
var _last_second: int = -1
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
func _ready() -> void:
	_rng.randomize()
func start_run(arena: Node2D) -> void:
	_arena = arena
	elapsed = 0.0
	_spawn_cooldown = 1.0
	_last_second = -1
	active = true
	time_changed.emit(elapsed)
func stop_run() -> void:
	active = false
	_arena = null
func _physics_process(delta: float) -> void:
	if not active or not is_instance_valid(_arena):
		return
	elapsed = minf(elapsed + delta, run_duration)
	if int(elapsed) != _last_second:
		_last_second = int(elapsed)
		time_changed.emit(elapsed)
	if elapsed >= run_duration:
		active = false
		boss_due.emit()
		return
	_spawn_cooldown -= delta
	if _spawn_cooldown > 0.0:
		return
	_spawn_cooldown = maxf(2.0 - elapsed / 240.0, 0.4)
	for index: int in range(mini(1 + int(elapsed / 180.0), 6)):
		spawn_enemy()
func spawn_enemy() -> Node2D:
	if not is_instance_valid(_arena) or get_tree().get_nodes_in_group("enemy").size() >= enemy_cap:
		return null
	var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return null
	for attempt: int in range(24):
		var point: Vector2 = arena_bounds.position
		if _rng.randi_range(0, 1) == 0:
			point.x += _rng.randf_range(0.0, arena_bounds.size.x)
			point.y += 0.0 if _rng.randi_range(0, 1) == 0 else arena_bounds.size.y
		else:
			point.x += 0.0 if _rng.randi_range(0, 1) == 0 else arena_bounds.size.x
			point.y += _rng.randf_range(0.0, arena_bounds.size.y)
		var world_point: Vector2 = _arena.to_global(point)
		if player.global_position.distance_to(world_point) < 110.0:
			continue
		var query: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
		var circle: CircleShape2D = CircleShape2D.new()
		circle.radius = 8.0
		query.shape = circle
		query.transform = Transform2D(0.0, world_point + Vector2(0, 6))
		query.collision_mask = 1
		if not _arena.get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty():
			continue
		var enemy: WoodcallerEnemy = ENEMY_SCENE.instantiate()
		enemy.position = point
		enemy.move_speed = minf(65.0 + elapsed / 60.0, 105.0)
		(enemy.get_node("Health") as CombatHealth).max_health = 30.0 * (1.0 + elapsed / 300.0)
		_arena.add_child(enemy)
		enemy_spawned.emit(enemy)
		return enemy
	return null
