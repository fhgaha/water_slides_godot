@tool
class_name TubeSegment extends Node3D

@export var draw: bool = false
@export var draw_line_gizmo: bool = false
@export var amnt = 10
@export var start: Node3D
@export var end: Node3D
 
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
var bezier_ops: Array[OrientedPoint] = []
var bezier: CubicBezier3d

func _ready() -> void:
	DebugDraw3D.scoped_config().set_thickness(0.1)
	bezier = CubicBezier3d.new()
	# hack to make duplicates not reference each others children
	mesh_instance_3d.mesh = mesh_instance_3d.mesh.duplicate()
	
	#set up mesh instance
	#mesh_instance_3d = MeshInstance3D.new()
	#add_child(mesh_instance_3d)
	#mesh_instance_3d.mesh = ArrayMesh.new()
	#mesh_instance_3d.mesh.resource_local_to_scene = true
	#var mat = StandardMaterial3D.new()
	#mat.albedo_texture = load("res://assets/img/stripes.png")
	#mat.uv1_scale = Vector3(1., 0.1, 1.)
	#mesh_instance_3d.material_override = mat

func _physics_process(delta: float) -> void:
	clear_and_try_generate()

func clear_and_try_generate():
	DebugDraw3D.clear_all()
	var mesh = mesh_instance_3d.mesh as ArrayMesh
	mesh.clear_surfaces()
	
	if !draw: return
	
	assert(start, "%s: No start point assigned" % name)
	assert(end, "%s: No end point assigned" % name)
	
	generate_bezier_ops()
	
	if draw_line_gizmo:
		DebugDraw3D.draw_line_path(
			bezier_ops.map(
				func(op: OrientedPoint): return op.pos
		))
	
	extrude(mesh, ExtrudeShape.circle_8(), bezier_ops)

func generate_bezier_ops():
	bezier.calc_for_2_control_points(start, end)
	bezier_ops.clear()
	for i in amnt:
		var t = i as float/(amnt - 1) as float
		var up: Vector3 = lerp(start.basis.y, end.basis.y, t)
		var op: OrientedPoint = bezier.get_oriented_pt(t, up)
		bezier_ops.append(op)

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
	
	var surface_0_array = []
	surface_0_array.resize(Mesh.ARRAY_MAX)
	
	var look_up: Array[float] = []
	look_up.resize(edge_loops)
	calc_length_table_into(look_up, bezier)
	
	#gen code
	for i in edge_loops:
		var offset: int = i * verts_in_shape
		var v_length: float = sample(look_up, (i as float) / edge_loops)
		for j in verts_in_shape:
			var id: int = offset + j
			vertices.insert(id, 
				path[i].local_to_world(
					Utils.vec2_extrude(shape.vertices[j].point)
				)
			)
			normals.insert(id,
				path[i].local_to_world_direction(
					Utils.vec2_extrude(shape.vertices[j].normal)
				)
			)
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
	surface_0_array[Mesh.ARRAY_VERTEX] = vertices
	surface_0_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_0_array[Mesh.ARRAY_NORMAL] = normals
	surface_0_array[Mesh.ARRAY_INDEX]  = triangle_indices
	mesh.resource_local_to_scene = true
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_0_array)
	
	
	## last edge
	#var edge_vert_count: int = verts_in_shape + 1
	#
	#var le_triangle_indices = PackedInt32Array()  
	#var le_vertices         = PackedVector3Array()
	#var le_normals          = PackedVector3Array()
	#var le_uvs              = PackedVector2Array()
	#le_triangle_indices.resize(edge_vert_count * 3)
	#le_vertices        .resize(edge_vert_count)
	#le_normals         .resize(edge_vert_count)
	#le_uvs             .resize(edge_vert_count)
	#
	#var last_op = path[edge_loops - 1]
	#for i in verts_in_shape:
		#le_vertices.insert(i, last_op.local_to_world(
			#Utils.vec2_extrude(shape.vertices[i].point)))
		#le_normals.insert(i, last_op.local_to_world_direction(
			#Utils.vec2_extrude(shape.vertices[i].normal)))
		#le_uvs.insert(i, Vector2(shape.vertices[i].u, 1.))
	#
	#
	#
	#var surface_1_array = []
	#surface_1_array.resize(Mesh.ARRAY_MAX)
	#surface_1_array[Mesh.ARRAY_VERTEX] = le_triangle_indices
	#surface_1_array[Mesh.ARRAY_TEX_UV] = le_vertices
	#surface_1_array[Mesh.ARRAY_NORMAL] = le_normals
	#surface_1_array[Mesh.ARRAY_INDEX]  = le_uvs
	#mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_1_array)
	
	#sphere(mesh)
	#square(mesh)
	square_with_center(mesh)

