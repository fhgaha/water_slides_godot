class_name CamController extends Node3D

@export var cam: Camera3D
@export var raycast: RayCast3D

const ray_length: int = 1000

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var space_state = get_world_3d().direct_space_state
		var mouse_position = event.position
		var params = PhysicsRayQueryParameters3D.new()
		params.from = cam.project_ray_origin(mouse_position)
		params.to = cam.project_ray_normal(mouse_position) * ray_length

		var result: Dictionary = space_state.intersect_ray(params)
		if result:
			var picked_object = result.collider
			print("Picked object: ", picked_object.name)
		