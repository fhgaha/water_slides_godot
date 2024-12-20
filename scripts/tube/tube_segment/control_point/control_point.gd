@tool
class_name ControlPoint extends Node3D

class InputEventData:
	var camera: Node
	var event: InputEvent 
	var event_position: Vector3 
	var normal: Vector3
	var shape_idx: int

	static func ctor(
		camera: Node, 
		event: InputEvent, 
		event_position: Vector3, 
		normal: Vector3, 
		shape_idx: int
	):
		var data := InputEventData.new()
		data.camera = camera
		data.event = event
		data.event_position = event_position
		data.normal = normal
		data.shape_idx = shape_idx
		return data

	func print():
		prints(
			"raycast trg recieved input event:",
			"\n\tcamera:", camera,
			"\n\tevent:", event,
			"\n\tevent_position:", event_position,
			"\n\tnormal:", normal, 
			"\n\tshape_idx:", shape_idx
		)
	
	func print_if_lmb_clicked():
		if event is InputEventMouseButton && event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
			prints(
				"raycast trg lmb click event:",
				"\n\tcamera:", camera,
				"\n\tevent:", event,
				"\n\tevent_position:", event_position,
				"\n\tnormal:", normal, 
				"\n\tshape_idx:", shape_idx
			)
		else:
			prints("raycast trg wasn't lmb clicked!")


signal regenerate_segment_request(sender: ControlPoint)
signal was_lmb_clicked(sender: ControlPoint, data: InputEventData)

@export var display: bool:
	set(value):
		if !is_node_ready(): await ready
		display = value
		if display:	show_edge() 
		else: hide_edge()

@export var nearest_cp_z_offest: float = 3.:
	set(value):
		nearest_cp_z_offest = value
		regenerate_segment_request.emit(self)

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D


func show_edge():
	mesh_instance.show()

func hide_edge():
	mesh_instance.hide()


func edge(shape: ExtrudeShape, path: Array[OrientedPoint]):
	if !is_node_ready(): await ready
	var mesh = mesh_instance.mesh as ArrayMesh
	if mesh.get_surface_count() != 0: return
	
	var is_start: bool 
	match name:
		"start": is_start = true
		"end": is_start = false
		_:	push_error("Name should be either start or end!: %s" % name)

	mesh.clear_surfaces()
	
	var verts_in_shape: int = shape.vertex_count()	#16
	var edge_loops: int = path.size()
	var edge_verts_amnt: int = (verts_in_shape - 1) / 2 * 3	# 21

	var triangle_indices = PackedInt32Array()  
	var vertices         = PackedVector3Array()
	var normals          = PackedVector3Array()
	var uvs              = PackedVector2Array()
	triangle_indices.resize(edge_verts_amnt + 3)
	vertices        .resize(edge_verts_amnt)
	normals         .resize(edge_verts_amnt)
	uvs             .resize(edge_verts_amnt)
	
	var base_op: OrientedPoint = path[0] if is_start else path[edge_loops - 1]
	var idx: int = 0
	var normal = base_op.rot.get_euler()
	# var normal: Vector3 = self.rotation

	for i in range(0, verts_in_shape - 2, 2): 
		vertices.set(idx, Vector3.ZERO)
		normals .set(idx, normal)
		uvs     .set(idx, Vector2.DOWN)
		idx += 1
		var point: Vector3 = Utils.vec2_extrude(shape.vertices[i + 1].point)
		vertices.set(idx, point)
		normals .set(idx, normal)
		uvs     .set(idx, Vector2(shape.vertices[i + 1].u, 1.))
		idx += 1
		point = Utils.vec2_extrude(shape.vertices[i + 2].point)
		vertices.set(idx, point)
		normals .set(idx, normal)
		uvs     .set(idx, Vector2(shape.vertices[i + 2].u, 1.))
		idx += 1

	idx = 0
	if is_start:
		for l in range(0, edge_verts_amnt, 3):
			triangle_indices.set(idx, l  ); idx += 1;
			triangle_indices.set(idx, l+2); idx += 1;	# flip if not is_first
			triangle_indices.set(idx, l+1); idx += 1;	# flip if not is_first

		# last triangle
		triangle_indices.set(idx, 0                  ); idx += 1;
		triangle_indices.set(idx, 1                  ); idx += 1;	# flip if not is_first
		triangle_indices.set(idx, edge_verts_amnt - 1); idx += 1;	# flip if not is_first
	else:
		for l in range(0, edge_verts_amnt, 3):
			triangle_indices.set(idx, l  ); idx += 1;
			triangle_indices.set(idx, l+1); idx += 1;
			triangle_indices.set(idx, l+2); idx += 1;

		# last triangle
		triangle_indices.set(idx, 0                  ); idx += 1;
		triangle_indices.set(idx, edge_verts_amnt - 1); idx += 1;
		triangle_indices.set(idx, 1                  ); idx += 1;

	# prints("vertex:", le_vertices.size(), "uvs:", le_uvs.size(), \
	# "normals:", le_normals.size(), "indices:", le_triangle_indices.size())
	# vertex: 21 uvs: 21 normals: 21 indices: 24
	
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	surface_array[Mesh.ARRAY_VERTEX] = vertices
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX]  = triangle_indices
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)


func _ready():
	set_notify_local_transform(true)
	var mesh = mesh_instance.mesh as ArrayMesh
	mesh.clear_surfaces()

	var raycast_target = $raycast_trg as ControlPointRaycastTarget
	raycast_target.register_contol_point(self)

	hide_edge()

	raycast_target.mouse_entered.connect(show_edge)
	raycast_target.mouse_exited.connect(hide_edge)

	raycast_target.input_event.connect(_on_raycast_trg_lmb_clicked)


func _notification(what: int) -> void:
	if what == Node3D.NOTIFICATION_LOCAL_TRANSFORM_CHANGED:
		regenerate_segment_request.emit(self)


func _on_raycast_trg_lmb_clicked(
	camera: Node, 
	event: InputEvent, 
	event_position: Vector3, 
	normal: Vector3, 
	shape_idx: int
):
	if event is InputEventMouseButton && event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
		was_lmb_clicked.emit(
			self, 
			InputEventData.ctor(
				camera, 
				event, 
				event_position, 
				normal, 
				shape_idx
			)
		)
