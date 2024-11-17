class_name Tube extends Node3D

@export var cam: CameraController
const TUBE_SEGMENT_SCENE = preload("res://scenes/tube_segment_0.tscn")

func _ready():
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_screen_position: Vector2 = event.position
		var result: Dictionary = cam.raycast(mouse_screen_position)
		if result && result.collider is ControlPointRaycastTarget:
			var cp_rc_trg = result.collider as ControlPointRaycastTarget
			prints("found raycastable:", cp_rc_trg)

