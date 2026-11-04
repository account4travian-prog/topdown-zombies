class_name Game
extends Node2D

## Vertical-slice controller. Owns the run: phase clock, resources, waves, the
## arena and all spawned entities, build mode, the HUD and the pause menu, plus
## save / autosave / export / import. Deliberately compact and data-driven —
## tuning lives in Balance, per-run options in GameConfig.

const WORLD_SIZE := Vector2(1600, 1200)
const WALL_THICKNESS := 40.0
const GRID := 16.0

var config := GameConfig.new()
var ledger: ResourceLedger
var clock: PhaseClock
var waves := WaveDirector.new()

var _entities: Node2D
var _structures: Node2D
var _pickups: Node2D
var _zombies: Node2D
var _bullets: Node2D
var player: Player
var base_core: BaseCore
var _camera: Camera2D
var hud: Hud
var pause_menu: PauseMenu
var _build_ghost: Node2D
var _gameover_layer: CanvasLayer
var _phase_tint: ColorRect
var _skip_autosave_load := false

var _paused := false
var _game_over := false
var _build_mode := false
var _selected_buildable := ""
var _pickup_timer := 0.0


func _ready() -> void:
	randomize()
	_apply_cmdline_overrides()

	ledger = ResourceLedger.new(Balance.START_RESOURCES)
	clock = PhaseClock.new(config)

	_build_world()
	_build_ui()
	_wire_signals()
	_load_settings()

	if not _skip_autosave_load and SaveSystem.has_autosave():
		var res: Dictionary = SaveSystem.load_autosave()
		if int(res.get("status", -1)) == SaveSystem.ImportStatus.OK:
			_apply_snapshot(res["snapshot"])
			hud.flash_message("Continued from autosave")

	_refresh_hud_static()
	set_process(true)
	set_physics_process(true)


# --- world construction ---------------------------------------------------

func _build_world() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.11, 0.13, 0.12)
	bg.size = WORLD_SIZE
	bg.z_index = -100
	add_child(bg)
	_build_ground_art()
	_build_world_props()
	_draw_grid_overlay()

	_add_walls()

	_entities = Node2D.new()
	_entities.name = "Entities"
	add_child(_entities)

	_structures = Node2D.new()
	_structures.name = "Structures"
	_entities.add_child(_structures)
	_pickups = Node2D.new()
	_pickups.name = "Pickups"
	_entities.add_child(_pickups)
	_zombies = Node2D.new()
	_zombies.name = "Zombies"
	_entities.add_child(_zombies)
	_bullets = Node2D.new()
	_bullets.name = "Bullets"
	_entities.add_child(_bullets)

	base_core = BaseCore.new()
	base_core.position = WORLD_SIZE * 0.5
	_entities.add_child(base_core)

	player = Player.new()
	player.position = WORLD_SIZE * 0.5 + Vector2(0, 120)
	_entities.add_child(player)

	_camera = Camera2D.new()
	_camera.position_smoothing_enabled = true
	_camera.limit_left = 0
	_camera.limit_top = 0
	_camera.limit_right = int(WORLD_SIZE.x)
	_camera.limit_bottom = int(WORLD_SIZE.y)
	player.add_child(_camera)
	_camera.make_current()

	_build_ghost = _GhostPreview.new()
	_build_ghost.game = self
	_build_ghost.visible = false
	add_child(_build_ghost)

	_phase_tint = ColorRect.new()
	_phase_tint.color = Color.TRANSPARENT
	_phase_tint.size = WORLD_SIZE
	_phase_tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_phase_tint.z_index = 8
	add_child(_phase_tint)


func _build_ground_art() -> void:
	var ground := TextureRect.new()
	ground.texture = load("res://assets/third_party/craftpix/world/ground_0012_tile.png")
	ground.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	ground.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ground.stretch_mode = TextureRect.STRETCH_TILE
	ground.size = WORLD_SIZE
	ground.modulate = Color(0.56, 0.62, 0.53, 0.62)
	ground.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ground.z_index = -100
	add_child(ground)


