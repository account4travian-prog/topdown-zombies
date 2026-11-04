class_name BuildSystem
extends RefCounted

## Pure placement-rule engine for build mode. Given the candidate structure, the
## already-placed structures, the arena bounds and keep-out zones, it decides
## whether a placement is legal and (optionally) spends the cost through the
## ledger. Kept node-free so placement rules are unit-testable.

enum Result {
	OK,
	UNKNOWN_BUILDABLE,
	CANNOT_AFFORD,
	OUT_OF_BOUNDS,
	OVERLAPS_STRUCTURE,
	INSIDE_KEEPOUT,
}

## A lightweight placed-structure record. `id` matches a Balance.BUILDABLES key.
class Placement:
	var id: String
	var position: Vector2
	var health: float

	func _init(p_id: String, p_position: Vector2) -> void:
		id = p_id
		position = p_position
		health = float(Balance.BUILDABLES.get(p_id, {}).get("health", 1.0))

	func size() -> Vector2:
		return Balance.BUILDABLES.get(id, {}).get("size", Vector2(40, 40))

	func rect() -> Rect2:
		var s: Vector2 = size()
		return Rect2(position - s * 0.5, s)

	func to_dict() -> Dictionary:
		return {"id": id, "x": position.x, "y": position.y, "health": health}

	static func from_dict(data: Dictionary) -> Placement:
		var pl := Placement.new(
			String(data.get("id", "")),
			Vector2(float(data.get("x", 0.0)), float(data.get("y", 0.0)))
		)
		pl.health = float(data.get("health", pl.health))
		return pl


## Validates a placement without mutating anything.
## `keepouts` is an Array[Rect2] of forbidden regions (base core, player spawn).
static func validate(
	buildable_id: String,
	position: Vector2,
	existing: Array,
	arena_bounds: Rect2,
	keepouts: Array,
	ledger: ResourceLedger
) -> int:
	if not Balance.BUILDABLES.has(buildable_id):
		return Result.UNKNOWN_BUILDABLE

	var def: Dictionary = Balance.BUILDABLES[buildable_id]
	var size: Vector2 = def.get("size", Vector2(40, 40))
	var candidate_rect := Rect2(position - size * 0.5, size)

	if not arena_bounds.encloses(candidate_rect):
		return Result.OUT_OF_BOUNDS

	for zone in keepouts:
		if (zone as Rect2).intersects(candidate_rect):
			return Result.INSIDE_KEEPOUT

	for other in existing:
		var pl := other as Placement
		if position.distance_to(pl.position) < Balance.PLACEMENT_MIN_SPACING:
			return Result.OVERLAPS_STRUCTURE
		if pl.rect().intersects(candidate_rect):
			return Result.OVERLAPS_STRUCTURE

	if ledger != null and not ledger.can_afford(def.get("cost", {})):
		return Result.CANNOT_AFFORD

	return Result.OK


## Validates and, on success, spends the cost and returns a new Placement.
## Returns null when the placement is illegal (call `validate` for the reason).
static func try_place(
	buildable_id: String,
	position: Vector2,
	existing: Array,
	arena_bounds: Rect2,
	keepouts: Array,
	ledger: ResourceLedger
) -> Placement:
	var result: int = validate(
		buildable_id, position, existing, arena_bounds, keepouts, ledger
	)
	if result != Result.OK:
		return null
	var def: Dictionary = Balance.BUILDABLES[buildable_id]
	if ledger != null:
		ledger.try_spend(def.get("cost", {}))
	return Placement.new(buildable_id, position)


static func result_message(result: int) -> String:
	match result:
		Result.OK: return "Placed"
		Result.UNKNOWN_BUILDABLE: return "Unknown structure"
		Result.CANNOT_AFFORD: return "Not enough resources"
		Result.OUT_OF_BOUNDS: return "Outside the buildable area"
		Result.OVERLAPS_STRUCTURE: return "Too close to another structure"
		Result.INSIDE_KEEPOUT: return "Cannot build there"
		_: return "Cannot build"
