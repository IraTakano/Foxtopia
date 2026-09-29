extends SceneTree


func _initialize() -> void:
	var game := GameModel.new()
	root.add_child(game)
	var test_dir := "foxtopia_test_saves_%d" % Time.get_ticks_usec()
	game.set("_save_directory_name", test_dir)
	var started := game.start_new_game({"seed": "save-management-regression", "scenario_id": "landfall"})
	assert(not started.is_empty())
	assert(game.has_unsaved_changes())
	assert(game.save_game("manual"))
	assert(not game.has_unsaved_changes())
	assert(not game.advance_autosave(61.0, 1.0, 2))
	game.tick(1.0)
	assert(game.has_unsaved_changes())
	assert(game.advance_autosave(61.0, 1.0, 2))
	var saves := game.list_saved_games()
	assert(saves.size() == 2)
	var autosaves := 0
	for saved in saves:
		if saved.get("is_autosave", false): autosaves += 1
	assert(autosaves == 1)
	game.tick(1.0)
	assert(game.advance_autosave(61.0, 1.0, 2))
	assert(game.list_saved_games().size() == 3)
	game.tick(1.0)
	assert(game.save_autosave(1))
	assert(game.list_saved_games().size() == 2)
	assert(game.load_game("manual"))
	assert(not game.has_unsaved_changes())
	assert(game.delete_saved_game("manual"))
	assert(game.has_unsaved_changes())
	assert(not game.delete_saved_game("../manual"))
	var directory := "user://%s" % test_dir
	var dir := DirAccess.open(directory)
	assert(dir != null)
	for filename in dir.get_files():
		assert(filename.begins_with("autosave_") and filename.ends_with(".json"))
		assert(DirAccess.remove_absolute(ProjectSettings.globalize_path("%s/%s" % [directory, filename])) == OK)
	assert(DirAccess.remove_absolute(ProjectSettings.globalize_path(directory)) == OK)
	print("SAVE_MANAGEMENT_REGRESSION_OK")
	quit()