func _build_world_props() -> void:
	var props := [
		["object_0008_house.png", Vector2(250, 230), 0.42],
		["object_0009_garage.png", Vector2(1350, 230), 0.38],
		["object_0010_car3.png", Vector2(290, 980), 0.36],
		["object_0011_car2.png", Vector2(1280, 930), 0.34],
		["object_0007_tree.png", Vector2(210, 610), 0.42],
		["object_0004_tree4.png", Vector2(1390, 610), 0.42],
	]
	for entry in props:
		var sprite := Sprite2D.new()
		sprite.texture = load("res://assets/third_party/craftpix/world/%s" % String(entry[0]))
		sprite.position = entry[1]
		sprite.scale = Vector2.ONE * float(entry[2])
		sprite.modulate = Color(0.82, 0.84, 0.79, 0.86)
		sprite.z_index = -5
		add_child(sprite)


func _draw_grid_overlay() -> void:
	var grid := _GridOverlay.new()
	grid.world_size = WORLD_SIZE
	grid.z_index = -99
	add_child(grid)


func _add_walls() -> void:
	var rects := [
		Rect2(Vector2(0, 0), Vector2(WORLD_SIZE.x, WALL_THICKNESS)),
		Rect2(Vector2(0, WORLD_SIZE.y - WALL_THICKNESS), Vector2(WORLD_SIZE.x, WALL_THICKNESS)),
		Rect2(Vector2(0, 0), Vector2(WALL_THICKNESS, WORLD_SIZE.y)),
		Rect2(Vector2(WORLD_SIZE.x - WALL_THICKNESS, 0), Vector2(WALL_THICKNESS, WORLD_SIZE.y)),
	]
	for r in rects:
		var body := StaticBody2D.new()
		body.collision_layer = Phys.bit(Phys.L_WORLD)
		body.collision_mask = 0
		body.position = (r as Rect2).position + (r as Rect2).size * 0.5
		var shape := RectangleShape2D.new()
		shape.size = (r as Rect2).size
		var col := CollisionShape2D.new()
		col.shape = shape
		body.add_child(col)
		add_child(body)


func _build_ui() -> void:
	hud = Hud.new()
	add_child(hud)
	pause_menu = PauseMenu.new()
	add_child(pause_menu)


func _wire_signals() -> void:
	ledger.changed.connect(func(t: Dictionary) -> void: hud.set_resources(t))
	clock.phase_changed.connect(_on_phase_changed)
	waves.wave_started.connect(func(w: int, total: int) -> void:
		hud.flash_message("Night %d — wave %d incoming (%d)" % [clock.day_number, w, total])
	)
	waves.wave_cleared.connect(_on_wave_cleared)

	player.fired.connect(func(pos: Vector2, dir: Vector2) -> void: _spawn_bullet(pos, dir))
	player.health_changed.connect(func(c: float, m: float) -> void: hud.set_health(c, m))
	player.died.connect(_on_player_died)

	base_core.health_changed.connect(func(c: float, m: float) -> void: hud.set_base_health(c, m))
	base_core.destroyed.connect(_on_base_destroyed)

	hud.build_requested.connect(_on_build_requested)
	hud.build_toggle_requested.connect(func() -> void: _set_build_mode(not _build_mode))
	hud.pause_requested.connect(func() -> void: _toggle_pause(not _paused))
	hud.touch_move_changed.connect(func(v: Vector2) -> void: player.touch_move = v)
	hud.touch_aim_changed.connect(func(v: Vector2) -> void: player.touch_aim = v)
	hud.touch_fire_changed.connect(func(active: bool) -> void: player.touch_firing = active)

	pause_menu.resumed.connect(_toggle_pause.bind(false))
	pause_menu.restart_requested.connect(_restart)
	pause_menu.settings_changed.connect(_on_settings_changed)
	pause_menu.debug_phase_override.connect(_on_debug_phase_override)
	pause_menu.export_requested.connect(_on_export_requested)
	pause_menu.import_requested.connect(_on_import_requested)
	pause_menu.sync_from_config(config)


