class_name BaseCore
extends StaticBody2D

## The homestead's heart. If zombies destroy it, the run is over.

signal health_changed(current: float, maximum: float)
signal destroyed

const HALF: float = 34.0

var max_health: float = Balance.BASE_CORE_MAX_HEALTH
var health: float = Balance.BASE_CORE_MAX_HEALTH
var hit_radius: float = HALF
var alive: bool = true


func _ready() -> void:
	add_to_group(Phys.GROUP_ATTACKABLE)
	add_to_group(Phys.GROUP_STRUCTURE)
	collision_layer = Phys.bit(Phys.L_STRUCTURE)
	collision_mask = 0
	var shape := RectangleShape2D.new()
	shape.size = Vector2(HALF * 2.0, HALF * 2.0)
	var col := CollisionShape2D.new()
	col.shape = shape
	add_child(col)


func take_damage(amount: float) -> void:
	if not alive:
		return
	health = maxf(0.0, health - amount)
	health_changed.emit(health, max_health)
	queue_redraw()
	if health <= 0.0:
		alive = false
		destroyed.emit()


func reset() -> void:
	health = max_health
	alive = true
	health_changed.emit(health, max_health)
	queue_redraw()


func keepout_rect() -> Rect2:
	# A generous no-build ring around the core.
	var pad := 46.0
	return Rect2(global_position - Vector2(HALF + pad, HALF + pad), Vector2(HALF + pad, HALF + pad) * 2.0)


func _draw() -> void:
	var frac := 0.0 if max_health <= 0.0 else clampf(health / max_health, 0.0, 1.0)
	var col := Color(0.3, 0.55, 0.9).lerp(Color(0.6, 0.2, 0.2), 1.0 - frac)
	draw_rect(Rect2(-Vector2(HALF, HALF), Vector2(HALF, HALF) * 2.0), col)
	draw_rect(Rect2(-Vector2(HALF, HALF), Vector2(HALF, HALF) * 2.0), Color(0.1, 0.15, 0.25), false, 3.0)
	draw_line(Vector2(-HALF, 0), Vector2(HALF, 0), Color(0.1, 0.15, 0.25), 2.0)
	draw_line(Vector2(0, -HALF), Vector2(0, HALF), Color(0.1, 0.15, 0.25), 2.0)
	# Health bar above the core.
	var w := HALF * 2.0
	draw_rect(Rect2(Vector2(-HALF, -HALF - 12.0), Vector2(w, 5.0)), Color(0.15, 0.15, 0.15))
	draw_rect(Rect2(Vector2(-HALF, -HALF - 12.0), Vector2(w * frac, 5.0)), Color(0.3, 0.8, 0.4))
