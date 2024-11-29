extends Node

@export var SEGMENT_SCENE: PackedScene

func _ready():
	for i in range(0, 1):
		var segm: TubeSegment = SEGMENT_SCENE.instantiate()
		$tube_0/segments.add_child(segm)
		segm.start.position.x = i * 30
		segm.end.position.x   = i * 30