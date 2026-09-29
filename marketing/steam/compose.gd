extends SceneTree

# Rebuild the exact-size Steam artwork from the original generated paintings
# and the game's vector-derived, transparent Foxtopia logo.
func _initialize() -> void:
	call_deferred("_compose")


func _compose() -> void:
	var args := OS.get_cmdline_user_args()
	if args.is_empty():
		push_error("Pass the marketing/steam directory after --.")
		quit(1)
		return
	var folder: String = args[0]
	var logo := _load_image(folder.path_join("foxtopia-logo-1280x720.png"))
	if logo == null:
		quit(1)
		return
	var logo_content := logo.get_region(logo.get_used_rect())

	var vertical := _load_image(folder.path_join("source/vertical-art.png"))
	var panorama := _load_image(folder.path_join("source/panorama-art.png"))
	var wide := _load_image(folder.path_join("source/wide-art.png"))
	if vertical == null or panorama == null or wide == null:
		quit(1)
		return

	vertical.resize(600, 900, Image.INTERPOLATE_LANCZOS)
	_blend_logo(vertical, logo_content, 535, Vector2i(32, 90))
	if vertical.save_png(folder.path_join("foxtopia-cover-600x900.png")) != OK:
		push_error("Unable to save vertical Steam cover.")
		quit(1)
		return

	panorama.resize(3840, 1240, Image.INTERPOLATE_LANCZOS)
	if panorama.save_png(folder.path_join("foxtopia-background-3840x1240.png")) != OK:
		push_error("Unable to save panoramic Steam background.")
		quit(1)
		return

	wide.resize(920, 430, Image.INTERPOLATE_LANCZOS)
	_blend_logo(wide, logo_content, 412, Vector2i(478, 93))
	if wide.save_png(folder.path_join("foxtopia-wide-cover-920x430.png")) != OK:
		push_error("Unable to save wide Steam cover.")
		quit(1)
		return

	print("STEAM_ART_OK: 600x900, 3840x1240, 1280x720, 920x430")
	quit()


func _load_image(path: String) -> Image:
	var loaded := Image.new()
	var error := loaded.load(path)
	if error != OK:
		push_error("Unable to load artwork %s (%d)." % [path, error])
		return null
	return loaded


func _blend_logo(canvas: Image, original: Image, width: int, destination: Vector2i) -> void:
	var scaled := original.duplicate() as Image
	var height := roundi(float(original.get_height()) * float(width) / float(original.get_width()))
	scaled.resize(width, height, Image.INTERPOLATE_LANCZOS)
	canvas.convert(Image.FORMAT_RGBA8)
	scaled.convert(Image.FORMAT_RGBA8)
	canvas.blend_rect(scaled, Rect2i(Vector2i.ZERO, scaled.get_size()), destination)