# --- main loop ----------------------------------------------------------

func _process(_delta: float) -> void:
	hud.set_timer(clock.time_left_ceil())
	hud.set_wave(waves.wave, waves.zombies_alive(), waves.spawns_remaining())
	player.aim_assist = config.aim_assist


func _physics_process(delta: float) -> void:
	if _paused or _game_over:
		return

	var flipped := clock.tick(delta)
	if not flipped:
		pass

	if clock.is_day():
		_tick_day(delta)
	else:
		_tick_night(delta)


func _tick_day(delta: float) -> void:
	_pickup_timer -= delta
	if _pickup_timer <= 0.0 and _pickups.get_child_count() < Balance.PICKUP_MAX_ACTIVE:
		_pickup_timer = Balance.PICKUP_SPAWN_INTERVAL
		_spawn_pickup()


func _tick_night(delta: float) -> void:
	var to_spawn := waves.tick(delta)
	for i in to_spawn:
		_spawn_zombie()


# --- spawning ---------------------------------------------------------

func _spawn_bullet(pos: Vector2, dir: Vector2, dmg: float = Balance.BULLET_DAMAGE) -> void:
	var b := Bullet.new()
	_bullets.add_child(b)
	b.setup(pos, dir, dmg)


func _spawn_pickup() -> void:
	var kind: String = Balance.PICKUP_KINDS[randi() % Balance.PICKUP_KINDS.size()]
	var p := Pickup.new()
	p.setup(kind, int(Balance.PICKUP_AMOUNT.get(kind, 5)))
	p.position = _random_open_point(90.0)
	p.collected.connect(func(k: String, amt: int) -> void:
		ledger.add(k, amt)
		hud.flash_message("+%d %s" % [amt, k], 1.0)
	)
	_pickups.add_child(p)


func _spawn_zombie() -> void:
	var z := Zombie.new()
	z.configure(Balance.wave_zombie_stats(waves.wave))
	z.player_ref = player
	z.base_ref = base_core
	z.position = _random_edge_point()
	z.removed.connect(_on_zombie_removed)
	_zombies.add_child(z)


func _random_edge_point() -> Vector2:
	var m := WALL_THICKNESS + 30.0
	match randi() % 4:
		0: return Vector2(randf_range(m, WORLD_SIZE.x - m), m)
		1: return Vector2(randf_range(m, WORLD_SIZE.x - m), WORLD_SIZE.y - m)
		2: return Vector2(m, randf_range(m, WORLD_SIZE.y - m))
		_: return Vector2(WORLD_SIZE.x - m, randf_range(m, WORLD_SIZE.y - m))


func _random_open_point(margin: float) -> Vector2:
	for _attempt in 12:
		var p := Vector2(
			randf_range(margin, WORLD_SIZE.x - margin),
			randf_range(margin, WORLD_SIZE.y - margin)
		)
		if p.distance_to(base_core.global_position) > 120.0:
			return p
	return Vector2(margin, margin)


# --- build mode -----------------------------------------------------

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_toggle_pause(not _paused)
		return
	if _paused or _game_over:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_B:
				_set_build_mode(not _build_mode)
			KEY_1:
				_on_build_requested(Balance.BUILDABLES.keys()[0])
			KEY_2:
				if Balance.BUILDABLES.size() > 1:
					_on_build_requested(Balance.BUILDABLES.keys()[1])
			KEY_3:
				if Balance.BUILDABLES.size() > 2:
					_on_build_requested(Balance.BUILDABLES.keys()[2])
	if _build_mode and event is InputEventMouseButton and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT:
		_try_place_at(get_global_mouse_position())
		get_viewport().set_input_as_handled()
	elif _build_mode and event is InputEventScreenTouch and event.pressed:
		var screen_pos := (event as InputEventScreenTouch).position
		var world_pos := get_canvas_transform().affine_inverse() * screen_pos
		_try_place_at(world_pos)
		get_viewport().set_input_as_handled()


