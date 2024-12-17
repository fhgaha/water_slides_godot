@tool
class_name StyleBoxMulti extends StyleBox

@export var style_boxes: Array[StyleBox] = []

func _draw(canvas_item: RID, rect: Rect2) -> void:
	for style_box: StyleBox in style_boxes:
		if style_box:
			#compensate shadows sticking out
			var margined_rect:= Rect2(
				rect.position.x + get_margin(SIDE_LEFT),
				rect.position.y + get_margin(SIDE_TOP)/2,
				rect.size.x 	- get_margin(SIDE_RIGHT),
				rect.size.y 	- get_margin(SIDE_BOTTOM)
			)
			style_box.draw(canvas_item, margined_rect)
