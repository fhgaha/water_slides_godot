@tool
class_name TubeSegment extends Node3D

@export var control_points: Array[Node3D]

var points: Array[Transform3D]:
	get:
		assert(control_points.all(func(cp: Node3D): return cp != null))
		return control_points.map(func(cp: Node3D): return cp.transform)

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D

func get_pos(i: int) -> Vector3:
	return control_points[i].position

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	#draw_line()
	#generate_mesh()
	
	pass 

func draw_line():
	DebugDraw3D.clear_all()
	
	var amnt = 10
	
	var positions: Array[Vector3]
	var position_untyped_arr: Array = control_points.map(
		func(cp: Node3D): return cp.position)
	positions.assign(position_untyped_arr)
	
	for i in range(0, amnt):
		var t = i as float/(amnt - 1) as float
		var bezier_pt = get_point(positions, t)
		
		DebugDraw3D.draw_box(bezier_pt, Quaternion.IDENTITY, Vector3.ONE)


func generate_mesh():
	print(Time.get_datetime_string_from_system())
	var mesh = mesh_instance_3d.mesh as ArrayMesh
	
	var vertices = PackedVector3Array()
	var normals  = PackedVector3Array()
	var uvs      = PackedVector2Array()
	var tris     = PackedInt32Array()
	
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	
	#gen code
	
	
	surface_array[Mesh.ARRAY_VERTEX] = vertices
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX]  = tris
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)

# optimize this thing
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
