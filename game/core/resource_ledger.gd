class_name ResourceLedger
extends RefCounted

## Tracks the player's stockpile of scrap / wood / parts and enforces that a
## purchase can only succeed when every line item is affordable. All build
## costs flow through here so resource accounting is single-sourced.

signal changed(totals: Dictionary)

var _totals: Dictionary = {}


func _init(starting: Dictionary = {}) -> void:
	var seed_data: Dictionary = starting if not starting.is_empty() else Balance.START_RESOURCES
	for key in seed_data.keys():
		_totals[key] = int(seed_data[key])


func amount(kind: String) -> int:
	return int(_totals.get(kind, 0))


func totals() -> Dictionary:
	return _totals.duplicate(true)


func add(kind: String, quantity: int) -> void:
	if quantity == 0:
		return
	_totals[kind] = maxi(0, amount(kind) + quantity)
	changed.emit(totals())


func add_bundle(bundle: Dictionary) -> void:
	var touched: bool = false
	for key in bundle.keys():
		var q: int = int(bundle[key])
		if q != 0:
			_totals[key] = maxi(0, amount(key) + q)
			touched = true
	if touched:
		changed.emit(totals())


## True when every line item in `cost` is fully covered by the stockpile.
func can_afford(cost: Dictionary) -> bool:
	for key in cost.keys():
		if amount(key) < int(cost[key]):
			return false
	return true


## Attempts to spend `cost`. Returns false and spends nothing if unaffordable.
func try_spend(cost: Dictionary) -> bool:
	if not can_afford(cost):
		return false
	for key in cost.keys():
		_totals[key] = amount(key) - int(cost[key])
	changed.emit(totals())
	return true


func to_dict() -> Dictionary:
	return totals()


func apply_dict(data: Dictionary) -> void:
	_totals.clear()
	for key in data.keys():
		_totals[key] = int(data[key])
	changed.emit(totals())
