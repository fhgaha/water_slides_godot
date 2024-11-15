@tool
class_name ControlPoint extends Node3D

signal local_transform_changed(sender: ControlPoint)

enum ControlPointState {None, Drag}

@export var display: bool:
	set(value):
		if !is_node_ready(): await ready
		display = value
		if display:	show_edge() 
		else: hide_edge()

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
var state = ControlPointState.None

func _ready():
	set_notify_local_transform(true)

func _notification(what: int) -> void:
	if what == Node3D.NOTIFICATION_LOCAL_TRANSFORM_CHANGED:
		local_transform_changed.emit(self)

func show_edge():
	mesh_instance.show()

func hide_edge():
	mesh_instance.hide()

func edge(shape: ExtrudeShape, path: Array[OrientedPoint], is_first: bool):
	var mesh = mesh_instance.mesh as ArrayMesh
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
	
	var base_op: OrientedPoint = path[0] if is_first else path[edge_loops - 1]
	base_op.pos = Vector3.ZERO
	var idx: int = 0
	# var normal = base_op.rot.get_euler()
	var normal: Vector3 = transform.basis.z

	for i in range(0, verts_in_shape - 2, 2): 
		vertices.set(idx, base_op.pos)
		normals .set(idx, normal)
		uvs     .set(idx, Vector2.DOWN)
		idx += 1
		# var point: Vector3 = base_op.local_to_world(Utils.vec2_extrude(shape.vertices[i + 1].point))
		var point: Vector3 = Utils.vec2_extrude(shape.vertices[i + 1].point)
		# var normal: Vector3 = last_op.local_to_world_direction(Utils.vec2_extrude(shape.vertices[i + 1].normal))
		vertices.set(idx, point)
		normals .set(idx, normal)
		uvs     .set(idx, Vector2(shape.vertices[i + 1].u, 1.))
		idx += 1
		# point = base_op.local_to_world(Utils.vec2_extrude(shape.vertices[i + 2].point))
		point = Utils.vec2_extrude(shape.vertices[i + 2].point)
		# normal = last_op.local_to_world_direction(Utils.vec2_extrude(shape.vertices[i + 2].normal))
		vertices.set(idx, point)
		normals .set(idx, normal)
		uvs     .set(idx, Vector2(shape.vertices[i + 2].u, 1.))
		idx += 1

	idx = 0
	if is_first:
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
