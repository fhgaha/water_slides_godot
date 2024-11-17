@tool
class_name ControlPointRaycastTarget extends AnimatableBody3D

@export_category("Don't set in editor")
@export var cp_parent: ControlPoint

func register_contol_point(cp: ControlPoint):
	assert(!cp_parent, "ControlPointRaycastTarget already has cp_parent!: %s" % cp_parent)
	cp_parent = cp
