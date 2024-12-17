@tool
class_name StyleBoxMulti extends StyleBox

@export var style_boxes: Array[StyleBox] = []

func _draw(canvas_item: RID, rect: Rect2) -> void:
	for style_box in style_boxes:
		if style_box:
			style_box.draw(canvas_item, rect)
