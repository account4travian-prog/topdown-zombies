class_name Hud
extends CanvasLayer

## Heads-up display: phase + countdown, resource stockpile, player health, base
## health, wave number, a build hotbar and a transient message line. Built
## entirely in code so it needs no .tscn.

signal build_requested(buildable_id: String)
signal build_cancel_requested
signal build_toggle_requested
signal pause_requested
signal touch_move_changed(direction: Vector2)
signal touch_aim_changed(direction: Vector2)
signal touch_fire_changed(active: bool)

var _phase_label: Label
var _timer_label: Label
var _wave_label: Label
var _resource_label: Label
var _health_bar: ProgressBar
var _base_bar: ProgressBar
var _message_label: Label
var _hotbar: HBoxContainer
var _message_time: float = 0.0
var _hotbar_buttons: Dictionary = {}
var _touch_enabled := false


func _ready() -> void:
	layer = 10
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	var top := VBoxContainer.new()
	top.position = Vector2(12, 10)
	top.add_theme_constant_override("separation", 2)
	root.add_child(top)

	_phase_label = _mk_label(top, "DAY", 26)
	_timer_label = _mk_label(top, "05:00", 20)
	_wave_label = _mk_label(top, "Wave 0", 16)
	_resource_label = _mk_label(top, "scrap 0   wood 0   parts 0", 16)

	var bars := VBoxContainer.new()
	bars.position = Vector2(12, 130)
	bars.custom_minimum_size = Vector2(220, 0)
	root.add_child(bars)
	_mk_label(bars, "Health", 12)
	_health_bar = _mk_bar(bars, Color(0.3, 0.8, 0.4))
	_mk_label(bars, "Base Core", 12)
	_base_bar = _mk_bar(bars, Color(0.35, 0.6, 0.95))

	_message_label = Label.new()
	_message_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_message_label.position = Vector2(-160, 70)
	_message_label.custom_minimum_size = Vector2(320, 0)
	_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message_label.add_theme_font_size_override("font_size", 18)
	_message_label.modulate = Color(1, 1, 1, 0)
	root.add_child(_message_label)

	_hotbar = HBoxContainer.new()
	_hotbar.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_hotbar.position = Vector2(-180, -54)
	_hotbar.add_theme_constant_override("separation", 8)
	root.add_child(_hotbar)
	var keys: Array = Balance.BUILDABLES.keys()
	for i in keys.size():
		var bid: String = keys[i]
		var def: Dictionary = Balance.BUILDABLES[bid]
		var btn := Button.new()
		btn.text = "%d. %s\n%s" % [i + 1, def.get("label", bid), _cost_text(def.get("cost", {}))]
		btn.custom_minimum_size = Vector2(110, 44)
		btn.toggle_mode = true
		btn.pressed.connect(_on_hotbar_pressed.bind(bid))
		_hotbar.add_child(btn)
		_hotbar_buttons[bid] = btn
	_hotbar.visible = false
	_build_touch_controls(root)


func _build_touch_controls(root: Control) -> void:
	_touch_enabled = OS.has_feature("mobile") or "--touch-ui" in OS.get_cmdline_user_args()
	if not _touch_enabled:
		return

	var move_stick := _VirtualStick.new()
	move_stick.name = "MoveStick"
	move_stick.position = Vector2(22, -182)
	move_stick.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	move_stick.vector_changed.connect(func(v: Vector2) -> void: touch_move_changed.emit(v))
	root.add_child(move_stick)

	var aim_stick := _VirtualStick.new()
	aim_stick.name = "AimAndFireStick"
	aim_stick.fire_while_active = true
	aim_stick.position = Vector2(-182, -182)
	aim_stick.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	aim_stick.vector_changed.connect(func(v: Vector2) -> void: touch_aim_changed.emit(v))
	aim_stick.active_changed.connect(func(active: bool) -> void: touch_fire_changed.emit(active))
	root.add_child(aim_stick)

	var build_button := Button.new()
	build_button.text = "BUILD"
	build_button.custom_minimum_size = Vector2(104, 52)
	build_button.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	build_button.position = Vector2(-52, -116)
	build_button.pressed.connect(func() -> void: build_toggle_requested.emit())
	root.add_child(build_button)

	var pause_button := Button.new()
	pause_button.text = "Ⅱ"
	pause_button.custom_minimum_size = Vector2(54, 54)
	pause_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	pause_button.position = Vector2(-66, 12)
	pause_button.pressed.connect(func() -> void: pause_requested.emit())
	root.add_child(pause_button)


func _mk_label(parent: Node, text: String, size: int) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	l.add_theme_constant_override("shadow_offset_x", 1)
	l.add_theme_constant_override("shadow_offset_y", 1)
	parent.add_child(l)
	return l


