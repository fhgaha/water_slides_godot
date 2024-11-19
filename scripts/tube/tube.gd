class_name Tube extends Node3D

enum BuildState {Idle, Building}

const TUBE_SEGMENT_SCENE = preload("res://scenes/tube_segment_0.tscn")

@export var cam: CameraController

@onready var segments: Node3D = $segments

#region building state
var build_state: BuildState = BuildState.Idle
var cur_building_segm: TubeSegment
var action_queue: Array[Callable] = []
#endregion

func add_segm(segm: TubeSegment):
	segments.add_child(segm)
	segm.start_was_lmb_clicked.connect(_on_segm_cp_was_lmb_clicked)
	segm.end_was_lmb_clicked.connect(_on_segm_cp_was_lmb_clicked)


func remove_segm(segm: TubeSegment):
	segm.start_was_lmb_clicked.disconnect(_on_segm_cp_was_lmb_clicked)
	segm.end_was_lmb_clicked.disconnect(_on_segm_cp_was_lmb_clicked)
	segments.remove_child(segm)
	segm.queue_free()


func _ready():
	for segm: TubeSegment in segments.get_children():
		segm.start_was_lmb_clicked.connect(_on_segm_cp_was_lmb_clicked)
		segm.end_was_lmb_clicked.connect(_on_segm_cp_was_lmb_clicked)
	pass

# 1. click on end, start dragging, generate on cursor move
# 2. if lmb, spawn new segment. if rmb, reset. 

func _input(event: InputEvent) -> void:
	return
	
	match build_state:
		BuildState.Idle:
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				action_queue.append(react_to_lmb_when_idle.bind(event))
			
		BuildState.Building:
			assert(cur_building_segm, "current building tube segment is null: %s" % cur_building_segm)
			if event is InputEventMouseMotion:
				action_queue.append(react_to_mouse_motion_when_building.bind(event))

			react_to_mouse_button_when_building(event)


func react_to_lmb_when_idle(event: InputEvent):
	var mouse_screen_position: Vector2 = event.position
	var result: Dictionary = cam.raycast(mouse_screen_position)
	prints("result:", result)
	if result && result.collider is ControlPointRaycastTarget:
		var cp_rc_trg = result.collider as ControlPointRaycastTarget
		prints("found raycast target:", cp_rc_trg)

		# action
		cur_building_segm = spawn_new_segm(cp_rc_trg.cp_parent.global_position)
		build_state = BuildState.Building
		action_queue.append(react_to_mouse_motion_when_building.bind(event))

		# cube spawn
		# var mesh_inst = MeshInstance3D.new()
		# mesh_inst.mesh = BoxMesh.new()
		# add_child(mesh_inst)
		# mesh_inst.global_position = cp_rc_trg.cp_parent.global_position


func react_to_mouse_motion_when_building(event: InputEvent):
	var mouse_screen_position: Vector2 = event.position
	
	# this should be run in _physics_process()
	var length := 20
	var new_pos := cam.project_to_length(mouse_screen_position, length)
	cur_building_segm.end.position = new_pos


func react_to_mouse_button_when_building(event: InputEvent):
	if event is InputEventMouseButton and event.pressed: 
		match event.button_index: 
			MOUSE_BUTTON_LEFT:
				cur_building_segm = null
				build_state = BuildState.Idle
			MOUSE_BUTTON_RIGHT:
				cur_building_segm.queue_free()
				cur_building_segm = null
				build_state = BuildState.Idle
		pass


func spawn_new_segm(spawn_global_pos: Vector3) -> TubeSegment:
	var new_segm: TubeSegment = TUBE_SEGMENT_SCENE.instantiate()
	add_segm(new_segm)
	# new_segm.name = "tube_segment_1"
	new_segm.start.global_position = spawn_global_pos
	var some_offset: Vector3 = Vector3.FORWARD * 10 + Vector3.DOWN * 10
	new_segm.end.global_position = spawn_global_pos + some_offset
	return new_segm


func _physics_process(_delta):
	update_in_physics_process()
	pass


func update_in_physics_process():
	match build_state:
		BuildState.Idle:
			# if Input.is_action_just_pressed("lmb_clicked"):
			# 	var mouse_screen_position: Vector2 = get_viewport().get_mouse_position()
			# 	var result: Dictionary = cam.raycast(mouse_screen_position)
			# 	prints("result:", result)
			# 	if result && result.collider is ControlPointRaycastTarget:
			# 		# raycasted succsessfully
			# 		var cp_rc_trg = result.collider as ControlPointRaycastTarget
			# 		prints("found raycast target:", cp_rc_trg)

			# 		# build mode on
			# 		cur_building_segm = spawn_new_segm(cp_rc_trg.cp_parent.global_position)
			# 		build_state = BuildState.Building
					
			# 		var length := 20
			# 		var new_pos := cam.project_to_length(mouse_screen_position, length)
			# 		cur_building_segm.end.position = new_pos
			# 	pass

			pass
		BuildState.Building:
			assert(cur_building_segm, "current building tube segment is null: %s" % cur_building_segm)
			var lmv: Vector2 = Input.get_last_mouse_velocity()
			if !lmv.is_zero_approx():
				# handle mouse motion
				var length := 20
				var mouse_screen_position: Vector2 = get_viewport().get_mouse_position()
				var new_pos := cam.project_to_length(mouse_screen_position, length)
				cur_building_segm.end.position = new_pos

			if Input.is_action_just_pressed("lmb_clicked"):
				# # confirm build
				# cur_building_segm = null
				# build_state = BuildState.Idle
				pass
			elif Input.is_action_just_pressed("rmb_clicked"):
				# cancel build
				cur_building_segm.queue_free()
				cur_building_segm = null
				build_state = BuildState.Idle


func _on_segm_cp_was_lmb_clicked(
	segm: TubeSegment, 
	cp: ControlPoint, 
	data: ControlPoint.InputEventData
):
	match build_state:
		BuildState.Idle:
			# switch to building
			# build mode on
			cur_building_segm = spawn_new_segm(cp.global_position)
			build_state = BuildState.Building
			
			var length := 20
			# var new_pos := cam.project_to_length(mouse_screen_position, length)
			var new_pos = cp.position
			cur_building_segm.end.position = new_pos

			pass
		BuildState.Building:
			cur_building_segm = null
			build_state = BuildState.Idle

			pass

	pass