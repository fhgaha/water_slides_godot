class_name Tube extends Node3D

const TUBE_SEGMENT_SCENE = preload("res://scenes/tube_segment_0.tscn")

@export var cam: CameraController
@onready var segments: Node3D = $segments


func _input(event: InputEvent) -> void:
	react_to_lmb(event)


func react_to_lmb(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_screen_position: Vector2 = event.position
		var result: Dictionary = cam.raycast(mouse_screen_position)
		if result && result.collider is ControlPointRaycastTarget:
			var cp_rc_trg = result.collider as ControlPointRaycastTarget
			prints("found raycast target:", cp_rc_trg)

			# action
			spawn_new_segm(cp_rc_trg.cp_parent.global_position)

			# var mesh_inst = MeshInstance3D.new()
			# mesh_inst.mesh = BoxMesh.new()
			# add_child(mesh_inst)
			# mesh_inst.global_position = cp_rc_trg.cp_parent.global_position


func spawn_new_segm(spawn_global_pos: Vector3):
	var new_segm: TubeSegment = TUBE_SEGMENT_SCENE.instantiate()
	segments.add_child(new_segm)
	# new_segm.name = "tube_segment_1"
	new_segm.start.global_position = spawn_global_pos
	var some_offset: Vector3 = Vector3.FORWARD * 10 + Vector3.DOWN * 10
	new_segm.end.global_position = spawn_global_pos + some_offset