func _set_build_mode(active: bool) -> void:
	_build_mode = active
	hud.set_build_mode(active)
	_build_ghost.visible = active and _selected_buildable != ""
	if not active:
		_selected_buildable = ""


func _on_build_requested(bid: String) -> void:
	if not Balance.BUILDABLES.has(bid):
		return
	_selected_buildable = bid
	if not _build_mode:
		_set_build_mode(true)
	_build_ghost.visible = true
	hud.flash_message("Placing: %s" % Balance.BUILDABLES[bid].get("label", bid), 1.2)


func snap_to_grid(p: Vector2) -> Vector2:
	return Vector2(round(p.x / GRID) * GRID, round(p.y / GRID) * GRID)


func current_placements() -> Array:
	var out: Array = []
	for s in _structures.get_children():
		var sid: String = s.get("id") if s.get("id") != null else ""
		out.append(BuildSystem.Placement.new(sid, (s as Node2D).global_position))
	return out


func arena_build_bounds() -> Rect2:
	var m := WALL_THICKNESS
	return Rect2(Vector2(m, m), WORLD_SIZE - Vector2(m, m) * 2.0)


func build_keepouts() -> Array:
	return [base_core.keepout_rect()]


func validate_placement(bid: String, pos: Vector2) -> int:
	return BuildSystem.validate(
		bid, pos, current_placements(), arena_build_bounds(), build_keepouts(), ledger
	)


func _try_place_at(world_pos: Vector2) -> void:
	if _selected_buildable == "":
		return
	var pos := snap_to_grid(world_pos)
	var result := BuildSystem.try_place(
		_selected_buildable, pos, current_placements(),
		arena_build_bounds(), build_keepouts(), ledger
	)
	if result == null:
		hud.flash_message(BuildSystem.result_message(validate_placement(_selected_buildable, pos)), 1.4)
		return
	_instantiate_structure(result.id, pos)
	hud.flash_message("Built %s" % Balance.BUILDABLES[result.id].get("label", result.id), 1.2)


func _instantiate_structure(bid: String, pos: Vector2) -> void:
	var node: Node2D
	if bid == "spike_trap":
		var trap := SpikeTrap.new()
		trap.destroyed.connect(func(_s: Node) -> void: hud.flash_message("Spike trap destroyed", 1.0))
		node = trap
	else:
		var st := Structure.new()
		st.configure(bid)
		if bid == "turret":
			st.bullet_spawner = func(p: Vector2, d: Vector2, dmg: float) -> void: _spawn_bullet(p, d, dmg)
		st.destroyed.connect(func(_s: Node) -> void: hud.flash_message("Structure destroyed", 1.0))
		node = st
	node.position = pos
	_structures.add_child(node)


# --- phase / wave events -------------------------------------------

func _on_phase_changed(new_phase: int, day_number: int) -> void:
	hud.set_phase(clock.phase_name(), day_number)
	_set_night_tint(new_phase == Balance.Phase.NIGHT)
	if new_phase == Balance.Phase.NIGHT:
		_clear_group(_pickups)
		waves.begin_night()
		hud.flash_message("NIGHT falls — defend the core!", 2.5)
	else:
		waves.end_night()
		_clear_group(_zombies)
		ledger.add_bundle(Balance.NIGHT_CLEAR_REWARD)
		hud.flash_message("You survived the night. Salvage delivered.", 2.5)
	_autosave()


func _on_wave_cleared(wave: int) -> void:
	hud.flash_message("Wave %d cleared — hold until dawn" % wave, 2.0)


func _on_zombie_removed(_z: Zombie) -> void:
	waves.notify_zombie_removed()


# --- death / restart ---------------------------------------------

func _on_player_died() -> void:
	_show_game_over("You fell. The homestead is overrun.")


func _on_base_destroyed() -> void:
	_show_game_over("The base core is destroyed.")


