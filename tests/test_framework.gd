class_name TestFramework
extends RefCounted

## Tiny zero-dependency assertion harness. Each test file is a RefCounted with
## public `test_*` methods; the runner instantiates it, calls each method with a
## fresh framework, and tallies pass / fail. No third-party addons.

var _suite: String = ""
var passed: int = 0
var failed: int = 0
var failures: Array[String] = []


func begin(suite: String) -> void:
	_suite = suite


func _record(ok: bool, message: String) -> void:
	if ok:
		passed += 1
	else:
		failed += 1
		failures.append("[%s] %s" % [_suite, message])


func check(condition: bool, message: String) -> void:
	_record(condition, message)


func eq(actual: Variant, expected: Variant, message: String) -> void:
	_record(actual == expected, "%s (expected %s, got %s)" % [message, str(expected), str(actual)])


func ne(actual: Variant, unexpected: Variant, message: String) -> void:
	_record(actual != unexpected, "%s (should not equal %s)" % [message, str(unexpected)])


func almost(actual: float, expected: float, message: String, tol: float = 0.0001) -> void:
	_record(absf(actual - expected) <= tol, "%s (expected ~%f, got %f)" % [message, expected, actual])


func greater(actual: float, threshold: float, message: String) -> void:
	_record(actual > threshold, "%s (expected > %f, got %f)" % [message, threshold, actual])


func less(actual: float, threshold: float, message: String) -> void:
	_record(actual < threshold, "%s (expected < %f, got %f)" % [message, threshold, actual])
