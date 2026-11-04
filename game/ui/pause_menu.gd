class_name PauseMenu
extends CanvasLayer

## Pause + settings overlay. Volume sliders, aim-assist slider, a debug phase
## override, and Save / Export / Import / Restart actions. Emits intent signals;
## the game owns the actual side effects.

signal resumed
signal restart_requested
signal export_requested(path: String)
signal import_requested(path: String)
signal settings_changed(settings: Dictionary)
signal debug_phase_override(day_seconds: float, night_seconds: float)

var _panel: Panel
var _master: HSlider
var _sfx: HSlider
var _music: HSlider
var _assist: HSlider
var _day_spin: SpinBox
var _night_spin: SpinBox
var _status: Label
var _export_dialog: FileDialog
var _import_dialog: FileDialog


func _ready() -> void:
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.55)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	_panel = Panel.new()
	_panel.set_anchors_preset(Control.PRESET_CENTER)
	_panel.custom_minimum_size = Vector2(380, 470)
	_panel.position = Vector2(-190, -235)
	add_child(_panel)

	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.offset_left = 18
	box.offset_top = 16
	box.offset_right = -18
	box.offset_bottom = -16
	box.add_theme_constant_override("separation", 8)
	_panel.add_child(box)

	var title := Label.new()
	title.text = "Paused"
	title.add_theme_font_size_override("font_size", 24)
	box.add_child(title)

	_master = _add_slider(box, "Master volume")
	_sfx = _add_slider(box, "SFX volume")
	_music = _add_slider(box, "Music volume")
	_assist = _add_slider(box, "Aim assist")

	box.add_child(HSeparator.new())
	var dbg := Label.new()
	dbg.text = "Debug phase override (seconds)"
	box.add_child(dbg)
	var dbg_row := HBoxContainer.new()
	box.add_child(dbg_row)
	_day_spin = _add_spin(dbg_row, "Day", Balance.DAY_SECONDS)
	_night_spin = _add_spin(dbg_row, "Night", Balance.NIGHT_SECONDS)
	var apply_dbg := Button.new()
	apply_dbg.text = "Apply override"
	apply_dbg.pressed.connect(func() -> void:
		debug_phase_override.emit(_day_spin.value, _night_spin.value)
		_set_status("Phase override applied")
	)
	box.add_child(apply_dbg)

	box.add_child(HSeparator.new())
	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 8)
	box.add_child(btn_row)
	_add_button(btn_row, "Resume", func() -> void: resumed.emit())
	_add_button(btn_row, "Restart", func() -> void: restart_requested.emit())

	var io_row := HBoxContainer.new()
	io_row.add_theme_constant_override("separation", 8)
	box.add_child(io_row)
	_add_button(io_row, "Export save", func() -> void: _export_dialog.popup_centered_ratio(0.6))
	_add_button(io_row, "Import save", func() -> void: _import_dialog.popup_centered_ratio(0.6))

	_status = Label.new()
	_status.add_theme_font_size_override("font_size", 13)
	_status.modulate = Color(0.8, 0.9, 1.0)
	box.add_child(_status)

	_export_dialog = _make_file_dialog(FileDialog.FILE_MODE_SAVE_FILE)
	_export_dialog.file_selected.connect(func(p: String) -> void: export_requested.emit(p))
	add_child(_export_dialog)

	_import_dialog = _make_file_dialog(FileDialog.FILE_MODE_OPEN_FILE)
	_import_dialog.file_selected.connect(func(p: String) -> void: import_requested.emit(p))
	add_child(_import_dialog)


func _make_file_dialog(mode: int) -> FileDialog:
	var d := FileDialog.new()
	d.file_mode = mode
	d.access = FileDialog.ACCESS_FILESYSTEM
	d.current_file = "last-stand-save.json"
	d.add_filter("*.json ; JSON save files")
	d.use_native_dialog = true
	return d


func _add_slider(parent: Node, label_text: String) -> HSlider:
	var row := VBoxContainer.new()
	parent.add_child(row)
	var l := Label.new()
	l.text = label_text
	row.add_child(l)
	var s := HSlider.new()
	s.min_value = 0.0
	s.max_value = 1.0
	s.step = 0.01
	s.value = 0.8
	s.custom_minimum_size = Vector2(0, 20)
	s.value_changed.connect(func(_v: float) -> void: _emit_settings())
	row.add_child(s)
	return s


func _add_spin(parent: Node, label_text: String, value: float) -> SpinBox:
	var col := VBoxContainer.new()
	parent.add_child(col)
	var l := Label.new()
	l.text = label_text
	col.add_child(l)
	var sp := SpinBox.new()
	sp.min_value = 1.0
	sp.max_value = 600.0
	sp.value = value
	col.add_child(sp)
	return sp


func _add_button(parent: Node, text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.pressed.connect(cb)
	parent.add_child(b)
	return b


func _emit_settings() -> void:
	settings_changed.emit({
		"master_volume": _master.value,
		"sfx_volume": _sfx.value,
		"music_volume": _music.value,
		"aim_assist": _assist.value,
	})


func sync_from_config(config: GameConfig) -> void:
	_master.set_value_no_signal(config.master_volume)
	_sfx.set_value_no_signal(config.sfx_volume)
	_music.set_value_no_signal(config.music_volume)
	_assist.set_value_no_signal(config.aim_assist)
	_day_spin.value = config.day_seconds
	_night_spin.value = config.night_seconds


func open() -> void:
	visible = true


func close() -> void:
	visible = false


func _set_status(text: String) -> void:
	_status.text = text


func report_io(text: String) -> void:
	_set_status(text)
