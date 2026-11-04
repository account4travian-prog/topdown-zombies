class_name SaveSystem
extends RefCounted

## Versioned local JSON persistence plus an export / import API.
##
## The core of the API is byte-oriented (`encode_snapshot` / `decode_snapshot`)
## so it works identically for:
##   * the desktop path flow (`export_to_path` / `import_from_path`), and
##   * the Android Storage Access Framework flow, where a document picker hands
##     back a file's bytes or a content:// URI rather than a plain filesystem
##     path. Android integration code calls `encode_snapshot` and writes the
##     bytes through the picker callback; on import it feeds the picked bytes
##     straight into `decode_snapshot`.
##
## Every payload carries `version`. `decode_snapshot` runs migrations so old
## saves keep loading after the schema evolves.

const CURRENT_VERSION: int = Balance.SAVE_VERSION

enum ImportStatus { OK, FILE_NOT_FOUND, BAD_JSON, NOT_AN_OBJECT, MISSING_VERSION, UNSUPPORTED_VERSION }


## Wraps a gameplay snapshot dictionary with envelope metadata and returns the
## UTF-8 JSON bytes ready to persist or hand to a document picker.
static func encode_snapshot(snapshot: Dictionary) -> PackedByteArray:
	var envelope: Dictionary = {
		"version": CURRENT_VERSION,
		"app": "last-stand-homestead",
		"saved_at": int(Time.get_unix_time_from_system()),
		"data": snapshot,
	}
	return JSON.stringify(envelope, "\t").to_utf8_buffer()


## Parses bytes produced by `encode_snapshot`. Returns:
##   { "status": ImportStatus, "snapshot": Dictionary, "version": int }
static func decode_snapshot(bytes: PackedByteArray) -> Dictionary:
	var text: String = bytes.get_string_from_utf8()
	# Use an instance parse (not the static helper) so malformed input reported by
	# import tooling doesn't also spam the error log.
	var json := JSON.new()
	if json.parse(text) != OK:
		return {"status": ImportStatus.BAD_JSON, "snapshot": {}, "version": 0}
	var parsed: Variant = json.data
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"status": ImportStatus.NOT_AN_OBJECT, "snapshot": {}, "version": 0}

	var envelope: Dictionary = parsed
	if not envelope.has("version"):
		return {"status": ImportStatus.MISSING_VERSION, "snapshot": {}, "version": 0}

	var version: int = int(envelope["version"])
	if version <= 0 or version > CURRENT_VERSION:
		return {"status": ImportStatus.UNSUPPORTED_VERSION, "snapshot": {}, "version": version}

	var snapshot: Dictionary = envelope.get("data", {})
	snapshot = _migrate(snapshot, version)
	return {"status": ImportStatus.OK, "snapshot": snapshot, "version": version}


## Applies forward migrations so a v(N) payload is usable by the current build.
static func _migrate(snapshot: Dictionary, from_version: int) -> Dictionary:
	var out: Dictionary = snapshot.duplicate(true)
	# No historical migrations yet; future schema bumps append steps here, e.g.
	# if from_version < 2: out["something"] = out.get("something", default)
	return out


# --- Desktop / user:// convenience wrappers --------------------------------

static func save_to_path(snapshot: Dictionary, path: String) -> bool:
	var f: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_error("SaveSystem: cannot open %s for writing (%d)" % [path, FileAccess.get_open_error()])
		return false
	f.store_buffer(encode_snapshot(snapshot))
	f.close()
	return true


static func load_from_path(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"status": ImportStatus.FILE_NOT_FOUND, "snapshot": {}, "version": 0}
	var f: FileAccess = FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {"status": ImportStatus.FILE_NOT_FOUND, "snapshot": {}, "version": 0}
	var bytes: PackedByteArray = f.get_buffer(f.get_length())
	f.close()
	return decode_snapshot(bytes)


static func autosave(snapshot: Dictionary) -> bool:
	return save_to_path(snapshot, Balance.SAVE_PATH)


static func load_autosave() -> Dictionary:
	return load_from_path(Balance.SAVE_PATH)


static func has_autosave() -> bool:
	return FileAccess.file_exists(Balance.SAVE_PATH)


## Desktop export: `path` is a real filesystem path chosen via a native dialog.
static func export_to_path(snapshot: Dictionary, path: String) -> bool:
	return save_to_path(snapshot, path)


## Desktop import: `path` is a real filesystem path chosen via a native dialog.
static func import_from_path(path: String) -> Dictionary:
	return load_from_path(path)


static func status_message(status: int) -> String:
	match status:
		ImportStatus.OK: return "Loaded"
		ImportStatus.FILE_NOT_FOUND: return "File not found"
		ImportStatus.BAD_JSON: return "File is not valid JSON"
		ImportStatus.NOT_AN_OBJECT: return "File is not a save file"
		ImportStatus.MISSING_VERSION: return "Save file has no version"
		ImportStatus.UNSUPPORTED_VERSION: return "Save file version is not supported"
		_: return "Could not import"
