class_name CubicBezier3d

var pts: Array[Vector3] = [Vector3.INF, Vector3.INF, Vector3.INF, Vector3.INF]
var p0: Vector3: 
	get: return pts[0]
var p1: Vector3:
	get: return pts[1]
var p2: Vector3:
	get: return pts[2]
var p3: Vector3:
	get: return pts[3]

func with_control_points(arr: Array[Vector3]) -> CubicBezier3d:
	assert(arr.size() == 4)
	for i in arr.size():
		self.pts[i] = arr[i]
	return self

func get_point(t: float) -> Vector3:
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
