class_name Utils extends Node

enum OptionEnum {Some, None}

class Option:
	var opt: OptionEnum
	var data: Variant

static func vec2_extrude(v2: Vector2) -> Vector3:
	return Vector3(v2.x, v2.y, 0.)
