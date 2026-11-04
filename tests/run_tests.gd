extends SceneTree

## Headless test entry point. Run with:
##   Godot_v4.7.1-stable_win64_console.exe --headless --path <project> \
##     --script res://tests/run_tests.gd
##
## Discovers every `test_*` method on each registered suite, runs it against a
## fresh TestFramework, prints a per-suite and total tally, and sets the process
## exit code (0 = all passed, 1 = any failure). No third-party addons.

func _suites() -> Array:
	return [
		TestPhaseTiming,
		TestResourceCosts,
		TestPlacementRules,
		TestSaveRoundtrip,
		TestWaveProgression,
	]


func _initialize() -> void:
	var total_pass := 0
	var total_fail := 0
	var all_failures: Array[String] = []

	print("\n=== Last Stand Homestead — gameplay test run ===")
	for suite_script in _suites():
		var instance: Object = (suite_script as GDScript).new()
		var suite_name: String = (suite_script as GDScript).get_global_name()
		var fw := TestFramework.new()
		fw.begin(suite_name)

		var methods: Array = instance.get_method_list()
		var names: Array[String] = []
		for m in methods:
			var n: String = m["name"]
			if n.begins_with("test_") and not names.has(n):
				names.append(n)
		names.sort()
		for n in names:
			instance.call(n, fw)

		total_pass += fw.passed
		total_fail += fw.failed
		all_failures.append_array(fw.failures)
		var mark := "ok  " if fw.failed == 0 else "FAIL"
		print("  [%s] %-22s  %d passed, %d failed" % [mark, suite_name, fw.passed, fw.failed])

	print("-----------------------------------------------")
	print("  TOTAL: %d passed, %d failed" % [total_pass, total_fail])
	if total_fail > 0:
		print("\nFailures:")
		for f in all_failures:
			print("  - " + f)
	print("===============================================\n")

	quit(1 if total_fail > 0 else 0)
