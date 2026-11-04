class_name Zombie
extends CharacterBody2D

## Simple pursuer. Navigates straight toward whichever of the player or the base
## core is the more urgent target, and chews through any attackable it bumps
## into on the way (barricades, traps, turrets, the core, the player).

signal removed(zombie: Zombie)

const RADIUS: float = 13.0
const PLAYER_AGGRO_RANGE: float = 230.0

var max_health: float = Balance.ZOMBIE_BASE_HEALTH
var health: float = Balance.ZOMBIE_BASE_HEALTH
var speed: float = Balance.ZOMBIE_BASE_SPEED
var damage: float = Balance.ZOMBIE_BASE_DAMAGE
var alive: bool = true

var player_ref: Node2D
var base_ref: Node2D

var _attack_timer: float = 0.0
var _hit_flash: float = 0.0
var _sprite: AnimatedSprite2D
var _attacking: bool = false
var _variant: String = "zombie1_female"


func configure(stats: Dictionary) -> void:
	max_health = float(stats.get("health", max_health))
	health = max_health
	speed = float(stats.get("speed", speed))
	damage = float(stats.get("damage", damage))


func _ready() -> void:
	add_to_group(Phys.GROUP_ZOMBIE)
	add_to_group(Phys.GROUP_ATTACKABLE)
	collision_layer = Phys.bit(Phys.L_ZOMBIE)
	collision_mask = Phys.mask([Phys.L_WORLD, Phys.L_STRUCTURE, Phys.L_ZOMBIE])
	var shape := CircleShape2D.new()
	shape.radius = RADIUS
	var col := CollisionShape2D.new()
	col.shape = shape
	add_child(col)
	_variant = ["zombie1_female", "zombie2_female", "zombie3_male"][randi() % 3]
	_build_sprite()


func _physics_process(delta: float) -> void:
	if not alive:
		return
	_attack_timer = maxf(0.0, _attack_timer - delta)
	_hit_flash = maxf(0.0, _hit_flash - delta)

	var target := _resolve_move_target()
	var attackable := _find_attackable_in_reach()

	if attackable != null:
		_attacking = true
		velocity = Vector2.ZERO
		if _attack_timer <= 0.0:
			_attack_timer = Balance.ZOMBIE_ATTACK_INTERVAL
			if attackable.has_method("take_damage"):
				attackable.take_damage(damage)
	elif target != null:
		_attacking = false
		var dir := (target.global_position - global_position)
		if dir.length() > 1.0:
			velocity = dir.normalized() * speed
		else:
			velocity = Vector2.ZERO
		move_and_slide()

	_update_sprite()

	queue_redraw()


func _resolve_move_target() -> Node2D:
	var p := player_ref if is_instance_valid(player_ref) and (player_ref as Player).alive else null
	if p != null and global_position.distance_to(p.global_position) <= PLAYER_AGGRO_RANGE:
		return p
	if is_instance_valid(base_ref):
		return base_ref
	return p


## Nearest node in the "attackable" group whose surface is within touch range.
func _find_attackable_in_reach() -> Node:
	var best: Node = null
	var best_d := INF
	for n in get_tree().get_nodes_in_group(Phys.GROUP_ATTACKABLE):
		if n == self:
			continue
		var n2d := n as Node2D
		if n2d == null:
			continue
		if n.is_in_group(Phys.GROUP_ZOMBIE):
			continue
		var other_radius: float = n.get("hit_radius") if n.get("hit_radius") != null else 20.0
		var d := global_position.distance_to(n2d.global_position)
		if d <= Balance.ZOMBIE_TOUCH_RADIUS + float(other_radius) and d < best_d:
			best_d = d
			best = n
	return best


func take_damage(amount: float) -> void:
	if not alive:
		return
	health -= amount
	_hit_flash = 0.12
	if health <= 0.0:
		die()
	else:
		queue_redraw()


func die() -> void:
	if not alive:
		return
	alive = false
	removed.emit(self)
	collision_layer = 0
	collision_mask = 0
	if _sprite != null and _sprite.sprite_frames.has_animation("death"):
		_sprite.play("death")
		await _sprite.animation_finished
	queue_free()


func _build_sprite() -> void:
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	var walk_name := "walk" if _variant == "zombie3_male" else "Walk"
	_add_animation(frames, "walk", "res://assets/third_party/craftpix/zombies/%s/walk/%s_%%03d.png" % [_variant, walk_name], 9, 9.0, true)
	_add_animation(frames, "attack", "res://assets/third_party/craftpix/zombies/%s/attack/Attack_%%03d.png" % _variant, 9, 12.0, true)
	_add_animation(frames, "death", "res://assets/third_party/craftpix/zombies/%s/death/Death_%%03d.png" % _variant, 6, 12.0, false)
	_sprite = AnimatedSprite2D.new()
	_sprite.sprite_frames = frames
	_sprite.scale = Vector2.ONE * 0.44
	_sprite.z_index = 2
	add_child(_sprite)
	_sprite.play("walk")


func _add_animation(frames: SpriteFrames, name: String, pattern: String, count: int, fps: float, loop: bool) -> void:
	frames.add_animation(name)
	frames.set_animation_speed(name, fps)
	frames.set_animation_loop(name, loop)
	for i in count:
		var texture := load(pattern % i) as Texture2D
		if texture != null:
			frames.add_frame(name, texture)


func _update_sprite() -> void:
	if _sprite == null or not alive:
		return
	if velocity.length() > 0.1:
		_sprite.rotation = velocity.angle() + PI * 0.5
	var wanted := "attack" if _attacking else "walk"
	if _sprite.animation != wanted:
		_sprite.play(wanted)
	_sprite.modulate = Color(1.0, 0.75, 0.75) if _hit_flash > 0.0 else Color.WHITE


func _draw() -> void:
	draw_set_transform(Vector2(0, 7), 0.0, Vector2(1.4, 0.5))
	draw_circle(Vector2.ZERO, RADIUS, Color(0, 0, 0, 0.25))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var frac := 0.0 if max_health <= 0.0 else clampf(health / max_health, 0.0, 1.0)
	if frac < 1.0:
		draw_line(Vector2(-RADIUS, -RADIUS - 4.0), Vector2(-RADIUS + 2.0 * RADIUS * frac, -RADIUS - 4.0), Color(0.9, 0.2, 0.2), 2.0)
