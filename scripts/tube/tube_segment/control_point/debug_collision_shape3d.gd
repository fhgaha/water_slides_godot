class_name DebugCollisionShape3D extends CollisionShape3D

func _ready():
	var arr_mesh: ArrayMesh = shape.get_debug_mesh()
	var verts: PackedVector3Array = arr_mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
	# prints("verts type:", type_string(typeof(verts)))
	DebugDraw3D.scoped_config().set_thickness(2)
	DebugDraw3D.draw_line_path(verts)

func _physics_process(_delta: float) -> void:
	DebugDraw3D.clear_all()
	
	var arr_mesh: ArrayMesh = shape.get_debug_mesh()
	var verts: PackedVector3Array = arr_mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
	# prints("verts type:", type_string(typeof(verts)))
	DebugDraw3D.draw_line_path(verts)