@tool
class_name StyleBoxMulti extends StyleBox

@export var style_boxes: Array[StyleBox] = []

func _draw(canvas_item: RID, rect: Rect2) -> void:
	for style_box: StyleBox in style_boxes:
		if style_box:
			#compensate shadows sticking out
			var margined_rect:= Rect2(
				rect.position.x + content_margin_left,
				rect.position.y + content_margin_top/2,
				rect.size.x 	- content_margin_right,
				rect.size.y 	- content_margin_bottom
			)
			style_box.draw(canvas_item, margined_rect)
