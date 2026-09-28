extends SceneTree

const SOURCE := "res://assets/foxtopia_mark.svg"
const PNG_OUTPUT := "res://assets/foxtopia_icon_256.png"
const ICO_OUTPUT := "res://assets/foxtopia.ico"
const ICON_SIZES := [16, 24, 32, 48, 64, 128, 256]


func _initialize() -> void:
	var source := FileAccess.get_file_as_bytes(SOURCE)
	if source.is_empty():
		push_error("Icon SVG is missing: " + SOURCE)
		quit(1)
		return
	var layers: Array[PackedByteArray] = []
	for icon_size in ICON_SIZES:
		var image := Image.new()
		var load_error := image.load_svg_from_buffer(source, float(icon_size) / 96.0)
		if load_error != OK or image.get_width() != icon_size or image.get_height() != icon_size:
			push_error("Could not render SVG at %d pixels." % icon_size)
			quit(1)
			return
		image.convert(Image.FORMAT_RGBA8)
		if icon_size == 256:
			if image.save_png(PNG_OUTPUT) != OK:
				push_error("Could not save " + PNG_OUTPUT)
				quit(1)
				return
			layers.append(image.save_png_to_buffer())
		else:
			layers.append(_dib_layer(image, icon_size))
	var icon := PackedByteArray()
	_u16(icon, 0)
	_u16(icon, 1)
	_u16(icon, layers.size())
	var offset := 6 + layers.size() * 16
	for index in layers.size():
		var icon_size: int = ICON_SIZES[index]
		icon.append(icon_size % 256)
		icon.append(icon_size % 256)
		icon.append(0) # Palette entries, unused for truecolour.
		icon.append(0)
		_u16(icon, 1)
		_u16(icon, 32)
		_u32(icon, layers[index].size())
		_u32(icon, offset)
		offset += layers[index].size()
	for layer in layers:
		icon.append_array(layer)
	var output := FileAccess.open(ICO_OUTPUT, FileAccess.WRITE)
	if output == null:
		push_error("Could not save " + ICO_OUTPUT)
		quit(1)
		return
	output.store_buffer(icon)
	output.close()
	print("ICON_BUILD_OK 16,24,32,48,64,128,256")
	quit(0)


func _dib_layer(image: Image, icon_size: int) -> PackedByteArray:
	# Classic 32-bit DIBs remain readable by the Windows shell at small sizes.
	var mask_stride := ((icon_size + 31) / 32) * 4
	var bitmap := PackedByteArray()
	_u32(bitmap, 40) # BITMAPINFOHEADER
	_u32(bitmap, icon_size)
	_u32(bitmap, icon_size * 2) # Colour image plus 1-bit transparency mask.
	_u16(bitmap, 1)
	_u16(bitmap, 32)
	_u32(bitmap, 0)
	_u32(bitmap, icon_size * icon_size * 4 + mask_stride * icon_size)
	for _unused in 4:
		_u32(bitmap, 0)
	var rgba := image.get_data()
	var mask := PackedByteArray()
	mask.resize(mask_stride * icon_size)
	for row in icon_size:
		for x in icon_size:
			var input_index := ((icon_size - 1 - row) * icon_size + x) * 4
			bitmap.append(rgba[input_index + 2])
			bitmap.append(rgba[input_index + 1])
			bitmap.append(rgba[input_index])
			bitmap.append(rgba[input_index + 3])
			if rgba[input_index + 3] < 128:
				var mask_index := row * mask_stride + x / 8
				mask[mask_index] = mask[mask_index] | (1 << (7 - x % 8))
	bitmap.append_array(mask)
	return bitmap


func _u16(output: PackedByteArray, value: int) -> void:
	output.append(value & 255)
	output.append((value >> 8) & 255)


func _u32(output: PackedByteArray, value: int) -> void:
	for index in 4:
		output.append((value >> (index * 8)) & 255)
