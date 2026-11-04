class_name TestPlacementRules
extends RefCounted

## BuildSystem placement validation: bounds, keep-out zones, structure spacing,
## affordability ordering, and that a successful placement spends the cost.

var _bounds := Rect2(Vector2(40, 40), Vector2(1520, 1120))


func _rich_ledger() -> ResourceLedger:
	return ResourceLedger.new({"scrap": 999, "wood": 999, "parts": 999})


func test_valid_placement_ok(t: TestFramework) -> void:
	var r := BuildSystem.validate("barricade", Vector2(400, 400), [], _bounds, [], _rich_ledger())
	t.eq(r, BuildSystem.Result.OK, "open placement is legal")


func test_unknown_buildable_rejected(t: TestFramework) -> void:
	var r := BuildSystem.validate("laser_fence", Vector2(400, 400), [], _bounds, [], _rich_ledger())
	t.eq(r, BuildSystem.Result.UNKNOWN_BUILDABLE, "unknown id rejected")


func test_out_of_bounds_rejected(t: TestFramework) -> void:
	var r := BuildSystem.validate("barricade", Vector2(10, 10), [], _bounds, [], _rich_ledger())
	t.eq(r, BuildSystem.Result.OUT_OF_BOUNDS, "placement clipping the wall rejected")


func test_keepout_rejected(t: TestFramework) -> void:
	var keep := [Rect2(Vector2(760, 560), Vector2(80, 80))]
	var r := BuildSystem.validate("barricade", Vector2(790, 590), [], _bounds, keep, _rich_ledger())
	t.eq(r, BuildSystem.Result.INSIDE_KEEPOUT, "placement inside keep-out rejected")


func test_spacing_rejected(t: TestFramework) -> void:
	var existing := [BuildSystem.Placement.new("barricade", Vector2(400, 400))]
	var r := BuildSystem.validate("barricade", Vector2(410, 400), existing, _bounds, [], _rich_ledger())
	t.eq(r, BuildSystem.Result.OVERLAPS_STRUCTURE, "too-close placement rejected")
	var r2 := BuildSystem.validate("barricade", Vector2(400 + 60, 400), existing, _bounds, [], _rich_ledger())
	t.eq(r2, BuildSystem.Result.OK, "far enough placement allowed")


func test_cannot_afford_rejected(t: TestFramework) -> void:
	var poor := ResourceLedger.new({"scrap": 0, "wood": 0, "parts": 0})
	var r := BuildSystem.validate("turret", Vector2(400, 400), [], _bounds, [], poor)
	t.eq(r, BuildSystem.Result.CANNOT_AFFORD, "no resources -> cannot afford")


func test_try_place_spends_and_returns_placement(t: TestFramework) -> void:
	var ledger := ResourceLedger.new({"scrap": 30, "parts": 20, "wood": 0})
	var placement := BuildSystem.try_place("turret", Vector2(500, 500), [], _bounds, [], ledger)
	t.ne(placement, null, "placement returned on success")
	t.eq(placement.id, "turret", "placement carries the id")
	t.eq(ledger.amount("scrap"), 5, "scrap spent (30 - 25)")
	t.eq(ledger.amount("parts"), 5, "parts spent (20 - 15)")


func test_try_place_returns_null_when_illegal(t: TestFramework) -> void:
	var ledger := _rich_ledger()
	var placement := BuildSystem.try_place("barricade", Vector2(5, 5), [], _bounds, [], ledger)
	t.eq(placement, null, "illegal placement returns null")
	t.eq(ledger.amount("wood"), 999, "nothing spent on a failed placement")


func test_placement_dict_roundtrip(t: TestFramework) -> void:
	var p := BuildSystem.Placement.new("spike_trap", Vector2(123, 456))
	p.health = 42.0
	var back := BuildSystem.Placement.from_dict(p.to_dict())
	t.eq(back.id, "spike_trap", "id survives roundtrip")
	t.almost(back.position.x, 123.0, "x survives roundtrip")
	t.almost(back.health, 42.0, "health survives roundtrip")
