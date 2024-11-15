class_name ExtrudeShape

class Vertex:
	var point: Vector2
	var normal: Vector2
	var u: float
	
	static func with_vals(point: Vector2, normal: Vector2, u: float) -> Vertex:
		var v = Vertex.new()
		v.point  = point
		v.normal = normal
		v.u      = u
		return v

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
	const sqrt: float = 1.0/sqrt(2.0)
	# sin(0) = 0, sin(PI/2) = 1
	# cos(0) = 1, cos(PI/2) = 0
	# Vector2(0, 1) ~ Vector2(1, 0)
	# Vector2(sin(1/3 * PI/2), cos(2/3 * PI/2))
	const s13rd: float = sin(1./3. * PI/2.)
	const s23rd: float = sin(2./3. * PI/2.)
	const c13rd: float = cos(1./3. * PI/2.)
	const c23rd: float = cos(2./3. * PI/2.)
	
	return ExtrudeShape.new().with_vals( \
		#vertices: point, normal, u
		[ \
			Vertex.with_vals(Vector2(0., 1.),         Vector2( s13rd,  c23rd), 	 1.000     ), \
			Vertex.with_vals(Vector2(0., 1.),         Vector2(-s13rd,  c23rd), 	 0.125 * 0.), \
			Vertex.with_vals(Vector2(-sqrt, sqrt),    Vector2(-s13rd,  c23rd), 	 0.125 * 1.), \
			Vertex.with_vals(Vector2(-sqrt, sqrt),    Vector2(-s23rd,  c13rd), 	 0.125 * 1.), \
			Vertex.with_vals(Vector2(-1., 0.),        Vector2(-s23rd,  c13rd), 	 0.125 * 2.), \
			Vertex.with_vals(Vector2(-1., 0.),        Vector2(-s13rd, -c23rd), 	 0.125 * 2.), \
			Vertex.with_vals(Vector2(-sqrt, -sqrt),   Vector2(-s13rd, -c23rd), 	 0.125 * 3.), \
			Vertex.with_vals(Vector2(-sqrt, -sqrt),   Vector2(-s23rd, -c13rd), 	 0.125 * 3.), \
			Vertex.with_vals(Vector2(0., -1.),        Vector2(-s23rd, -c13rd), 	 0.125 * 4.), \
			Vertex.with_vals(Vector2(0., -1.),        Vector2( s13rd, -c23rd), 	 0.125 * 4.), \
			Vertex.with_vals(Vector2(sqrt, -sqrt),    Vector2( s13rd, -c23rd), 	 0.125 * 5.), \
			Vertex.with_vals(Vector2(sqrt, -sqrt),    Vector2( s23rd, -c13rd), 	 0.125 * 5.), \
			Vertex.with_vals(Vector2(1., 0.),         Vector2( s23rd, -c13rd), 	 0.125 * 6.), \
			Vertex.with_vals(Vector2(1., 0.),         Vector2( s23rd,  c13rd), 	 0.125 * 6.), \
			Vertex.with_vals(Vector2(sqrt, sqrt),     Vector2( s23rd,  c13rd), 	 0.125 * 7.), \
			Vertex.with_vals(Vector2(sqrt, sqrt),     Vector2( s13rd,  c23rd), 	 0.125 * 7.), \
		],\
		#line_indices: 
		[ \
			1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 0 \
		] \
	)
