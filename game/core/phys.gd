class_name Phys
extends RefCounted

## Shared collision-layer bit indices (1-based, as Godot's inspector shows them)
## and group names. Centralised so every entity agrees on who collides with who
## without needing named layers registered in project.godot.

const L_WORLD: int = 1      ## arena boundary walls
const L_PLAYER: int = 2
const L_ZOMBIE: int = 3
const L_STRUCTURE: int = 4  ## movement-blocking buildables + base core
const L_BULLET: int = 5
const L_PICKUP: int = 6
const L_TRAP: int = 7       ## non-blocking damage areas (spike trap)

const GROUP_ZOMBIE: String = "zombie"
const GROUP_PLAYER: String = "player"
const GROUP_ATTACKABLE: String = "attackable"  ## has take_damage(float)
const GROUP_STRUCTURE: String = "structure"
const GROUP_PICKUP: String = "pickup"


## Converts a 1-based layer index into a bitmask value.
static func bit(index: int) -> int:
	return 1 << (index - 1)


## Builds a bitmask from several 1-based layer indices.
static func mask(indices: Array) -> int:
	var m: int = 0
	for i in indices:
		m |= bit(int(i))
	return m
