@tool
class_name ControlPoint extends Node3D

enum ControlPointState {None, Drag}

var state = ControlPointState.None

func _ready():
	set_notify_local_transform(true)

func _notification(what: int) -> void:
	if what == Node3D.NOTIFICATION_LOCAL_TRANSFORM_CHANGED:
		prints(self.name, "Local transform has changed!")
	pass