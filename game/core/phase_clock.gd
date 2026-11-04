class_name PhaseClock
extends RefCounted

## Deterministic day/night timer. Node-free so headless tests can drive it with
## fixed delta steps. Emits phase transitions through return values rather than
## signals to keep the logic pure and easy to assert.

signal phase_changed(new_phase: int, day_number: int)

var phase: int = Balance.Phase.DAY
var time_left: float = Balance.DAY_SECONDS
var day_number: int = 1

var _day_seconds: float
var _night_seconds: float


func _init(config: GameConfig = null) -> void:
	if config == null:
		config = GameConfig.new()
	_day_seconds = config.day_seconds
	_night_seconds = config.night_seconds
	phase = Balance.Phase.DAY
	time_left = _day_seconds
	day_number = 1


## Advances the clock. Returns true on the tick where the phase flips.
func tick(delta: float) -> bool:
	if delta <= 0.0:
		return false
	time_left -= delta
	if time_left > 0.0:
		return false
	_flip_phase()
	return true


func _flip_phase() -> void:
	if phase == Balance.Phase.DAY:
		phase = Balance.Phase.NIGHT
		time_left += _night_seconds
	else:
		phase = Balance.Phase.DAY
		day_number += 1
		time_left += _day_seconds
	# Guard against pathological huge deltas leaving a negative timer.
	if time_left < 0.0:
		time_left = 0.0
	phase_changed.emit(phase, day_number)


func is_day() -> bool:
	return phase == Balance.Phase.DAY


func is_night() -> bool:
	return phase == Balance.Phase.NIGHT


func phase_name() -> String:
	return "DAY" if is_day() else "NIGHT"


## Whole seconds remaining, for HUD display.
func time_left_ceil() -> int:
	return int(ceil(max(time_left, 0.0)))


func to_dict() -> Dictionary:
	return {
		"phase": phase,
		"time_left": time_left,
		"day_number": day_number,
	}


func apply_dict(data: Dictionary) -> void:
	phase = int(data.get("phase", Balance.Phase.DAY))
	time_left = float(data.get("time_left", _day_seconds))
	day_number = int(data.get("day_number", 1))
