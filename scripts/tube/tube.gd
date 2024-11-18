class_name Tube extends Node3D

enum BuildState {Idle, Building}

const TUBE_SEGMENT_SCENE = preload("res://scenes/tube_segment_0.tscn")

@export var cam: CameraController

@onready var segments: Node3D = $segments

var build_state: BuildState = BuildState.Idle
var cur_building_segm: TubeSegment

# 1. click on end, start dragging, generate on cursor move
# 2. if lmb, spawn new segment. if rmb, reset. 

func _input(event: InputEvent) -> void:
	match build_state:
		BuildState.Idle:
			react_to_lmb_when_idle(event)
			pass
		BuildState.Building:
			assert(cur_building_segm, "current building tube segment is null: %s" % cur_building_segm)
			if event is InputEventMouseMotion:
				var mouse_screen_position: Vector2 = event.position
				var z_offset: Vector3 = cur_building_segm.start.position + Vector3.FORWARD * 10
				# var mouse_world_position: Vector3 \
					# = Utils.vec2_extrude(mouse_screen_position) + z_offset
				# cur_building_segm.end.global_position = mouse_world_position
				# var new_pos_no_offset = cam.project_to_screen(
				# 	mouse_screen_position, 
				# 	cur_building_segm.start.global_position
				# )
				var new_pos_no_offset = cam.project_to_screen(mouse_screen_position)
				var new_pos = new_pos_no_offset #- z_offset
				cur_building_segm.end.position = new_pos

				prints("mouse pos: %s, world pos: %s" % [mouse_screen_position, new_pos])

			# prints("start: %s, end %s" % [
			# 	cur_building_segm.start.global_position, 
			# 	cur_building_segm.end.global_position
			# ])
			pass



func react_to_lmb_when_idle(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_screen_position: Vector2 = event.position
		var result: Dictionary = cam.raycast(mouse_screen_position)
		if result && result.collider is ControlPointRaycastTarget:
			var cp_rc_trg = result.collider as ControlPointRaycastTarget
			prints("found raycast target:", cp_rc_trg)

			# action
			cur_building_segm = spawn_new_segm(cp_rc_trg.cp_parent.global_position)
			build_state = BuildState.Building

			# var mesh_inst = MeshInstance3D.new()
			# mesh_inst.mesh = BoxMesh.new()
			# add_child(mesh_inst)
			# mesh_inst.global_position = cp_rc_trg.cp_parent.global_position


func spawn_new_segm(spawn_global_pos: Vector3) -> TubeSegment:
	var new_segm: TubeSegment = TUBE_SEGMENT_SCENE.instantiate()
	segments.add_child(new_segm)
	# new_segm.name = "tube_segment_1"
	new_segm.start.global_position = spawn_global_pos
	var some_offset: Vector3 = Vector3.FORWARD * 10 + Vector3.DOWN * 10
	new_segm.end.global_position = spawn_global_pos + some_offset
	return new_segm


func _physics_process(delta):
	match build_state:
		BuildState.Idle:
			pass
		BuildState.Building:
			pass

	# prints("build state:", BuildState.keys()[build_state])

	pass
