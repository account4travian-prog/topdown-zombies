class_name SpikeTrap
extends Area2D

## Non-blocking buildable. Zombies walk over it and take periodic contact
## damage; each pulse also wears the trap down until it breaks.

signal destroyed(structure: SpikeTrap)

var id: String = "spike_trap"
var def: Dictionary = Balance.BUILDABLES["spike_trap"]
var max_health: float = float(Balance.BUILDABLES["spike_trap"]["health"])
var health: float = float(Balance.BUILDABLES["spike_trap"]["health"])
var hit_radius: float = 22.0

var _pulse_timer: float = 0.0


func configure(_p_id: String = "spike_trap") -> void:
	# Present for API symmetry with Structure; spike traps have a single form.
	pass


func _ready() -> void:
	add_to_group(Phys.GROUP_ATTACKABLE)
	add_to_group(Phys.GROUP_STRUCTURE)
	collision_layer = Phys.bit(Phys.L_TRAP)
	collision_mask = Phys.bit(Phys.L_ZOMBIE)
	monitoring = true
	var s: Vector2 = def.get("size", Vector2(44, 44))
	hit_radius = maxf(s.x, s.y) * 0.5
	var shape := RectangleShape2D.new()
	shape.size = s
	var col := CollisionShape2D.new()
	col.shape = shape
	add_child(col)


func _physics_process(delta: float) -> void:
	_pulse_timer -= delta
	if _pulse_timer > 0.0:
		return
	var bodies := get_overlapping_bodies()
	var hit_any := false
	for b in bodies:
		if b.is_in_group(Phys.GROUP_ZOMBIE) and b.has_method("take_damage"):
			b.take_damage(float(def.get("contact_damage", 18.0)))
			hit_any = true
	if hit_any:
		_pulse_timer = float(def.get("contact_interval", 0.5))
		take_damage(4.0)
		queue_redraw()


func take_damage(amount: float) -> void:
	health -= amount
	if health <= 0.0:
		destroyed.emit(self)
		queue_free()


func _draw() -> void:
	var s: Vector2 = def.get("size", Vector2(44, 44))
	var frac := 0.0 if max_health <= 0.0 else clampf(health / max_health, 0.0, 1.0)
	draw_rect(Rect2(-s * 0.5, s), Color(0.28, 0.28, 0.3).lerp(Color(0.2, 0.1, 0.1), 1.0 - frac))
	var n := 3
	for i in n:
		for j in n:
			var c := Vector2(
				-s.x * 0.5 + s.x * (i + 0.5) / n,
				-s.y * 0.5 + s.y * (j + 0.5) / n
			)
			var t := 5.0
			draw_colored_polygon(PackedVector2Array([
				c + Vector2(0, -t), c + Vector2(t, t), c + Vector2(-t, t)
			]), Color(0.75, 0.75, 0.8))
	draw_rect(Rect2(-s * 0.5, s), Color(0.12, 0.12, 0.14), false, 2.0)
