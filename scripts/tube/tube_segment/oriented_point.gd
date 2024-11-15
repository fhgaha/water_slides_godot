class_name OrientedPoint

var pos: Vector3
var rot: Quaternion

func with_vals(pos: Vector3, rot: Quaternion) -> OrientedPoint:
	self.pos = pos
	self.rot = rot
	return self

func local_to_world(point: Vector3) -> Vector3:
	return pos + rot * point

func world_to_local(point: Vector3) -> Vector3:
	return rot.inverse() * (point - pos)

func local_to_world_direction(dir: Vector3) -> Vector3:
	return rot * dir
