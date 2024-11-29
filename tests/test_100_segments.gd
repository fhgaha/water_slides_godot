extends Node

@export var SEGMENT_SCENE: PackedScene

func _ready():
	for i in range(0, 100):
		var segm: TubeSegment = SEGMENT_SCENE.instantiate()
		$tube_0/segments.add_child(segm)
		var x_offset := (i + 1) * 3
		segm.start.position.x = x_offset
		segm.end.position.x = x_offset
