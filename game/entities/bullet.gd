class_name Bullet
extends Area2D

## Straight-line projectile fired by the player and by auto-turrets. Damages the
## first zombie it overlaps, then despawns. Also despawns on lifetime timeout.

var velocity: Vector2 = Vector2.ZERO
var damage: float = Balance.BULLET_DAMAGE
var life: float = Balance.BULLET_LIFETIME


func setup(from_pos: Vector2, direction: Vector2, dmg: float = Balance.BULLET_DAMAGE, spd: float = Balance.BULLET_SPEED) -> void:
	global_position = from_pos
	velocity = direction.normalized() * spd
	damage = dmg


func _ready() -> void:
	collision_layer = Phys.bit(Phys.L_BULLET)
	collision_mask = Phys.bit(Phys.L_ZOMBIE)
	monitoring = true
	var shape := CircleShape2D.new()
	shape.radius = 4.0
	var col := CollisionShape2D.new()
	col.shape = shape
	add_child(col)
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	global_position += velocity * delta
	life -= delta
	if life <= 0.0:
		queue_free()


func _on_body_entered(body: Node) -> void:
	if body.is_in_group(Phys.GROUP_ZOMBIE) and body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()


func _draw() -> void:
	draw_circle(Vector2.ZERO, 4.0, Color(1.0, 0.9, 0.4))
	draw_circle(Vector2.ZERO, 2.0, Color(1.0, 1.0, 0.9))
