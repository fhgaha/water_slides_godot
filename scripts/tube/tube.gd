class_name Tube extends Node3D

enum BuildState {Idle, Building}

const TUBE_SEGMENT_SCENE = preload("res://scenes/tube_segment_0.tscn")

@export var cam_ctrlr: CameraController

@onready var segments: Node3D = $segments

#region building state
var build_state: BuildState = BuildState.Idle
var cur_building_segm: TubeSegment
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
			pass
		BuildState.Building:
			assert(cur_building_segm, "current building tube segment is null: %s" % cur_building_segm)
			var lmv: Vector2 = Input.get_last_mouse_velocity()
			if !lmv.is_zero_approx():
				# set end pos to mouse pos
				var length := 20
				var mouse_screen_position: Vector2 = get_viewport().get_mouse_position()
				var new_pos := cam_ctrlr.project_to_length(mouse_screen_position, length)
				cur_building_segm.end.position = new_pos

			if Input.is_action_just_pressed("lmb_clicked"):
				pass
			# use the signal
			elif Input.is_action_just_pressed("rmb_clicked"):
				# cancel build
				cur_building_segm.queue_free()
				cur_building_segm = null
				build_state = BuildState.Idle


func _on_segm_cp_was_lmb_clicked(
	_segm: TubeSegment, 
	cp: ControlPoint, 
	_data: ControlPoint.InputEventData
):
	match build_state:
		BuildState.Idle:
			# switch to building mode
			build_state = BuildState.Building
			cur_building_segm = spawn_new_segm(cp.global_position)
			cur_building_segm.end.position = cp.position
			cam_ctrlr.change_parent(cp)
			pass
		BuildState.Building:
			# switch to idle mode
			cur_building_segm = null
			build_state = BuildState.Idle
			pass
	pass
