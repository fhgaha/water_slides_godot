@tool
class_name StyleBoxMulti extends StyleBox

@export var style_boxes: Array[StyleBox] = []

@export_group("Compensate shadows margins")
@export_range(0, 2048, 1, "suffix:px") var shadow_margin_left: int
@export_range(0, 2048, 1, "suffix:px") var shadow_margin_top: int
@export_range(0, 2048, 1, "suffix:px") var shadow_margin_right: int
@export_range(0, 2048, 1, "suffix:px") var shadow_margin_bottom: int

func _draw(canvas_item: RID, rect: Rect2) -> void:
	for style_box in style_boxes:
		if style_box:
			var r:= Rect2(
				rect.position.x + content_margin_left,
				rect.position.y,
				rect.size.x - content_margin_right,
				rect.size.y
			)
			style_box.draw(canvas_item, r)
