extends Control

const PawnVisual = preload("res://scripts/ui/pawn_visual.gd")

var appearance: Dictionary = {"hair": "short", "hair_color": "#4d3c32", "skin": "#d9ad81", "outfit": "#527a81"}


func _ready() -> void:
	custom_minimum_size = Vector2(130, 146)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_appearance(next_appearance: Dictionary) -> void:
	appearance = next_appearance
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("#34534b"))
	draw_rect(Rect2(0, size.y * 0.77, size.x, size.y * 0.23), Color("#547454"))
	PawnVisual.draw_pawn(self, size * Vector2(0.5, 0.49), minf(size.x, size.y) * 0.69, appearance, false, false, false)
	draw_rect(Rect2(Vector2.ZERO, size), Color("#b4c2ad", 0.38), false, 1.0)