func _show_game_over(reason: String) -> void:
	if _game_over:
		return
	_game_over = true
	get_tree().paused = false
	_gameover_layer = CanvasLayer.new()
	_gameover_layer.layer = 30
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.7)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_gameover_layer.add_child(dim)
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.position = Vector2(-160, -60)
	box.custom_minimum_size = Vector2(320, 0)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	_gameover_layer.add_child(box)
	var l := Label.new()
	l.text = "%s\nReached Day %d, Wave %d." % [reason, clock.day_number, waves.wave]
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 20)
	box.add_child(l)
	var b := Button.new()
	b.text = "Restart"
	b.pressed.connect(_restart)
	box.add_child(b)
	add_child(_gameover_layer)


func _restart() -> void:
	DirAccess.remove_absolute(Balance.SAVE_PATH)
	get_tree().paused = false
	get_tree().reload_current_scene()


# --- pause / settings -------------------------------------------

func _toggle_pause(state: bool) -> void:
	if _game_over:
		return
	_paused = state
	get_tree().paused = state
	if state:
		pause_menu.sync_from_config(config)
		pause_menu.open()
	else:
		pause_menu.close()


func _on_settings_changed(settings: Dictionary) -> void:
	config.apply_settings_dict(settings)
	_apply_audio_config()
	_save_settings()


func _on_debug_phase_override(day_seconds: float, night_seconds: float) -> void:
	config.set_debug_phase_durations(day_seconds, night_seconds)
	# Rebuild the clock so the new durations take effect from the current phase.
	var snap := clock.to_dict()
	clock = PhaseClock.new(config)
	clock.apply_dict(snap)
	clock.phase_changed.connect(_on_phase_changed)
	hud.flash_message("Debug: day %ds / night %ds" % [int(day_seconds), int(night_seconds)])


func _apply_audio_config() -> void:
	var master_idx := AudioServer.get_bus_index("Master")
	if master_idx >= 0:
		AudioServer.set_bus_volume_db(master_idx, linear_to_db(maxf(config.master_volume, 0.0001)))


# --- save / load ----------------------------------------------

func build_snapshot() -> Dictionary:
	var structs: Array = []
	for s in _structures.get_children():
		var sid: String = s.get("id") if s.get("id") != null else ""
		structs.append({
			"id": sid,
			"x": (s as Node2D).global_position.x,
			"y": (s as Node2D).global_position.y,
			"health": float(s.get("health")) if s.get("health") != null else 0.0,
		})
	return {
		"clock": clock.to_dict(),
		"resources": ledger.to_dict(),
		"waves": waves.to_dict(),
		"player_health": player.health,
		"base_health": base_core.health,
		"structures": structs,
		"day_seconds": config.day_seconds,
		"night_seconds": config.night_seconds,
		"debug_overrides": config.debug_overrides_enabled,
	}


func _apply_snapshot(snap: Dictionary) -> void:
	if snap.has("debug_overrides") and bool(snap["debug_overrides"]):
		config.set_debug_phase_durations(
			float(snap.get("day_seconds", Balance.DAY_SECONDS)),
			float(snap.get("night_seconds", Balance.NIGHT_SECONDS))
		)
	clock = PhaseClock.new(config)
	clock.apply_dict(snap.get("clock", {}))
	clock.phase_changed.connect(_on_phase_changed)
	ledger.apply_dict(snap.get("resources", {}))
	waves.apply_dict(snap.get("waves", {}))
	player.health = float(snap.get("player_health", player.max_health))
	player.health_changed.emit(player.health, player.max_health)
	base_core.health = float(snap.get("base_health", base_core.max_health))
	base_core.health_changed.emit(base_core.health, base_core.max_health)

	_clear_group(_structures)
	for entry in snap.get("structures", []):
		var e: Dictionary = entry
		_instantiate_structure(String(e.get("id", "")), Vector2(float(e.get("x", 0)), float(e.get("y", 0))))
	hud.set_phase(clock.phase_name(), clock.day_number)
	_set_night_tint(clock.is_night())


