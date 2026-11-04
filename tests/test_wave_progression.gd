class_name TestWaveProgression
extends RefCounted

## WaveDirector escalation: each night bumps the wave, later waves send more and
## tougher zombies faster, spawns are scheduled over time (not all at once), and
## a wave only reports "cleared" once every scheduled zombie is dead.


func test_each_night_increments_wave(t: TestFramework) -> void:
	var wd := WaveDirector.new()
	t.eq(wd.wave, 0, "no wave before the first night")
	wd.begin_night()
	t.eq(wd.wave, 1, "first night is wave 1")
	wd.end_night()
	wd.begin_night()
	t.eq(wd.wave, 2, "second night is wave 2")


func test_counts_and_difficulty_escalate(t: TestFramework) -> void:
	t.eq(Balance.wave_zombie_count(1), Balance.WAVE_BASE_COUNT, "wave 1 uses the base count")
	t.greater(Balance.wave_zombie_count(3), Balance.wave_zombie_count(1), "wave 3 sends more than wave 1")
	t.greater(Balance.wave_zombie_count(5), Balance.wave_zombie_count(3), "wave 5 sends more than wave 3")

	var hp1: float = Balance.wave_zombie_stats(1)["health"]
	var hp5: float = Balance.wave_zombie_stats(5)["health"]
	t.greater(hp5, hp1, "wave 5 zombies are tougher")
	var sp1: float = Balance.wave_zombie_stats(1)["speed"]
	var sp5: float = Balance.wave_zombie_stats(5)["speed"]
	t.greater(sp5, sp1, "wave 5 zombies are faster")

	t.less(Balance.wave_spawn_interval(5), Balance.wave_spawn_interval(1), "later waves spawn faster")
	t.check(Balance.wave_spawn_interval(50) >= Balance.WAVE_SPAWN_INTERVAL_MIN, "spawn interval clamped to a floor")


func test_spawns_are_time_gated(t: TestFramework) -> void:
	var wd := WaveDirector.new()
	wd.begin_night()  # wave 1
	var total := Balance.wave_zombie_count(1)
	var first := wd.tick(0.001)
	t.eq(first, 1, "one zombie on the opening tick")
	t.eq(wd.tick(0.0), 0, "no zombies without elapsed time")
	var interval := Balance.wave_spawn_interval(1)
	var second := wd.tick(interval)
	t.eq(second, 1, "one more zombie after exactly one interval")
	t.eq(wd.spawns_remaining(), total - 2, "spawn budget drawn down by two")


func test_all_spawns_release_over_time(t: TestFramework) -> void:
	var wd := WaveDirector.new()
	wd.begin_night()
	var total := Balance.wave_zombie_count(1)
	var spawned := 0
	for i in 2000:
		spawned += wd.tick(0.1)
		if wd.spawns_remaining() == 0:
			break
	t.eq(spawned, total, "every scheduled zombie eventually spawns")
	t.eq(wd.zombies_alive(), total, "all spawned zombies are counted alive")


func test_wave_clears_only_after_all_dead(t: TestFramework) -> void:
	var wd := WaveDirector.new()
	var cleared: Array[int] = []
	wd.wave_cleared.connect(func(w: int) -> void: cleared.append(w))
	wd.begin_night()
	var total := Balance.wave_zombie_count(1)
	for i in 5000:
		wd.tick(0.2)
		if wd.spawns_remaining() == 0:
			break
	t.eq(wd.spawns_remaining(), 0, "spawns exhausted")
	for i in range(total - 1):
		wd.notify_zombie_removed()
	t.eq(cleared.size(), 0, "not cleared while one zombie remains")
	wd.notify_zombie_removed()
	t.eq(cleared, [1] as Array[int], "cleared fires once the last zombie dies")
	t.check(not wd.is_wave_active(), "wave no longer active after clear")


func test_end_night_cancels_pending_spawns(t: TestFramework) -> void:
	var wd := WaveDirector.new()
	wd.begin_night()
	wd.tick(0.001)
	wd.end_night()
	t.eq(wd.spawns_remaining(), 0, "pending spawns cancelled at dawn")
	t.eq(wd.tick(10.0), 0, "no spawns after the night ends")
