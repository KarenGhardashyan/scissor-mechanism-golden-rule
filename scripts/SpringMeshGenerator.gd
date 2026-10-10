class_name SpringMeshGenerator
extends RefCounted

## Procedural 3D Coiled Helix Spring Mesh Generator for Godot 4
## Generates a realistic helical extension spring along the -Y axis.

static func generate_spring(
	length: float,
	radius: float = 0.042,
	coils: float = 7.5,
	wire_radius: float = 0.0065,
	coil_samples: int = 140,
	radial_segments: int = 8,
	lead_fraction: float = 0.08
) -> ArrayMesh:
	# Clamp length to a physically reasonable minimum to prevent inversion
	var spring_len: float = maxf(length, wire_radius * 8.0)
	var lead_len: float = clampf(spring_len * lead_fraction, wire_radius * 2.0, 0.05)
	var helix_len: float = spring_len - 2.0 * lead_len

	# Step 1: Generate spine curve points
	var spine_points: Array[Vector3] = []
	var total_points: int = coil_samples + 1

	for i in range(total_points):
		var u: float = float(i) / float(coil_samples) # 0.0 to 1.0
		var pos: Vector3 = Vector3.ZERO

		if u < 0.08:
			# Top lead-in straight / transition
			var t_lead: float = u / 0.08
			var angle: float = 0.0
			var r: float = radius * smoothstep(0.0, 1.0, t_lead)
			pos = Vector3(
				r * cos(angle),
				-lead_len * t_lead,
				r * sin(angle)
			)
		elif u > 0.92:
			# Bottom lead-out straight / transition
			var t_lead: float = (u - 0.92) / 0.08
			var angle: float = TAU * coils
			var r: float = radius * (1.0 - smoothstep(0.0, 1.0, t_lead))
			pos = Vector3(
				r * cos(angle),
				-(lead_len + helix_len) - lead_len * t_lead,
				r * sin(angle)
			)
		else:
			# Active helical coil
			var t_helix: float = (u - 0.08) / (0.92 - 0.08)
			var angle: float = TAU * coils * t_helix
			pos = Vector3(
				radius * cos(angle),
				-lead_len - (helix_len * t_helix),
				radius * sin(angle)
			)
		spine_points.append(pos)

	# Step 2: Compute coordinate frames along the spine using Rotation Minimizing Frames (RMF)
	var num_pts: int = spine_points.size()
	var tangents: Array[Vector3] = []
	var normals: Array[Vector3] = []
	var binormals: Array[Vector3] = []

	tangents.resize(num_pts)
	normals.resize(num_pts)
	binormals.resize(num_pts)

	# Compute forward tangents
	for i in range(num_pts):
		var t: Vector3
		if i == 0:
			t = (spine_points[1] - spine_points[0]).normalized()
		elif i == num_pts - 1:
			t = (spine_points[num_pts - 1] - spine_points[num_pts - 2]).normalized()
		else:
			t = (spine_points[i + 1] - spine_points[i - 1]).normalized()
		if t.is_zero_approx():
			t = Vector3.DOWN
		tangents[i] = t

	# Initial normal
	var init_t: Vector3 = tangents[0]
	var arbitrary: Vector3 = Vector3.FORWARD if absf(init_t.dot(Vector3.FORWARD)) < 0.9 else Vector3.RIGHT
	normals[0] = (arbitrary - init_t * arbitrary.dot(init_t)).normalized()
	binormals[0] = init_t.cross(normals[0]).normalized()

	# Propagate frame using parallel transport
	for i in range(num_pts - 1):
		var v1: Vector3 = spine_points[i + 1] - spine_points[i]
		var c1: float = v1.dot(v1)
		var n_curr: Vector3 = normals[i]
		var t_curr: Vector3 = tangents[i]
		var t_next: Vector3 = tangents[i + 1]

		# Standard double reflection method for RMF
		var r_l: Vector3 = n_curr - (2.0 / c1) * v1.dot(n_curr) * v1 if c1 > 0.00001 else n_curr
		var v2: Vector3 = t_next - (t_curr - (2.0 / c1) * v1.dot(t_curr) * v1) if c1 > 0.00001 else Vector3.ZERO
		var c2: float = v2.dot(v2)
		var n_next: Vector3 = r_l - (2.0 / c2) * v2.dot(r_l) * v2 if c2 > 0.00001 else r_l
		normals[i + 1] = n_next.normalized()
		binormals[i + 1] = tangents[i + 1].cross(normals[i + 1]).normalized()

	# Step 3: Construct tube mesh with SurfaceTool
	var st: SurfaceTool = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	# Generate vertex rings
	for i in range(num_pts):
		var center: Vector3 = spine_points[i]
		var norm: Vector3 = normals[i]
		var binorm: Vector3 = binormals[i]
		var v_coord: float = float(i) / float(num_pts - 1) * coils * 2.0

		for j in range(radial_segments):
			var theta: float = float(j) / float(radial_segments) * TAU
			var rad_offset: Vector3 = (norm * cos(theta) + binorm * sin(theta))
			var vert_pos: Vector3 = center + rad_offset * wire_radius
			var normal_dir: Vector3 = rad_offset.normalized()
			var u_coord: float = float(j) / float(radial_segments)

			st.set_normal(normal_dir)
			st.set_uv(Vector2(u_coord, v_coord))
			st.add_vertex(vert_pos)

	# Generate quad indices
	for i in range(num_pts - 1):
		var ring1: int = i * radial_segments
		var ring2: int = (i + 1) * radial_segments

		for j in range(radial_segments):
			var next_j: int = (j + 1) % radial_segments

			var p0: int = ring1 + j
			var p1: int = ring1 + next_j
			var p2: int = ring2 + next_j
			var p3: int = ring2 + j

			# First triangle
			st.add_index(p0)
			st.add_index(p1)
			st.add_index(p2)

			# Second triangle
			st.add_index(p0)
			st.add_index(p2)
			st.add_index(p3)

	# Add cap at top
	var top_center_idx: int = num_pts * radial_segments
	st.set_normal(Vector3.UP)
	st.set_uv(Vector2(0.5, 0.5))
	st.add_vertex(spine_points[0])
	for j in range(radial_segments):
		var next_j: int = (j + 1) % radial_segments
		st.add_index(top_center_idx)
		st.add_index(next_j)
		st.add_index(j)

	# Add cap at bottom
	var bot_center_idx: int = top_center_idx + 1
	var last_ring: int = (num_pts - 1) * radial_segments
	st.set_normal(Vector3.DOWN)
	st.set_uv(Vector2(0.5, 0.5))
	st.add_vertex(spine_points[num_pts - 1])
	for j in range(radial_segments):
		var next_j: int = (j + 1) % radial_segments
		st.add_index(bot_center_idx)
		st.add_index(last_ring + j)
		st.add_index(last_ring + next_j)

	st.generate_tangents()
	return st.commit()