func _set_night_tint(is_night: bool) -> void:
	if _phase_tint == null:
		return
	var target := Color(0.03, 0.07, 0.18, 0.43) if is_night else Color.TRANSPARENT
	var tween := create_tween()
	tween.tween_property(_phase_tint, "color", target, 0.7)


func _autosave() -> void:
	SaveSystem.autosave(build_snapshot())


func _on_export_requested(path: String) -> void:
	var ok := SaveSystem.export_to_path(build_snapshot(), path)
	pause_menu.report_io("Exported to %s" % path if ok else "Export failed")


func _on_import_requested(path: String) -> void:
	var res: Dictionary = SaveSystem.import_from_path(path)
	if int(res.get("status", -1)) == SaveSystem.ImportStatus.OK:
		_apply_snapshot(res["snapshot"])
		pause_menu.report_io("Imported %s" % path)
		hud.flash_message("Save imported")
	else:
		pause_menu.report_io(SaveSystem.status_message(int(res.get("status", -1))))


func _save_settings() -> void:
	var f := FileAccess.open(Balance.SETTINGS_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(config.settings_to_dict(), "\t"))
		f.close()


func _load_settings() -> void:
	if not FileAccess.file_exists(Balance.SETTINGS_PATH):
		return
	var f := FileAccess.open(Balance.SETTINGS_PATH, FileAccess.READ)
	if f == null:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(parsed) == TYPE_DICTIONARY:
		config.apply_settings_dict(parsed)
		_apply_audio_config()
		pause_menu.sync_from_config(config)


# --- helpers ------------------------------------------------------

func _clear_group(parent: Node) -> void:
	for c in parent.get_children():
		c.queue_free()


func _refresh_hud_static() -> void:
	hud.set_phase(clock.phase_name(), clock.day_number)
	hud.set_resources(ledger.to_dict())
	hud.set_health(player.health, player.max_health)
	hud.set_base_health(base_core.health, base_core.max_health)
	hud.set_wave(waves.wave, 0, 0)


func _apply_cmdline_overrides() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg == "--fresh":
			_skip_autosave_load = true
		elif arg.begins_with("--day="):
			config.set_debug_phase_durations(float(arg.trim_prefix("--day=")), config.night_seconds)
		elif arg.begins_with("--night="):
			config.set_debug_phase_durations(config.day_seconds, float(arg.trim_prefix("--night=")))


# --- inner helper nodes ----------------------------------------

class _GridOverlay:
	extends Node2D
	var world_size: Vector2 = Vector2(1600, 1200)
	func _draw() -> void:
		var step := 64.0
		var c := Color(1, 1, 1, 0.04)
		var x := 0.0
		while x <= world_size.x:
			draw_line(Vector2(x, 0), Vector2(x, world_size.y), c, 1.0)
			x += step
		var y := 0.0
		while y <= world_size.y:
			draw_line(Vector2(0, y), Vector2(world_size.x, y), c, 1.0)
			y += step


class _GhostPreview:
	extends Node2D
	var game: Game
	func _process(_delta: float) -> void:
		queue_redraw()
	func _draw() -> void:
		if game == null or game._selected_buildable == "":
			return
		var bid: String = game._selected_buildable
		var def: Dictionary = Balance.BUILDABLES.get(bid, {})
		var size: Vector2 = def.get("size", Vector2(40, 40))
		var pos := game.snap_to_grid(get_global_mouse_position())
		var ok := game.validate_placement(bid, pos) == BuildSystem.Result.OK
		var col := Color(0.3, 0.9, 0.4, 0.4) if ok else Color(0.9, 0.3, 0.3, 0.4)
		draw_set_transform(pos - global_position, 0.0, Vector2.ONE)
		draw_rect(Rect2(-size * 0.5, size), col)
		draw_rect(Rect2(-size * 0.5, size), Color(col.r, col.g, col.b, 0.9), false, 2.0)
