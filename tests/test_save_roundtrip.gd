class_name TestSaveRoundtrip
extends RefCounted

## SaveSystem: a snapshot survives an encode -> decode roundtrip byte-for-byte
## in meaning, the payload is versioned, and malformed / unsupported inputs are
## rejected with a clear status rather than crashing.


func _sample_snapshot() -> Dictionary:
	return {
		"clock": {"phase": Balance.Phase.NIGHT, "time_left": 142.5, "day_number": 3},
		"resources": {"scrap": 120, "wood": 45, "parts": 30},
		"waves": {"wave": 4},
		"player_health": 68.0,
		"base_health": 410.0,
		"structures": [
			{"id": "barricade", "x": 400.0, "y": 512.0, "health": 160.0},
			{"id": "turret", "x": 640.0, "y": 480.0, "health": 90.0},
		],
	}


func test_roundtrip_preserves_data(t: TestFramework) -> void:
	var snap := _sample_snapshot()
	var bytes := SaveSystem.encode_snapshot(snap)
	var res := SaveSystem.decode_snapshot(bytes)
	t.eq(int(res["status"]), SaveSystem.ImportStatus.OK, "decoded ok")
	var out: Dictionary = res["snapshot"]
	t.eq(int(out["resources"]["scrap"]), 120, "scrap preserved")
	t.almost(float(out["clock"]["time_left"]), 142.5, "clock time preserved")
	t.eq(int(out["waves"]["wave"]), 4, "wave preserved")
	t.eq((out["structures"] as Array).size(), 2, "structure count preserved")
	t.eq(String(out["structures"][1]["id"]), "turret", "second structure id preserved")


func test_payload_is_versioned(t: TestFramework) -> void:
	var bytes := SaveSystem.encode_snapshot(_sample_snapshot())
	var envelope: Variant = JSON.parse_string(bytes.get_string_from_utf8())
	t.eq(typeof(envelope), TYPE_DICTIONARY, "envelope is a JSON object")
	t.eq(int(envelope["version"]), SaveSystem.CURRENT_VERSION, "carries current version")
	t.check(envelope.has("saved_at"), "carries a timestamp")
	t.check(envelope.has("data"), "wraps the snapshot under data")


func test_bad_json_rejected(t: TestFramework) -> void:
	var res := SaveSystem.decode_snapshot("{not valid json".to_utf8_buffer())
	t.eq(int(res["status"]), SaveSystem.ImportStatus.BAD_JSON, "malformed JSON reported")


func test_non_object_rejected(t: TestFramework) -> void:
	var res := SaveSystem.decode_snapshot("[1,2,3]".to_utf8_buffer())
	t.eq(int(res["status"]), SaveSystem.ImportStatus.NOT_AN_OBJECT, "JSON array rejected")


func test_missing_version_rejected(t: TestFramework) -> void:
	var res := SaveSystem.decode_snapshot('{"data": {}}'.to_utf8_buffer())
	t.eq(int(res["status"]), SaveSystem.ImportStatus.MISSING_VERSION, "no version field rejected")


func test_future_version_rejected(t: TestFramework) -> void:
	var future := '{"version": %d, "data": {}}' % (SaveSystem.CURRENT_VERSION + 5)
	var res := SaveSystem.decode_snapshot(future.to_utf8_buffer())
	t.eq(int(res["status"]), SaveSystem.ImportStatus.UNSUPPORTED_VERSION, "future version rejected")


func test_file_roundtrip_on_user_path(t: TestFramework) -> void:
	var path := "user://test_save_roundtrip.json"
	var ok := SaveSystem.save_to_path(_sample_snapshot(), path)
	t.check(ok, "wrote save file to user://")
	t.check(FileAccess.file_exists(path), "save file exists on disk")
	var res := SaveSystem.load_from_path(path)
	t.eq(int(res["status"]), SaveSystem.ImportStatus.OK, "reloaded from disk")
	t.eq(int(res["snapshot"]["resources"]["wood"]), 45, "wood value survives a disk roundtrip")
	DirAccess.remove_absolute(path)


func test_missing_file_reported(t: TestFramework) -> void:
	var res := SaveSystem.load_from_path("user://does_not_exist_%d.json" % randi())
	t.eq(int(res["status"]), SaveSystem.ImportStatus.FILE_NOT_FOUND, "missing file reported cleanly")