func square_with_center(mesh: ArrayMesh):
	var my_vertices : Array[ExtrudeShape.Vertex] = \
	[
		ExtrudeShape.Vertex.with_vals(Vector2(-1, 1), Vector2.UP, 0.1),
		ExtrudeShape.Vertex.with_vals(Vector2( 1, 1), Vector2.UP, 0.1),
		ExtrudeShape.Vertex.with_vals(Vector2( 1,-1), Vector2.UP, 0.1),
		ExtrudeShape.Vertex.with_vals(Vector2(-1,-1), Vector2.UP, 0.1)
	]
	
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	var verts = PackedVector3Array()
	var uvs = PackedVector2Array()
	var normals = PackedVector3Array()
	var indices = PackedInt32Array()
	
	var center = Vector3.ZERO
	#for i in range(0, my_vertices.size() - 1):
		#verts.append(center)
		#normals.append(Vector3.FORWARD)
		#uvs.append(Vector2.UP)
		#
		#verts.append(Utils.vec2_extrude(my_vertices[i].point))
		#normals.append(Utils.vec2_extrude(my_vertices[i].normal))
		#uvs.append(Vector2(my_vertices[i].u, 0))
		#
		#verts.append(Utils.vec2_extrude(my_vertices[i + 1].point))
		#normals.append(Utils.vec2_extrude(my_vertices[i + 1].normal))
		#uvs.append(Vector2(my_vertices[i].u, 0))
	
	#0
	verts.append(center)
	normals.append(Vector3.FORWARD)
	uvs.append(Vector2.UP)
	#1
	verts.append(Utils.vec2_extrude(my_vertices[0].point))
	normals.append(Utils.vec2_extrude(my_vertices[0].normal))
	uvs.append(Vector2(my_vertices[0].u, 0))
	#2
	verts.append(Utils.vec2_extrude(my_vertices[1].point))
	normals.append(Utils.vec2_extrude(my_vertices[1].normal))
	uvs.append(Vector2(my_vertices[1].u, 0))
	#3
	verts.append(center)
	normals.append(Vector3.FORWARD)
	uvs.append(Vector2.UP)
	#4
	verts.append(Utils.vec2_extrude(my_vertices[1].point))
	normals.append(Utils.vec2_extrude(my_vertices[1].normal))
	uvs.append(Vector2(my_vertices[1].u, 0))
	#5
	verts.append(Utils.vec2_extrude(my_vertices[2].point))
	normals.append(Utils.vec2_extrude(my_vertices[2].normal))
	uvs.append(Vector2(my_vertices[2].u, 0))
	#6
	verts.append(center)
	normals.append(Vector3.FORWARD)
	uvs.append(Vector2.UP)
	#7
	verts.append(Utils.vec2_extrude(my_vertices[2].point))
	normals.append(Utils.vec2_extrude(my_vertices[2].normal))
	uvs.append(Vector2(my_vertices[2].u, 0))
	#8
	verts.append(Utils.vec2_extrude(my_vertices[3].point))
	normals.append(Utils.vec2_extrude(my_vertices[3].normal))
	uvs.append(Vector2(my_vertices[3].u, 0))
	
	indices.append_array([0, 1, 2])
	indices.append_array([3, 4, 5])
	indices.append_array([6, 7, 8])
	indices.append_array([0, 8, 1]) # 0 and 6 are the same here
	
	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices
	prints("vertex:", verts.size(), "uvs:", uvs.size(), \
	"normals:", normals.size(), "indices:", indices.size())
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)

func square(mesh: ArrayMesh):
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)

	# PackedVector**Arrays for mesh construction.
	var verts = PackedVector3Array()
	var uvs = PackedVector2Array()
	var normals = PackedVector3Array()
	var indices = PackedInt32Array()
	# 0
	verts.append(Vector3(-1, 1, 0))
	normals.append(Vector3.BACK)
	uvs.append(Vector2.DOWN)
	# 1
	verts.append(Vector3(1, 1, 0))
	normals.append(Vector3.BACK)
	uvs.append(Vector2.DOWN)
	# 2
	verts.append(Vector3(1, -1, 0))
	normals.append(Vector3.BACK)
	uvs.append(Vector2.DOWN)
	# 3
	verts.append(Vector3(-1, -1, 0))
	normals.append(Vector3.BACK)
	uvs.append(Vector2.DOWN)
	# tri 0, 1
	indices.append_array([0, 1, 2])
	indices.append_array([0, 2, 3])
	
	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)

func sphere(mesh: ArrayMesh):
	var surface_1_array = []
	surface_1_array.resize(Mesh.ARRAY_MAX)

	# PackedVector**Arrays for mesh construction.
	var verts = PackedVector3Array()
	var uvs = PackedVector2Array()
	var normals = PackedVector3Array()
	var indices = PackedInt32Array()

	var rings = 50
	var radial_segments = 50
	var radius = 1

	# Vertex indices.
	var thisrow = 0
	var prevrow = 0
	var point = 0

	# Loop over rings.
	for i in range(rings + 1):
		var v = float(i) / rings
		var w = sin(PI * v)
		var y = cos(PI * v)

		# Loop over segments in ring.
		for j in range(radial_segments + 1):
			var u = float(j) / radial_segments
			var x = sin(u * PI * 2.0)
			var z = cos(u * PI * 2.0)
			var vert = Vector3(x * radius * w, y * radius, z * radius * w)
			verts.append(vert)
			normals.append(vert.normalized())
			uvs.append(Vector2(u, v))
			point += 1

			# Create triangles in ring using indices.
			if i > 0 and j > 0:
				indices.append(prevrow + j - 1)
				indices.append(prevrow + j)
				indices.append(thisrow + j - 1)

				indices.append(prevrow + j)
				indices.append(thisrow + j)
				indices.append(thisrow + j - 1)

		prevrow = thisrow
		thisrow = point
	

	# Assign arrays to surface array.
	surface_1_array[Mesh.ARRAY_VERTEX] = verts
	surface_1_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_1_array[Mesh.ARRAY_NORMAL] = normals
	surface_1_array[Mesh.ARRAY_INDEX] = indices

	# Create mesh surface from mesh array.
	# No blendshapes, lods, or compression used.
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_1_array)

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
