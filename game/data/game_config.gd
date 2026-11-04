class_name GameConfig
extends RefCounted

## Runtime-adjustable configuration layered on top of the immutable Balance
## tables. Debug overrides live here so tests and the in-game debug panel can
## shorten phases without touching production constants.

var day_seconds: float = Balance.DAY_SECONDS
var night_seconds: float = Balance.NIGHT_SECONDS

## When true, phase durations may deviate from the 300s production defaults.
var debug_overrides_enabled: bool = false

## Audio, 0.0 - 1.0.
var master_volume: float = 0.8
var sfx_volume: float = 0.9
var music_volume: float = 0.6

## Aim assist strength, 0.0 (off) - 1.0 (strong magnetism toward nearest zombie).
var aim_assist: float = 0.35


func set_debug_phase_durations(day: float, night: float) -> void:
	debug_overrides_enabled = true
	day_seconds = maxf(1.0, day)
	night_seconds = maxf(1.0, night)


func reset_phase_durations() -> void:
	debug_overrides_enabled = false
	day_seconds = Balance.DAY_SECONDS
	night_seconds = Balance.NIGHT_SECONDS


func settings_to_dict() -> Dictionary:
	return {
		"master_volume": master_volume,
		"sfx_volume": sfx_volume,
		"music_volume": music_volume,
		"aim_assist": aim_assist,
	}


func apply_settings_dict(data: Dictionary) -> void:
	master_volume = clampf(float(data.get("master_volume", master_volume)), 0.0, 1.0)
	sfx_volume = clampf(float(data.get("sfx_volume", sfx_volume)), 0.0, 1.0)
	music_volume = clampf(float(data.get("music_volume", music_volume)), 0.0, 1.0)
	aim_assist = clampf(float(data.get("aim_assist", aim_assist)), 0.0, 1.0)
