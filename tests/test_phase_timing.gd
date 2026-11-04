class_name TestPhaseTiming
extends RefCounted

## Deterministic checks on PhaseClock: production defaults are exactly 300s,
## transitions flip DAY <-> NIGHT, the day counter advances, and debug overrides
## shorten phases without touching the Balance constants.


func test_production_defaults_are_300s(t: TestFramework) -> void:
	t.almost(Balance.DAY_SECONDS, 300.0, "DAY default is 300s")
	t.almost(Balance.NIGHT_SECONDS, 300.0, "NIGHT default is 300s")
	var clock := PhaseClock.new()
	t.eq(clock.phase, Balance.Phase.DAY, "starts in DAY")
	t.almost(clock.time_left, 300.0, "starts with 300s on the clock")


func test_day_flips_to_night_at_zero(t: TestFramework) -> void:
	var clock := PhaseClock.new()
	var flipped := false
	for i in 299:
		flipped = clock.tick(1.0)
		t.check(not flipped, "no flip at second %d" % (i + 1))
	flipped = clock.tick(1.0)
	t.check(flipped, "flips exactly at 300s elapsed")
	t.eq(clock.phase, Balance.Phase.NIGHT, "now NIGHT")
	t.eq(clock.day_number, 1, "still day 1 through the first night")


func test_full_daynight_cycle_advances_day(t: TestFramework) -> void:
	var clock := PhaseClock.new()
	clock.tick(300.0)          # -> NIGHT
	t.eq(clock.phase, Balance.Phase.NIGHT, "night after first day")
	clock.tick(300.0)          # -> DAY (day 2)
	t.eq(clock.phase, Balance.Phase.DAY, "day after first night")
	t.eq(clock.day_number, 2, "day counter incremented to 2")
	t.almost(clock.time_left, 300.0, "fresh 300s for day 2")


func test_carryover_time_is_preserved(t: TestFramework) -> void:
	var clock := PhaseClock.new()
	# Overshoot the day boundary by 10s; the night should start with 290s left.
	clock.tick(310.0)
	t.eq(clock.phase, Balance.Phase.NIGHT, "flipped to NIGHT on overshoot")
	t.almost(clock.time_left, 290.0, "10s overshoot carried into NIGHT")


func test_debug_override_shortens_phase(t: TestFramework) -> void:
	var cfg := GameConfig.new()
	cfg.set_debug_phase_durations(5.0, 8.0)
	var clock := PhaseClock.new(cfg)
	t.almost(clock.time_left, 5.0, "debug day length applied")
	var flipped := clock.tick(5.0)
	t.check(flipped, "short day flips after 5s")
	t.almost(clock.time_left, 8.0, "debug night length applied")
	# Balance constants remain untouched.
	t.almost(Balance.DAY_SECONDS, 300.0, "Balance DAY constant unchanged")
	t.almost(Balance.NIGHT_SECONDS, 300.0, "Balance NIGHT constant unchanged")


func test_roundtrip_dict(t: TestFramework) -> void:
	var clock := PhaseClock.new()
	clock.tick(150.0)
	var data := clock.to_dict()
	var restored := PhaseClock.new()
	restored.apply_dict(data)
	t.eq(restored.phase, clock.phase, "phase restored")
	t.almost(restored.time_left, clock.time_left, "time_left restored")
	t.eq(restored.day_number, clock.day_number, "day_number restored")
