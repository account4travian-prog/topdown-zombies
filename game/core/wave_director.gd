class_name WaveDirector
extends RefCounted

## Owns night-wave escalation. Node-free and delta-driven: the game calls
## `begin_night()` at dusk, then `tick(delta)` each frame; the director returns
## how many zombies to spawn this tick and reports when the wave is cleared.

signal wave_started(wave: int, total_zombies: int)
signal wave_cleared(wave: int)

var wave: int = 0
var _spawns_remaining: int = 0
var _alive: int = 0
var _spawn_timer: float = 0.0
var _spawn_interval: float = Balance.WAVE_SPAWN_INTERVAL_START
var _active: bool = false


## Called when NIGHT begins. Bumps the wave counter and schedules its spawns.
func begin_night() -> void:
	wave += 1
	_spawns_remaining = Balance.wave_zombie_count(wave)
	_spawn_interval = Balance.wave_spawn_interval(wave)
	_spawn_timer = 0.0
	_alive = 0
	_active = true
	wave_started.emit(wave, _spawns_remaining)


## Called when NIGHT ends (timer ran out). Any leftover spawns are cancelled.
func end_night() -> void:
	_active = false
	_spawns_remaining = 0


## Advances spawn scheduling. Returns the number of zombies to spawn this tick.
func tick(delta: float) -> int:
	if not _active or _spawns_remaining <= 0:
		return 0
	_spawn_timer -= delta
	var to_spawn: int = 0
	while _spawn_timer <= 0.0 and _spawns_remaining > 0:
		to_spawn += 1
		_spawns_remaining -= 1
		_spawn_timer += _spawn_interval
	_alive += to_spawn
	return to_spawn


## The game reports each zombie death so the director can detect a cleared wave.
func notify_zombie_removed() -> void:
	_alive = maxi(0, _alive - 1)
	_check_cleared()


func _check_cleared() -> void:
	if _active and _spawns_remaining <= 0 and _alive <= 0:
		_active = false
		wave_cleared.emit(wave)


func zombies_alive() -> int:
	return _alive


func spawns_remaining() -> int:
	return _spawns_remaining


func is_wave_active() -> bool:
	return _active


func to_dict() -> Dictionary:
	return {"wave": wave}


func apply_dict(data: Dictionary) -> void:
	wave = int(data.get("wave", 0))