func _mk_bar(parent: Node, fill: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.min_value = 0.0
	bar.max_value = 1.0
	bar.value = 1.0
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(200, 14)
	var sb := StyleBoxFlat.new()
	sb.bg_color = fill
	bar.add_theme_stylebox_override("fill", sb)
	parent.add_child(bar)
	return bar


func _cost_text(cost: Dictionary) -> String:
	var parts: PackedStringArray = []
	for k in cost.keys():
		parts.append("%s %d" % [k, int(cost[k])])
	return ", ".join(parts)


func _process(delta: float) -> void:
	if _message_time > 0.0:
		_message_time -= delta
		var a: float = clampf(_message_time, 0.0, 1.0)
		_message_label.modulate = Color(1, 1, 1, a)


func set_phase(phase_name: String, day_number: int) -> void:
	_phase_label.text = "%s  ·  Day %d" % [phase_name, day_number]
	_phase_label.add_theme_color_override(
		"font_color",
		Color(1.0, 0.85, 0.45) if phase_name == "DAY" else Color(0.6, 0.7, 1.0)
	)


func set_timer(seconds_left: int) -> void:
	_timer_label.text = "%02d:%02d" % [seconds_left / 60, seconds_left % 60]


func set_wave(wave: int, alive: int, pending: int) -> void:
	if wave <= 0:
		_wave_label.text = "Wave 0"
	else:
		_wave_label.text = "Wave %d   (%d active, %d incoming)" % [wave, alive, pending]


func set_resources(totals: Dictionary) -> void:
	_resource_label.text = "scrap %d    wood %d    parts %d" % [
		int(totals.get("scrap", 0)), int(totals.get("wood", 0)), int(totals.get("parts", 0))
	]


func set_health(current: float, maximum: float) -> void:
	_health_bar.value = 0.0 if maximum <= 0.0 else current / maximum


func set_base_health(current: float, maximum: float) -> void:
	_base_bar.value = 0.0 if maximum <= 0.0 else current / maximum


func set_build_mode(active: bool) -> void:
	_hotbar.visible = active
	if not active:
		for b in _hotbar_buttons.values():
			(b as Button).button_pressed = false


func flash_message(text: String, hold: float = 2.0) -> void:
	_message_label.text = text
	_message_time = hold
	_message_label.modulate = Color(1, 1, 1, 1)


func _on_hotbar_pressed(bid: String) -> void:
	for k in _hotbar_buttons.keys():
		(_hotbar_buttons[k] as Button).button_pressed = (k == bid)
	build_requested.emit(bid)


class _VirtualStick:
	extends Control
	signal vector_changed(value: Vector2)
	signal active_changed(active: bool)

	var fire_while_active := false
	var _touch_id := -1
	var _value := Vector2.ZERO
	const STICK_SIZE := 160.0
	const RADIUS := 62.0

	func _ready() -> void:
		custom_minimum_size = Vector2(STICK_SIZE, STICK_SIZE)
		size = Vector2(STICK_SIZE, STICK_SIZE)
		mouse_filter = Control.MOUSE_FILTER_STOP
		queue_redraw()

	func _gui_input(event: InputEvent) -> void:
		if event is InputEventScreenTouch:
			var touch := event as InputEventScreenTouch
			if touch.pressed and _touch_id < 0:
				_touch_id = touch.index
				_set_from_local(touch.position)
				active_changed.emit(true)
				accept_event()
			elif not touch.pressed and touch.index == _touch_id:
				_release()
				accept_event()
		elif event is InputEventScreenDrag and (event as InputEventScreenDrag).index == _touch_id:
			_set_from_local((event as InputEventScreenDrag).position)
			accept_event()
		elif event is InputEventMouseButton:
			var mouse := event as InputEventMouseButton
			if mouse.button_index == MOUSE_BUTTON_LEFT:
				if mouse.pressed:
					_touch_id = -2
					_set_from_local(mouse.position)
					active_changed.emit(true)
				else:
					_release()
				accept_event()
		elif event is InputEventMouseMotion and _touch_id == -2:
			_set_from_local((event as InputEventMouseMotion).position)
			accept_event()

	func _set_from_local(pos: Vector2) -> void:
		var center := Vector2.ONE * STICK_SIZE * 0.5
		_value = ((pos - center) / RADIUS).limit_length(1.0)
		vector_changed.emit(_value)
		queue_redraw()

	func _release() -> void:
		_touch_id = -1
		_value = Vector2.ZERO
		vector_changed.emit(Vector2.ZERO)
		active_changed.emit(false)
		queue_redraw()

	func _draw() -> void:
		var center := Vector2.ONE * STICK_SIZE * 0.5
		draw_circle(center, RADIUS, Color(0.05, 0.07, 0.08, 0.48))
		draw_arc(center, RADIUS, 0, TAU, 32, Color(1, 1, 1, 0.38), 3.0)
		draw_circle(center + _value * RADIUS, 25.0, Color(0.88, 0.91, 0.82, 0.72))
		if fire_while_active:
			draw_string(ThemeDB.fallback_font, center + Vector2(-22, 5), "FIRE", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)
