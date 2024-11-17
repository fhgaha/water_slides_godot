class_name Tube extends Node3D

@export var cam: CameraController

func _ready():
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_screen_pos: Vector2 = event.position
		var result: Dictionary = cam.raycast(mouse_screen_pos)
		prints("result:", result)
