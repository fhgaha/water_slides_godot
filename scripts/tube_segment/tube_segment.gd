@tool
class_name TubeSegment extends Node3D

@export var draw: bool = false
@export var draw_line_gizmo: bool = false
@export var amnt = 10
@export var start: Node3D
@export var end: Node3D
 
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
var bez_ops: Array[OrientedPoint] = []
var bezier: CubicBezier3d

func _ready() -> void:
	DebugDraw3D.scoped_config().set_thickness(0.1)
	bezier = CubicBezier3d.new()

func _physics_process(delta: float) -> void:
	create_bez_pts()
	generate_mesh()

func create_bez_pts():
	DebugDraw3D.clear_all()
	if !draw: return
	
	bezier = bezier.with_2_control_points(start, end)
	
	bez_ops.clear()
	for i in amnt:
		var t = i as float/(amnt - 1) as float
		var up: Vector3 = lerp(start.basis.y, end.basis.y, t)
		var op: OrientedPoint = bezier.get_oriented_pt(t, up)
		bez_ops.append(op)
	
	if draw_line_gizmo:
		var arr: Array = bez_ops.map(func(op: OrientedPoint): return op.pos)
		DebugDraw3D.draw_line_path(arr)


func generate_mesh():
	var mesh = mesh_instance_3d.mesh as ArrayMesh
	mesh.clear_surfaces()
	
	if draw:
		var shape = ExtrudeShape.circle_8()
		extrude(mesh, shape, bez_ops)

func extrude(mesh: ArrayMesh, shape: ExtrudeShape, path: Array[OrientedPoint]):
	var verts_in_shape: int = shape.vertex_count()
	var segments: int = path.size() - 1
	var edge_loops: int = path.size()
	var vert_count: int = shape.vertex_count() * edge_loops
	var tri_count: int = shape.line_count() * segments
	var tri_index_count: int = tri_count * 3
	
	var triangle_indices = PackedInt32Array()  
	var vertices         = PackedVector3Array()
	var normals          = PackedVector3Array()
	var uvs              = PackedVector2Array()
	triangle_indices.resize(tri_index_count)
	vertices        .resize(vert_count)
	normals         .resize(vert_count)
	uvs             .resize(vert_count)
	
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	
	var look_up: Array[float] = []
	look_up.resize(edge_loops)
	calc_length_table_into(look_up, bezier)
	
	#gen code
	for i in edge_loops:
		var offset: int = i * verts_in_shape
		var v_length: float = sample(look_up, (i as float) / edge_loops)
		for j in verts_in_shape:
			var id: int = offset + j
			vertices.insert(
				id, 
				path[i].local_to_world(
					Utils.vec2_extrude(shape.vertices[j].point)
			))
			normals.insert(
				id,
				path[i].local_to_world_direction(
					Utils.vec2_extrude(shape.vertices[j].normal)
			))
			uvs.insert(id, Vector2(shape.vertices[j].u, v_length))
	
	var ti: int = 0
	for i in segments:
		var offset: int = i * verts_in_shape
		for l in range(0, shape.line_count(), 2):
			var a: int = offset + shape.line_indices[l] + verts_in_shape
			var b: int = offset + shape.line_indices[l]
			var c: int = offset + shape.line_indices[l + 1]
			var d: int = offset + shape.line_indices[l + 1] + verts_in_shape
			triangle_indices.set(ti, a); ti += 1;
			triangle_indices.set(ti, b); ti += 1;
			triangle_indices.set(ti, c); ti += 1;
			triangle_indices.set(ti, c); ti += 1;
			triangle_indices.set(ti, d); ti += 1;
			triangle_indices.set(ti, a); ti += 1;
	
	##array mesh
	surface_array[Mesh.ARRAY_VERTEX] = vertices
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX]  = triangle_indices
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)

func get_length_approx() -> float:
	const PRESCISION = 8
	var points: Array[Vector3] = []
	
	for i in PRESCISION:
		var t = i as float / (PRESCISION - 1) as float
		var pt: Vector3 = bezier.get_point(t)
		points.append(pt)
	
	var dist: float = 0.
	for i in PRESCISION - 1:
		var a = points[i];
		var b = points[i + 1];
		dist += (a - b).length()
	
	return dist

#Create a lookup-table containing cumulative point distances
func calc_length_table_into(to_fill: Array[float], bezier: CubicBezier3d):
	to_fill[0] = 0.
	var total_length: float = 0.
	var prev: Vector3 = bezier.pts[0]
	for i in to_fill.size():
		var t: float = (i as float)/(to_fill.size() - 1)
		var pt: Vector3 = bezier.get_point(t)
		var diff: float = (prev - pt).length()
		total_length += diff
		to_fill[i] = total_length
		prev = pt

#Sample the length array at t
func sample(f_arr: Array[float], t: float) -> float:
	var count: float = f_arr.size()
	if count == 0:
		push_error("Unable to sample array - it has no elements")
		return 0.
	if count == 1:
		return f_arr[0]
	var i_float: float = t * (count - 1)
	var id_lower: int = floori(i_float)
	var id_upper: int = floori(i_float + 1)
	if id_upper >= count:
		return f_arr[count - 1]
	if id_lower < 0:
		return f_arr[0]
	return lerpf(f_arr[id_lower], f_arr[id_upper], i_float - id_lower)
