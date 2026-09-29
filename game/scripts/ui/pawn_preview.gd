extends Control

const PawnVisual = preload("res://scripts/ui/pawn_visual.gd")

var appearance: Dictionary = {"hair": "short", "hair_color": "#4d3c32", "skin": "#d9ad81", "outfit": "#527a81"}


func _ready() -> void:
	custom_minimum_size = Vector2(130, 146)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS


func set_appearance(next_appearance: Dictionary) -> void:
	appearance = next_appearance
	queue_redraw()


func _draw() -> void:
	# The quiet inset background lets hair, skin and outfit colours read clearly.
	draw_rect(Rect2(Vector2.ZERO, size), Color("#394b47"))
	draw_rect(Rect2(0, size.y * 0.73, size.x, size.y * 0.27), Color("#455c4e"))
	draw_line(Vector2(0, size.y * 0.73), Vector2(size.x, size.y * 0.73), Color("#78866d", 0.28), 1.0)
	PawnVisual.draw_pawn(self, size * Vector2(0.5, 0.45), minf(size.x, size.y) * 0.79, appearance)
	draw_rect(Rect2(Vector2.ZERO, size), Color("#a9b4a5", 0.35), false, 1.0)
