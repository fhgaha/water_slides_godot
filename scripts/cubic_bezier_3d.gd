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
		pts[i] = arr[i]
	return self

func get_point(t: float) -> Vector3:
	var a: Vector3 = lerp(pts[0], pts[1], t)
	var b: Vector3 = lerp(pts[1], pts[2], t)
	var c: Vector3 = lerp(pts[2], pts[3], t)
	var d: Vector3 = lerp(a, b, t)
	var e: Vector3 = lerp(b, c, t)
	return lerp(d, e, t)
