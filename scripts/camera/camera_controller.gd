# https://www.reddit.com/r/godot/comments/yoo3ye/rotating_camera_around_object/

# Create a Spatial node. (I will be calling it "Main" from now on)
# Add whatever you want to be at the center (I will be calling it "Target") as a child of Main
# Add another Spatial as a child of Main (I will be calling it "Spinner")
# Add a Camera as a child of Spinner, and move it back a bit (so that its facing Target, but from a distance)
# Your nodes should now look this:
#     Spatial (Main) ---Target ---Spatial (Spinner) ------Camera3D
# Add a script to the camera with the following code
# func _process(delta): 
#      rotation.y += 1.0*delta
# This should make the camera spin around your target. 

# all rotations should be global

class_name CameraController extends Node

@export var cam: Camera3D
@export var target: Node3D
@export var ray_length: int = 1000
@export var can_move: bool = false

@export var SPEED: int = 100
@export var ROTATE_BUTTON: MouseButton = MOUSE_BUTTON_RIGHT
@export var ROT_Y_SPEED: float = 0.01
@export var ROT_X_SPEED: float = 0.01

@export var PAN_BUTTON: MouseButton = MOUSE_BUTTON_MIDDLE

@export_group("Limits")
@export_range(0, 360) 	var spin_y_deg: float	#glob rotation.y
const MIN_X_DEG: float = -89
const MAX_X_DEG: float = -5
@export_range(MIN_X_DEG, MAX_X_DEG) var spin_x_deg: float	#glob rotation.x
@export_range(20, 100) 				var zoom_z: float		#position.z

@onready var spinner_y: 	Node3D = $spinner_y	# also this node is moved around on wasd
@onready var spinner_x: 	Node3D = $spinner_y/spinner_x
@onready var mover_z: 		Node3D = $spinner_y/spinner_x/mover_z

### this should be run in _physics_process()
func raycast(mouse_screen_pos: Vector2) -> Dictionary:
	var space_state: PhysicsDirectSpaceState3D = cam.get_world_3d().direct_space_state
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

# move anchor on wasd. if clicked on edge after that, reset position to local zero.
# reset position only when we are going from idle state to building state


func reset_pos():
	pass


func change_parent(cp: ControlPoint):
	reset_pos()
	reparent(cp, false)
	pass


func _ready():
	spinner_y.rotation = Vector3.ZERO
	spinner_x.rotation = Vector3.ZERO
	spinner_y.rotation.y = deg_to_rad(spin_y_deg)
	spinner_x.rotation.x = deg_to_rad(spin_x_deg)
	mover_z.position.z = zoom_z

	pass


func _physics_process(delta: float):
	if can_move:
		move(delta)
	rotate(delta)


func move(dt: float):
	var dir: Vector2 = Input.get_vector(
		"move_cam_left", 
		"move_cam_right", 
		"move_cam_forward", 
		"move_cam_back"
	)
	spinner_y.translate_object_local(Vector3(dir.x, 0, dir.y) * dt * SPEED)


func rotate(dt: float):
	if Input.is_mouse_button_pressed(ROTATE_BUTTON):
		var vel := Input.get_last_mouse_velocity()
		spinner_y.rotation.y -= vel.x * dt * ROT_Y_SPEED

		spinner_x.rotation.x -= vel.y * dt * 0.005
		spinner_x.rotation.x = clampf(
			spinner_x.rotation.x, 
			deg_to_rad(MIN_X_DEG),
			deg_to_rad(MAX_X_DEG), 
		) 
	pass
