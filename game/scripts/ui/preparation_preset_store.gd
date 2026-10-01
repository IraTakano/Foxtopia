extends RefCounted

const CHARACTER_DIR := "user://prepared_characters"
const CREW_DIR := "user://preparation_presets"


static func directory(kind: String) -> String:
	return CHARACTER_DIR if kind == "character" else CREW_DIR


static func safe_id(display_name: String) -> String:
	var result := ""
	for character in display_name.strip_edges():
		if character in ["/", "\\", ":", "*", "?", "\"", "<", ">", "|", "."]:
			continue
		result += "_" if character == " " else character
	return result.left(48).strip_edges().trim_prefix("_").trim_suffix("_")


static func list_slots(kind: String) -> Array:
	_ensure_directory(kind)
	var result: Array = []
	var folder := DirAccess.open(directory(kind))
	if folder == null:
		return result
	for filename in folder.get_files():
		if not filename.ends_with(".json"):
			continue
		var id := filename.trim_suffix(".json")
		# Prior builds generated these placeholder imports on every library open.
		# Keep the files recoverable, but do not present them as player saves.
		if id == "old_character" or id == "old_crew":
			continue
		var record := load_slot(kind, id)
		if record.is_empty():
			continue
		result.append({"id": id, "name": str(record.get("name", id)), "saved_at": str(record.get("saved_at", ""))})
	result.sort_custom(func(a: Dictionary, b: Dictionary): return str(a["name"]).naturalnocasecmp_to(str(b["name"])) < 0)
	return result


static func load_slot(kind: String, id: String) -> Dictionary:
	if safe_id(id) != id:
		return {}
	var path := "%s/%s.json" % [directory(kind), id]
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if parsed is Dictionary and (parsed as Dictionary).get("data", null) is Dictionary:
		return parsed
	return {}


static func save_slot(kind: String, display_name: String, data: Dictionary) -> bool:
	var id := safe_id(display_name)
	if id.is_empty() or not _ensure_directory(kind):
		return false
	var file := FileAccess.open("%s/%s.json" % [directory(kind), id], FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify({"name": display_name.strip_edges(), "saved_at": Time.get_datetime_string_from_system(), "data": data}))
	return true


static func delete_slot(kind: String, id: String) -> bool:
	if safe_id(id) != id:
		return false
	return DirAccess.remove_absolute(ProjectSettings.globalize_path("%s/%s.json" % [directory(kind), id])) == OK


static func _ensure_directory(kind: String) -> bool:
	return DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory(kind))) == OK


static func _migrate_old_slot(kind: String) -> void:
	var old_path := "user://prepared_character.json" if kind == "character" else "user://preparation_preset.json"
	var marker_path := "%s/.legacy_imported" % directory(kind)
	if FileAccess.file_exists(marker_path):
		return
	if not FileAccess.file_exists(old_path):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(old_path))
	if not parsed is Dictionary:
		return
	var old_data: Dictionary = parsed
	if kind == "character" and not old_data.has("name"):
		return
	if kind == "crew" and not old_data.get("characters", null) is Array:
		return
	var old_id := "old_character" if kind == "character" else "old_crew"
	var imported := FileAccess.file_exists("%s/%s.json" % [directory(kind), old_id])
	if not imported:
		imported = save_slot(kind, old_id, old_data)
	if imported:
		var marker := FileAccess.open(marker_path, FileAccess.WRITE)
		if marker != null:
			marker.store_string("Legacy save imported once.\n")
