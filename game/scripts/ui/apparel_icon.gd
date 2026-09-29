extends Control

const PawnVisual = preload("res://scripts/ui/pawn_visual.gd")

@export var item_id: String = "tshirt":
	set(value):
		item_id = value
		queue_redraw()

@export var tint: Color = Color("#527a81"):
	set(value):
		tint = value
		queue_redraw()


func _ready() -> void:
	custom_minimum_size = Vector2(36, 36)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS


func _draw() -> void:
	PawnVisual.draw_apparel_icon(self, size * 0.5, minf(size.x, size.y) * 0.86, item_id, tint)
