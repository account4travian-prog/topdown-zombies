class_name Structure
extends StaticBody2D

## Movement-blocking buildable: barricade or auto-turret. Behaviour is chosen by
## `id` (a key in Balance.BUILDABLES) so adding a new blocking structure is a
## data change plus, at most, a small branch here.

signal destroyed(structure: Structure)

var id: String = "barricade"
var def: Dictionary = {}
var max_health: float = 100.0
var health: float = 100.0
var hit_radius: float = 24.0

var _fire_timer: float = 0.0
var _muzzle_flash: float = 0.0
var bullet_spawner: Callable = Callable()


func configure(p_id: String) -> void:
	id = p_id
	def = Balance.BUILDABLES.get(p_id, {})
	max_health = float(def.get("health", 100.0))
	health = max_health
	var s: Vector2 = def.get("size", Vector2(40, 40))
	hit_radius = maxf(s.x, s.y) * 0.5


func _ready() -> void:
	if def.is_empty():
		configure(id)
	add_to_group(Phys.GROUP_ATTACKABLE)
	add_to_group(Phys.GROUP_STRUCTURE)
	collision_layer = Phys.bit(Phys.L_STRUCTURE)
	collision_mask = 0
	var shape := RectangleShape2D.new()
	shape.size = def.get("size", Vector2(40, 40))
	var col := CollisionShape2D.new()
	col.shape = shape
	add_child(col)
	set_physics_process(id == "turret")


func _physics_process(delta: float) -> void:
	if id != "turret":
		return
	_fire_timer = maxf(0.0, _fire_timer - delta)
	_muzzle_flash = maxf(0.0, _muzzle_flash - delta)
	if _fire_timer <= 0.0:
		var target := _nearest_zombie_in_range()
		if target != null and bullet_spawner.is_valid():
			var dir := (target.global_position - global_position).normalized()
			bullet_spawner.call(global_position + dir * (hit_radius + 4.0), dir, float(def.get("damage", 16.0)))
			_fire_timer = float(def.get("fire_interval", 0.7))
			_muzzle_flash = 0.06
	queue_redraw()


func _nearest_zombie_in_range() -> Node2D:
	var range_sq: float = pow(float(def.get("range", 240.0)), 2.0)
	var best: Node2D = null
	var best_d := INF
	for z in get_tree().get_nodes_in_group(Phys.GROUP_ZOMBIE):
		var zn := z as Node2D
		if zn == null:
			continue
		var d := global_position.distance_squared_to(zn.global_position)
		if d <= range_sq and d < best_d:
			best_d = d
			best = zn
	return best


func take_damage(amount: float) -> void:
	health -= amount
	queue_redraw()
	if health <= 0.0:
		destroyed.emit(self)
		queue_free()


func _draw() -> void:
	var s: Vector2 = def.get("size", Vector2(40, 40))
	var frac := 0.0 if max_health <= 0.0 else clampf(health / max_health, 0.0, 1.0)
	if id == "turret":
		draw_circle(Vector2.ZERO, s.x * 0.5, Color(0.35, 0.4, 0.5))
		draw_arc(Vector2.ZERO, s.x * 0.5, 0.0, TAU, 20, Color(0.15, 0.18, 0.22), 2.0)
		var barrel := Color(0.9, 0.8, 0.3) if _muzzle_flash > 0.0 else Color(0.15, 0.15, 0.15)
		draw_line(Vector2.ZERO, Vector2(s.x * 0.5 + 8.0, 0), barrel, 4.0)
	else:
		var col := Color(0.5, 0.36, 0.2).lerp(Color(0.35, 0.2, 0.15), 1.0 - frac)
		draw_rect(Rect2(-s * 0.5, s), col)
		draw_rect(Rect2(-s * 0.5, s), Color(0.2, 0.13, 0.08), false, 3.0)
		draw_line(Vector2(-s.x * 0.5, 0), Vector2(s.x * 0.5, 0), Color(0.2, 0.13, 0.08), 2.0)
	if frac < 1.0:
		draw_rect(Rect2(Vector2(-s.x * 0.5, -s.y * 0.5 - 8.0), Vector2(s.x, 4.0)), Color(0.15, 0.15, 0.15))
		draw_rect(Rect2(Vector2(-s.x * 0.5, -s.y * 0.5 - 8.0), Vector2(s.x * frac, 4.0)), Color(0.3, 0.8, 0.4))
