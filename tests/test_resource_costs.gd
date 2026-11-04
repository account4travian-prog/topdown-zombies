class_name TestResourceCosts
extends RefCounted

## ResourceLedger accounting: affordability is all-or-nothing, spending debits
## every line item, unaffordable purchases are inert, and pickups / night
## rewards credit correctly.


func test_starting_stockpile(t: TestFramework) -> void:
	var l := ResourceLedger.new()
	t.eq(l.amount("scrap"), int(Balance.START_RESOURCES["scrap"]), "starts with default scrap")
	t.eq(l.amount("wood"), int(Balance.START_RESOURCES["wood"]), "starts with default wood")
	t.eq(l.amount("parts"), int(Balance.START_RESOURCES["parts"]), "starts with default parts")


func test_can_afford_is_all_or_nothing(t: TestFramework) -> void:
	var l := ResourceLedger.new({"scrap": 25, "parts": 10})
	t.check(l.can_afford(Balance.BUILDABLES["turret"]["cost"]) == false, "turret unaffordable: parts short")
	l.add("parts", 5)
	t.check(l.can_afford(Balance.BUILDABLES["turret"]["cost"]), "turret affordable once parts cover cost")


func test_spend_debits_every_line_item(t: TestFramework) -> void:
	var l := ResourceLedger.new({"scrap": 50, "parts": 20, "wood": 0})
	var ok := l.try_spend(Balance.BUILDABLES["turret"]["cost"])  # scrap 25, parts 15
	t.check(ok, "turret purchase succeeds")
	t.eq(l.amount("scrap"), 25, "scrap debited by 25")
	t.eq(l.amount("parts"), 5, "parts debited by 15")


func test_failed_spend_changes_nothing(t: TestFramework) -> void:
	var l := ResourceLedger.new({"scrap": 10, "parts": 2})
	var before := l.totals()
	var ok := l.try_spend(Balance.BUILDABLES["turret"]["cost"])
	t.check(not ok, "unaffordable purchase rejected")
	t.eq(l.totals(), before, "totals untouched after rejected purchase")


func test_barricade_and_spike_costs(t: TestFramework) -> void:
	var l := ResourceLedger.new({"wood": 15, "scrap": 20})
	t.check(l.try_spend(Balance.BUILDABLES["barricade"]["cost"]), "barricade affordable")
	t.eq(l.amount("wood"), 0, "barricade drains 15 wood")
	t.check(l.try_spend(Balance.BUILDABLES["spike_trap"]["cost"]), "spike trap affordable")
	t.eq(l.amount("scrap"), 0, "spike trap drains 20 scrap")


func test_pickups_and_night_reward_credit(t: TestFramework) -> void:
	var l := ResourceLedger.new({"scrap": 0, "wood": 0, "parts": 0})
	l.add("scrap", int(Balance.PICKUP_AMOUNT["scrap"]))
	t.eq(l.amount("scrap"), int(Balance.PICKUP_AMOUNT["scrap"]), "scrap pickup credited")
	l.add_bundle(Balance.NIGHT_CLEAR_REWARD)
	t.eq(l.amount("wood"), int(Balance.NIGHT_CLEAR_REWARD["wood"]), "night reward credits wood")
	t.eq(l.amount("parts"), int(Balance.NIGHT_CLEAR_REWARD["parts"]), "night reward credits parts")


func test_totals_never_go_negative(t: TestFramework) -> void:
	var l := ResourceLedger.new({"scrap": 5})
	l.add("scrap", -100)
	t.eq(l.amount("scrap"), 0, "clamped at zero, not negative")
