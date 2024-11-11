@tool
class_name TubeSegment extends Node3D

@export var draw: bool = false
@export var draw_line_gizmo: bool = false
@export var amnt = 10
@export var control_points: Array[Node3D]

var control_points_transforms: Array[Transform3D]:
	get:
		assert(control_points.all(func(cp: Node3D): return cp != null))
		var result: Array[Transform3D]
		result.assign(control_points.map(func(cp: Node3D): return cp.transform))
		return result

var control_points_positions: Array[Vector3]:
	get:
		assert(control_points.all(func(cp: Node3D): return cp != null))
		var result: Array[Vector3]
		result.assign(control_points.map(func(cp: Node3D): return cp.position))
		return result

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
var bez_ops: Array[OrientedPoint] = []

func get_pos(i: int) -> Vector3:
	return control_points[i].position

func _ready() -> void:
	DebugDraw3D.scoped_config().set_thickness(0.1)
	pass

func _physics_process(delta: float) -> void:
	create_bez_pts()
	generate_mesh()
	
	pass 


func create_bez_pts():
	DebugDraw3D.clear_all()
	if !draw: return
	
	var positions: Array[Vector3]
	positions.assign(
		control_points.map(func(cp: Node3D): return cp.position)
	)
	
	bez_ops.clear()
	for i in amnt:
		var t = i as float/(amnt - 1) as float
		var op: OrientedPoint = OrientedPoint.new() \
			.with_vals( 
				get_point(positions, t), 
				get_orientation_3d(control_points_positions, t, Vector3.UP) 
			)
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
	var uv_length_compensation: float = get_length_approx()/shape.calc_u_span()
	
	#gen code
	for i in path.size():
		var offset: int = i * verts_in_shape
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
			uvs.insert(id, Vector2(
				shape.vertices[j].u, 
				(i as float / edge_loops as float) * uv_length_compensation
			))
	
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
	
	##surface tool
	#var st = SurfaceTool.new()
	#st.begin(Mesh.PRIMITIVE_TRIANGLES)
	#for i in vert_count:
		#st.set_uv(uvs[i])
		#st.set_normal(normals[i])
		#st.add_vertex(vertices[i])
	#
	#st.generate_normals()
	##mesh = st.commit()
	#$MeshInstance3D.mesh = st.commit()


func get_point(pts: Array[Vector3], t: float) -> Vector3:
	var a: Vector3 = lerp(pts[0], pts[1], t)
	var b: Vector3 = lerp(pts[1], pts[2], t)
	var c: Vector3 = lerp(pts[2], pts[3], t)
	var d: Vector3 = lerp(a, b, t)
	var e: Vector3 = lerp(b, c, t)
	return lerp(d, e, t)

func get_tangent(pts: Array[Vector3], t: float) -> Vector3:
	var omt: float = 1 - t
	var omt2: float = omt * omt 
	var t2: float = t * t
	var tangent: Vector3 = \
		pts[0] * (-omt2) + \
		pts[1] * ( 3 * omt2 - 2 * omt) + \
		pts[2] * (-3 * t2 + 2 * t) + \
		pts[3] * t2
	return tangent.normalized()

func get_normal_2d(pts: Array[Vector3], t: float) -> Vector3:
	var tng: Vector3 = get_tangent(pts, t)
	return Vector3( -tng.y, tng.x, 0.0)

func get_normal_3d(pts: Array[Vector3], t: float, up: Vector3) -> Vector3:
	var tng: Vector3 = get_tangent(pts, t)
	var binormal: Vector3 = up.cross(tng).normalized()
	return tng.cross(binormal)

func get_orientation_2d(pts: Array[Vector3], t: float) -> Quaternion:
	var tng: Vector3 = get_tangent(pts, t)
	var nrm: Vector3 = get_normal_2d(pts, t)
	return quaternion_look_rotation(tng, nrm)

func get_orientation_3d(pts: Array[Vector3], t: float, up: Vector3) -> Quaternion:
	var tng: Vector3 = get_tangent(pts, t)
	var nrm: Vector3 = get_normal_3d(pts, t, up)
	return quaternion_look_rotation(tng, nrm)

func quaternion_look_rotation(forward: Vector3, up: Vector3) -> Quaternion:
	return Quaternion.from_euler(
		Transform3D.IDENTITY.looking_at(forward, up).basis.get_euler()
	)

func get_length_approx() -> float:
	const PRESCISION = 8
	var points: Array[Vector3] = []
	
	for i in PRESCISION:
		var t = i as float / (PRESCISION - 1) as float
		var pt: Vector3 = get_point(control_points_positions, t)
		points.append(pt)
	
	var dist: float = 0.
	for i in PRESCISION - 1:
		var a = points[i];
		var b = points[i + 1];
		dist += (a - b).length()
	
	return dist

#Create a lookup-table containing cumulative point distances
func calc_length_table_into(arr: Array[float], bezier: CubicBezier3d):
	arr[0] = 0.
	var total_length: float = 0.
	var prev: Vector3 = bezier.p0
	for i in arr.size():
		var t = (i as float)/(arr.size() - 1)
		var pt = bezier.get_point(t)
		var diff: float = (prev - pt).length()
		total_length += diff
		arr[i] = total_length
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
