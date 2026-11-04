class_name Player
extends CharacterBody2D

## Top-down twin-stick style avatar. Keyboard + mouse on desktop, virtual
## sticks on touch. All collision shapes are built in code so no .tscn is
## required for the entity.

signal died
signal health_changed(current: float, maximum: float)
signal fired(from_pos: Vector2, direction: Vector2)

const RADIUS: float = 16.0

var max_health: float = Balance.PLAYER_MAX_HEALTH
var health: float = Balance.PLAYER_MAX_HEALTH
var speed: float = Balance.PLAYER_SPEED
var alive: bool = true

## Aim assist strength, mirrored from GameConfig each frame by the game.
var aim_assist: float = 0.0

## Movement / aim intents supplied by touch controls (0,0 when unused).
var touch_move: Vector2 = Vector2.ZERO
var touch_aim: Vector2 = Vector2.ZERO
var touch_firing: bool = false

var _aim_dir: Vector2 = Vector2.RIGHT
var _fire_cooldown: float = 0.0
var _use_touch_aim: bool = false
var _sprite: AnimatedSprite2D
var _shoot_anim_time: float = 0.0


func _ready() -> void:
	add_to_group(Phys.GROUP_PLAYER)
	add_to_group(Phys.GROUP_ATTACKABLE)
	collision_layer = Phys.bit(Phys.L_PLAYER)
	collision_mask = Phys.mask([Phys.L_WORLD, Phys.L_STRUCTURE])
	var shape := CircleShape2D.new()
	shape.radius = RADIUS
	var col := CollisionShape2D.new()
	col.shape = shape
	add_child(col)
	_build_sprite()


func _physics_process(delta: float) -> void:
	if not alive:
		return
	_fire_cooldown = maxf(0.0, _fire_cooldown - delta)
	_shoot_anim_time = maxf(0.0, _shoot_anim_time - delta)

	var move := _read_move_input()
	velocity = move * speed
	move_and_slide()

	_update_aim()
	_update_sprite(move)

	if _read_fire_input() and _fire_cooldown <= 0.0:
		_shoot()

	queue_redraw()


func _read_move_input() -> Vector2:
	if touch_move.length() > 0.05:
		return touch_move.limit_length(1.0)
	var v := Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)
	# Raw WASD as well as the ui_* arrow actions.
	if Input.is_physical_key_pressed(KEY_A): v.x -= 1.0
	if Input.is_physical_key_pressed(KEY_D): v.x += 1.0
	if Input.is_physical_key_pressed(KEY_W): v.y -= 1.0
	if Input.is_physical_key_pressed(KEY_S): v.y += 1.0
	return v.limit_length(1.0)


func _read_fire_input() -> bool:
	if touch_firing:
		return true
	return Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_physical_key_pressed(KEY_SPACE)


func _update_aim() -> void:
	var desired := _aim_dir
	if touch_aim.length() > 0.15:
		desired = touch_aim.normalized()
		_use_touch_aim = true
	else:
		if _use_touch_aim and touch_aim.length() <= 0.15:
			_use_touch_aim = false
		var to_mouse := get_global_mouse_position() - global_position
		if to_mouse.length() > 1.0:
			desired = to_mouse.normalized()

	desired = _apply_aim_assist(desired)
	_aim_dir = desired.normalized()


## Rotates the aim vector toward the nearest zombie by up to `aim_assist` of the
## angular gap, so a light nudge helps without fully auto-aiming.
func _apply_aim_assist(dir: Vector2) -> Vector2:
	if aim_assist <= 0.001:
		return dir
	var nearest: Node2D = null
	var best := INF
	for z in get_tree().get_nodes_in_group(Phys.GROUP_ZOMBIE):
		var zn := z as Node2D
		if zn == null:
			continue
		var d := global_position.distance_to(zn.global_position)
		if d < best:
			best = d
			nearest = zn
	if nearest == null or best > 420.0:
		return dir
	var target_dir := (nearest.global_position - global_position).normalized()
	return dir.slerp(target_dir, clampf(aim_assist, 0.0, 1.0)).normalized()


func _shoot() -> void:
	_fire_cooldown = Balance.PLAYER_FIRE_COOLDOWN
	_shoot_anim_time = 0.16
	if _sprite != null:
		_sprite.play("shoot")
	var muzzle := global_position + _aim_dir * (RADIUS + 6.0)
	fired.emit(muzzle, _aim_dir)


func _build_sprite() -> void:
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	_add_animation(frames, "idle", "res://assets/third_party/craftpix/player/idle/Idle_gun_%03d.png", 8, 8.0, true)
	_add_animation(frames, "walk", "res://assets/third_party/craftpix/player/walk/Walk_gun_%03d.png", 6, 11.0, true)
	_add_animation(frames, "shoot", "res://assets/third_party/craftpix/player/shoot/Gun_Shot_%03d.png", 5, 18.0, false)
	_sprite = AnimatedSprite2D.new()
	_sprite.sprite_frames = frames
	_sprite.scale = Vector2.ONE * 0.46
	_sprite.z_index = 2
	add_child(_sprite)
	_sprite.play("idle")


func _add_animation(frames: SpriteFrames, name: String, pattern: String, count: int, fps: float, loop: bool) -> void:
	frames.add_animation(name)
	frames.set_animation_speed(name, fps)
	frames.set_animation_loop(name, loop)
	for i in count:
		var texture := load(pattern % i) as Texture2D
		if texture != null:
			frames.add_frame(name, texture)


func _update_sprite(move: Vector2) -> void:
	if _sprite == null:
		return
	_sprite.rotation = _aim_dir.angle() + PI * 0.5
	if _shoot_anim_time > 0.0:
		return
	var desired := "walk" if move.length() > 0.05 else "idle"
	if _sprite.animation != desired:
		_sprite.play(desired)


func take_damage(amount: float) -> void:
	if not alive:
		return
	health = maxf(0.0, health - amount)
	health_changed.emit(health, max_health)
	queue_redraw()
	if health <= 0.0:
		alive = false
		died.emit()


func heal_full() -> void:
	health = max_health
	alive = true
	health_changed.emit(health, max_health)
	queue_redraw()


func aim_direction() -> Vector2:
	return _aim_dir


func _draw() -> void:
	# A soft footprint remains readable beneath the licensed sprite.
	draw_ellipse_shadow()
	# Health pip ring.
	var frac := 0.0 if max_health <= 0.0 else health / max_health
	draw_arc(Vector2.ZERO, RADIUS + 5.0, -PI / 2.0, -PI / 2.0 + TAU * frac, 24, Color(0.9, 0.85, 0.2), 2.0)


func draw_ellipse_shadow() -> void:
	draw_set_transform(Vector2(0, 8), 0.0, Vector2(1.5, 0.55))
	draw_circle(Vector2.ZERO, RADIUS, Color(0, 0, 0, 0.28))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
