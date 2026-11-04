class_name Balance
extends RefCounted

## Central, data-driven tuning tables for Last Stand Homestead.
## Every gameplay system reads from here so balance stays in one place and
## headless tests can assert against the same numbers the game runs with.

## Phase durations in seconds. Production defaults are exactly 300s / 300s.
## Debug overrides are applied through GameConfig, never by mutating these.
const DAY_SECONDS: float = 300.0
const NIGHT_SECONDS: float = 300.0

enum Phase { DAY, NIGHT }

## Starting stockpile the player wakes up with on a fresh run.
const START_RESOURCES: Dictionary = {
	"scrap": 40,
	"wood": 30,
	"parts": 10,
}

const PLAYER_MAX_HEALTH: float = 100.0
const BASE_CORE_MAX_HEALTH: float = 500.0

const PLAYER_SPEED: float = 220.0
const PLAYER_FIRE_COOLDOWN: float = 0.16
const BULLET_SPEED: float = 720.0
const BULLET_DAMAGE: float = 24.0
const BULLET_LIFETIME: float = 1.4

## Resource pickups that spawn around the map during DAY.
const PICKUP_KINDS: Array[String] = ["scrap", "wood", "parts"]
const PICKUP_AMOUNT: Dictionary = {
	"scrap": 8,
	"wood": 6,
	"parts": 3,
}
const PICKUP_SPAWN_INTERVAL: float = 4.0
const PICKUP_MAX_ACTIVE: int = 14

## Buildable catalogue. `cost` is checked and spent by BuildSystem.
const BUILDABLES: Dictionary = {
	"barricade": {
		"label": "Barricade",
		"cost": {"wood": 15},
		"health": 160.0,
		"blocks_movement": true,
		"size": Vector2(48, 48),
	},
	"spike_trap": {
		"label": "Spike Trap",
		"cost": {"scrap": 20},
		"health": 80.0,
		"blocks_movement": false,
		"contact_damage": 18.0,
		"contact_interval": 0.5,
		"size": Vector2(44, 44),
	},
	"turret": {
		"label": "Auto-Turret",
		"cost": {"scrap": 25, "parts": 15},
		"health": 120.0,
		"blocks_movement": true,
		"range": 260.0,
		"fire_interval": 0.7,
		"damage": 16.0,
		"size": Vector2(40, 40),
	},
}

## Minimum spacing between two placed structures, centre to centre.
const PLACEMENT_MIN_SPACING: float = 40.0

## Zombie base stats before per-wave scaling is applied.
const ZOMBIE_BASE_HEALTH: float = 40.0
const ZOMBIE_BASE_SPEED: float = 62.0
const ZOMBIE_BASE_DAMAGE: float = 10.0
const ZOMBIE_ATTACK_INTERVAL: float = 0.8
const ZOMBIE_TOUCH_RADIUS: float = 26.0

## Wave escalation model. Everything the WaveDirector needs is derived from
## these constants so progression is fully deterministic and testable.
const WAVE_BASE_COUNT: int = 6
const WAVE_COUNT_PER_WAVE: int = 3
const WAVE_HEALTH_GROWTH: float = 0.18   ## +18% zombie health per wave index
const WAVE_SPEED_GROWTH: float = 0.05    ## +5% zombie speed per wave index
const WAVE_SPAWN_INTERVAL_START: float = 1.6
const WAVE_SPAWN_INTERVAL_MIN: float = 0.35
const WAVE_SPAWN_INTERVAL_DECAY: float = 0.12  ## seconds shaved per wave index

## Resource reward granted at the end of each survived night.
const NIGHT_CLEAR_REWARD: Dictionary = {
	"scrap": 25,
	"wood": 15,
	"parts": 10,
}

const SAVE_VERSION: int = 1
const SAVE_PATH: String = "user://save_game.json"
const SETTINGS_PATH: String = "user://settings.json"


## Returns the zombie stat block for a given 1-based wave number.
static func wave_zombie_stats(wave: int) -> Dictionary:
	var idx: int = maxi(wave - 1, 0)
	return {
		"health": ZOMBIE_BASE_HEALTH * (1.0 + WAVE_HEALTH_GROWTH * idx),
		"speed": ZOMBIE_BASE_SPEED * (1.0 + WAVE_SPEED_GROWTH * idx),
		"damage": ZOMBIE_BASE_DAMAGE,
	}


## Total number of zombies scheduled to spawn in a given wave.
static func wave_zombie_count(wave: int) -> int:
	var idx: int = maxi(wave - 1, 0)
	return WAVE_BASE_COUNT + WAVE_COUNT_PER_WAVE * idx


## Seconds between individual spawns during a given wave.
static func wave_spawn_interval(wave: int) -> float:
	var idx: int = maxi(wave - 1, 0)
	return maxf(
		WAVE_SPAWN_INTERVAL_MIN,
		WAVE_SPAWN_INTERVAL_START - WAVE_SPAWN_INTERVAL_DECAY * idx
	)
