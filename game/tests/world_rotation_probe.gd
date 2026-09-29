extends SceneTree

const WorldView = preload("res://scripts/ui/world_view.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		print("WORLD_ROTATION_PROBE_SKIP_HEADLESS")
		quit()
		return
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	var world: Dictionary = root.get_node("Game").preview_world("rotation-performance-probe")
	var view := WorldView.new()
	root.add_child(view)
	view.size = Vector2(1200, 780)
	view.set_preview(world, str(world["sites"][0]["id"]))
	for _warmup in 20:
		view.rotate_by(0.013, 0.001)
		await RenderingServer.frame_post_draw
	var times: Array[float] = []
	for _sample in 120:
		var started := Time.get_ticks_usec()
		view.rotate_by(0.013, 0.001)
		await RenderingServer.frame_post_draw
		times.append(float(Time.get_ticks_usec() - started) / 1000.0)
	times.sort()
	var sum := 0.0
	for value in times:
		sum += value
	print("WORLD_ROTATION_PROBE frames=%d mean_ms=%.3f median_ms=%.3f p95_ms=%.3f" % [times.size(), sum / times.size(), times[times.size() / 2], times[int(times.size() * 0.95)]])
	quit()
