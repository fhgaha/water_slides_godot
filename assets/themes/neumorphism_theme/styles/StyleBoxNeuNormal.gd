@tool
class_name StyleBoxNeuNormal extends StyleBox

@export var compensate: bool = true
@export var style_boxes: Array[StyleBoxFlat] = []

func _draw(canvas_item: RID, rect: Rect2) -> void:
	for style_box: StyleBoxFlat in style_boxes:
		if style_box:
			var new_rect : Rect2
			match compensate:
				true:
					# compensate shadows sticking out
					new_rect= Rect2(
						rect.position.x + get_margin(SIDE_LEFT)/2,
						rect.position.y + get_margin(SIDE_TOP)/2,
						rect.size.x 	- get_margin(SIDE_RIGHT),
						rect.size.y 	- get_margin(SIDE_BOTTOM)
					)
				false:
					new_rect = rect
			
			style_box.draw(canvas_item, new_rect)
