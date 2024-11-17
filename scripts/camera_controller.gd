class_name CameraController extends Node3D

@export var cam: Camera3D
@export var ray_length: int = 1000

func raycast(mouse_position: Vector2) -> Dictionary:
	var space_state = get_world_3d().direct_space_state
	var params = PhysicsRayQueryParameters3D.new()
	params.from = cam.project_ray_origin(mouse_position)
	params.to = cam.project_ray_normal(mouse_position) * ray_length
	return space_state.intersect_ray(params)