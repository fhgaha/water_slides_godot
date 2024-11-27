class_name CameraController extends Node3D

@export var cam: Camera3D
@export var ray_length: int = 1000

### this should be run in _physics_process()
func raycast(mouse_screen_pos: Vector2) -> Dictionary:
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var params := PhysicsRayQueryParameters3D.new()
	params.from = cam.project_ray_origin(mouse_screen_pos)
	params.to   = cam.project_ray_normal(mouse_screen_pos) * ray_length
	return space_state.intersect_ray(params)

### this should be run in _physics_process()
func project_to_length(mouse_screen_pos: Vector2, length: float) -> Vector3:
	var from: Vector3 = cam.project_ray_origin(mouse_screen_pos)
	var to  : Vector3 = cam.project_ray_normal(mouse_screen_pos) * length
	return from + to

### this should be run in _physics_process()
func project_to_screen(mouse_screen_pos: Vector2) -> Vector3:
	var from: Vector3 = cam.project_ray_origin(mouse_screen_pos)
	var to  : Vector3 = cam.project_ray_normal(mouse_screen_pos)
	return from + to
