extends RefCounted

## Shared rendering API for map pawns, portraits, preparation preview, and
## clothing icons. The artwork itself lives in smooth_pawn.gd.
const SmoothPawn = preload("res://scripts/ui/smooth_pawn.gd")
const MALE_HAIR := ["short", "sidepart", "curly", "shaved"]
const FEMALE_HAIR := ["bob", "wavy", "long", "braid"]
const SHIRT_ID := "tshirt"
const PANTS_ID := "pants"


static func hair_options(sex: String) -> Array:
	return FEMALE_HAIR.duplicate() if sex == "female" else MALE_HAIR.duplicate()


static func draw_pawn(canvas: CanvasItem, center: Vector2, diameter: float, appearance: Dictionary, selected: bool = false, enemy: bool = false, drafted: bool = false) -> void:
	SmoothPawn.draw_pawn(canvas, center, diameter, appearance, selected, enemy, drafted)


static func draw_apparel_icon(canvas: CanvasItem, center: Vector2, size: float, item_id: String, tint: Color) -> void:
	SmoothPawn.draw_apparel_icon(canvas, center, size, item_id, tint)
