@tool
class_name StyleBoxNeuPressed extends StyleBox

@export var style_boxes: Array[StyleBoxFlat] = []

func _draw(canvas_item: RID, rect: Rect2) -> void:
	for style_box: StyleBoxFlat in style_boxes:
		if style_box:
			style_box.draw(canvas_item, rect)
			# not compensating shadows sticking out here cause we are able 
			# to use content margin to position the internal text this way
	