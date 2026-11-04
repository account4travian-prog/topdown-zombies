class_name Pickup
extends Area2D

## A resource node that appears around the map during DAY. Walking the player
## over it banks the resources.

signal collected(kind: String, amount: int)

const RADIUS: float = 11.0

var kind: String = "scrap"
var amount: int = 8
var _bob: float = 0.0


func setup(p_kind: String, p_amount: int) -> void:
	kind = p_kind
	amount = p_amount


func _ready() -> void:
	add_to_group(Phys.GROUP_PICKUP)
	collision_layer = Phys.bit(Phys.L_PICKUP)
	collision_mask = Phys.bit(Phys.L_PLAYER)
	var shape := CircleShape2D.new()
	shape.radius = RADIUS + 4.0
	var col := CollisionShape2D.new()
	col.shape = shape
	add_child(col)
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_bob += delta * 3.0
	queue_redraw()


func _on_body_entered(body: Node) -> void:
	if body.is_in_group(Phys.GROUP_PLAYER):
		collected.emit(kind, amount)
		queue_free()


func _colour() -> Color:
	match kind:
		"wood": return Color(0.55, 0.38, 0.2)
		"parts": return Color(0.5, 0.6, 0.75)
		_: return Color(0.75, 0.7, 0.35)


func _draw() -> void:
	var r := RADIUS + sin(_bob) * 1.5
	var pts := PackedVector2Array([
		Vector2(0, -r), Vector2(r, 0), Vector2(0, r), Vector2(-r, 0)
	])
	draw_colored_polygon(pts, _colour())
	draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[3], pts[0]]), Color(0.1, 0.1, 0.1), 1.5)
