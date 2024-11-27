@tool
class_name ControlPointRaycastTarget extends Area3D

var cp_parent: ControlPoint

func register_contol_point(cp: ControlPoint):
	assert(!cp_parent, "ControlPointRaycastTarget already has cp_parent!: %s" % cp_parent)
	cp_parent = cp
