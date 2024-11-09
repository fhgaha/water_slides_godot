class_name ExtrudeShape

class Vertex:
	var point: Vector2
	var normal: Vector2
	var u: float
	
	func with_vals(point: Vector2, normal: Vector2, u: float) -> Vertex:
		self.point  = point
		self.normal = normal
		self.u      = u
		return self

var vertices: Array[Vertex]
var line_indices: Array[int]

func with_vals(vertices: Array[Vertex], line_indeces: Array[int]) -> ExtrudeShape:
	self.vertices = vertices
	self.line_indices = line_indeces
	return self

func vertex_count() -> int:
	return self.vertices.size()

func line_count() -> int: 
	return self.line_indices.size()

func calc_u_span() -> float:
	var dist: float = 0.
	var line_count = self.line_count();
	for i in range(0, line_count, 2):
		var u_a = self.vertices[self.line_indices[i]].point;
		var u_b = self.vertices[self.line_indices[i + 1]].point;
		dist += (u_a - u_b).length();
	
	return dist

static func circle_8() -> ExtrudeShape:
	var sqrt: float = 1.0/sqrt(2.0)
	return ExtrudeShape.new().with_vals( \
		#vertices:
		[ \
			# TODO: set correct normals
			Vertex.new().with_vals(Vector2(0.0, 1.0),       Vector2.UP, 	 1.000     ), \
			Vertex.new().with_vals(Vector2(0., 1.),         Vector2.UP, 	 0.000     ), \
			Vertex.new().with_vals(Vector2(-sqrt, sqrt),   -Vector2.UP, 	 0.125     ), \
			Vertex.new().with_vals(Vector2(-sqrt, sqrt),   -Vector2.UP, 	 0.125     ), \
			Vertex.new().with_vals(Vector2(-1., 0.),       -Vector2.UP, 	 0.125 * 2.), \
			Vertex.new().with_vals(Vector2(-1., 0.),       -Vector2.UP, 	 0.125 * 2.), \
			Vertex.new().with_vals(Vector2(-sqrt, -sqrt),  -Vector2.UP, 	 0.125 * 3.), \
			Vertex.new().with_vals(Vector2(-sqrt, -sqrt),  -Vector2.UP, 	 0.125 * 3.), \
			Vertex.new().with_vals(Vector2(0., -1.),       -Vector2.UP, 	 0.125 * 4.), \
			Vertex.new().with_vals(Vector2(0., -1.),       -Vector2.UP, 	 0.125 * 4.), \
			Vertex.new().with_vals(Vector2(sqrt, -sqrt),    Vector2.UP, 	 0.125 * 5.), \
			Vertex.new().with_vals(Vector2(sqrt, -sqrt),    Vector2.UP, 	 0.125 * 5.), \
			Vertex.new().with_vals(Vector2(1., 0.),         Vector2.UP, 	 0.125 * 6.), \
			Vertex.new().with_vals(Vector2(1., 0.),         Vector2.UP, 	 0.125 * 6.), \
			Vertex.new().with_vals(Vector2(sqrt, sqrt),     Vector2.UP, 	 0.125 * 7.), \
			Vertex.new().with_vals(Vector2(sqrt, sqrt),     Vector2.UP, 	 0.125 * 7.), \
		],\
		#line_indices: 
		[ \
			1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 0 \
		] \
	)
