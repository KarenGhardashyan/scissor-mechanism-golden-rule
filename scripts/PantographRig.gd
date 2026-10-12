class_name PantographRig
extends Node3D

## Apple Industrial Hardware Aesthetic: Scissor Pantograph Prototype
## Tactile, chunky 3D hardware linkages with satin resin / space-grey anodized finishes.
## Minimalist VisionOS design language. Supports uniform and 1:2:3 variable-pitch pantographs.

signal telemetry_updated(data: Dictionary)

# Physical Experiment Parameters
@export var n_stages: int = 3
@export var rig_name: String = "Rig A (n=3)"
@export var is_scaled_123: bool = false         # Scaled 1:2:3 Variable-Pitch Pantograph
@export var rig_color_theme: String = "blue"   # "blue", "green", "orange"
@export var physical_link_length: float = 0.06 # Base arm length: 6.0 cm
@export var physical_resting_H: float = 0.075  # Base unloaded rhombus height: 7.5 cm
@export var spring_k: float = 1000.0           # Spring stiffness in N/m [500 - 1500]
@export var suspended_mass: float = 0.5        # Mass in kg [0.0 - 1.5]
@export var link_mass_per_stage: float = 0.05  # Self-weight PLA per rhombus: 0.05 kg
@export var efficiency_eta: float = 1.0        # Mechanical efficiency η [0.50 - 1.00]
@export var gravity: float = 9.81              # m/s²
@export var visual_scale: float = 4.4          # 3D units per physical meter
@export var is_left_rig: bool = true
@export var laser_side_sign: float = -1.0      # -1.0 for left side, +1.0 for right side

# Dynamic State & Vibration Controls
@export var oscillations_enabled: bool = true  # Toggle harmonic oscillation / smooth glide
@export var damping_ratio_zeta: float = 0.25   # Damping ratio [0.00 - 0.60]
@export var natural_frequency_omega: float = 20.0 # Nominal frequency [10.0 - 35.0 rad/s]

var current_H: float = 0.075
var velocity_H: float = 0.0
var target_H: float = 0.075
var current_W: float = 0.0
var current_theta: float = 0.0
var current_L: float = 0.0

# Mechanical telemetry variables
var tensile_force_T: float = 0.0
var effective_load_P: float = 0.0
var spring_delta_H: float = 0.0
var total_delta_L: float = 0.0
var transmission_ratio_lambda: float = 0.0

# Visual Nodes
var links_container: Node3D
var pins_container: Node3D
var spring_mesh_instance: MeshInstance3D
var mass_assembly: Node3D
var mass_cylinder: MeshInstance3D
var mass_label: Label3D
var rig_title_label: Label3D

# Extension Dimension Lasers & Ticks
var dimension_lines_container: Node3D
var line_h: MeshInstance3D
var line_l: MeshInstance3D
var tick_top: MeshInstance3D
var tick_mid: MeshInstance3D
var tick_bot: MeshInstance3D
var arrow_h_top: MeshInstance3D
var arrow_h_bot: MeshInstance3D
var arrow_l_top: MeshInstance3D
var arrow_l_bot: MeshInstance3D
var dim_label_h: Label3D
var dim_label_l: Label3D
var mat_laser: StandardMaterial3D

# Premium Industrial Materials
var mat_arm_body: StandardMaterial3D
var mat_arm_chamfer: StandardMaterial3D
var mat_pin_steel: StandardMaterial3D
var mat_pin_accent: StandardMaterial3D
var mat_joint_brass: StandardMaterial3D
var mat_spring_chrome: StandardMaterial3D
var mat_mass_metal: StandardMaterial3D

# Internal arrays
var arm_nodes: Array[Node3D] = []
var pin_nodes: Array[Node3D] = []

var base_spring_vis_height: float = 0.33
var anim_time: float = 0.0


func get_base_link_length() -> float:
	return (physical_link_length * 0.75) if is_scaled_123 else physical_link_length


func get_base_resting_H() -> float:
	return (physical_resting_H * 0.75) if is_scaled_123 else physical_resting_H


func _ready() -> void:
	_init_materials()
	_build_rig_hierarchy()
	_update_physics_targets()
	current_H = target_H
	velocity_H = 0.0
	_update_kinematics(0.016)
	_update_visuals()


func _init_materials() -> void:
	# --- Apple Hardware Materials ---
	mat_arm_body = StandardMaterial3D.new()
	mat_arm_chamfer = StandardMaterial3D.new()
	mat_pin_accent = StandardMaterial3D.new()
	mat_mass_metal = StandardMaterial3D.new()

	mat_laser = StandardMaterial3D.new()
	mat_laser.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat_laser.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat_laser.cull_mode = BaseMaterial3D.CULL_DISABLED

	var theme: String = rig_color_theme.to_lower()
	if theme == "green" or is_scaled_123:
		# RIG C (Mechanism 3): Precision Satin Anodized Emerald Green (#30D158)
		mat_arm_body.albedo_color = Color(0.19, 0.82, 0.35)
		mat_arm_body.metallic = 0.58
		mat_arm_body.roughness = 0.26

		mat_arm_chamfer.albedo_color = Color(0.08, 0.39, 0.16) # Forest Green Chamfer
		mat_arm_chamfer.metallic = 0.85
		mat_arm_chamfer.roughness = 0.22

		# Mint / Jade Collar (#63E6BE)
		mat_pin_accent.albedo_color = Color(0.39, 0.90, 0.75)
		mat_pin_accent.metallic = 0.90
		mat_pin_accent.roughness = 0.16

		# Suspended Weight: Polished Satin Titanium Billet
		mat_mass_metal.albedo_color = Color(0.85, 0.86, 0.88)
		mat_mass_metal.metallic = 0.95
		mat_mass_metal.roughness = 0.18

		mat_laser.albedo_color = Color(0.19, 0.82, 0.35, 0.85)
	elif theme == "orange" or (not is_left_rig and not is_scaled_123):
		# RIG B (Mechanism 2): Precision Satin Anodized Ultra Orange (#FF6B0D)
		mat_arm_body.albedo_color = Color(1.0, 0.42, 0.05)
		mat_arm_body.metallic = 0.58
		mat_arm_body.roughness = 0.26

		mat_arm_chamfer.albedo_color = Color(0.65, 0.22, 0.02) # Deep Amber Chamfer
		mat_arm_chamfer.metallic = 0.85
		mat_arm_chamfer.roughness = 0.22

		# Warm Golden Amber Accent Collar (#FFB703)
		mat_pin_accent.albedo_color = Color(1.0, 0.72, 0.15)
		mat_pin_accent.metallic = 0.92
		mat_pin_accent.roughness = 0.16

		# Suspended Weight: Machined Brass / Bronze Billet
		mat_mass_metal.albedo_color = Color(0.92, 0.78, 0.46)
		mat_mass_metal.metallic = 0.94
		mat_mass_metal.roughness = 0.16

		mat_laser.albedo_color = Color(1.0, 0.45, 0.0, 0.85)
	else:
		# RIG A (Mechanism 1): Precision Satin Anodized Electric Blue (#0071E3)
		mat_arm_body.albedo_color = Color(0.06, 0.45, 0.92)
		mat_arm_body.metallic = 0.58
		mat_arm_body.roughness = 0.26

		mat_arm_chamfer.albedo_color = Color(0.03, 0.22, 0.54) # Deep Indigo Chamfer
		mat_arm_chamfer.metallic = 0.85
		mat_arm_chamfer.roughness = 0.22

		# Electric Ice-Cyan Accent Collar (#4CC9F0)
		mat_pin_accent.albedo_color = Color(0.30, 0.80, 1.0)
		mat_pin_accent.metallic = 0.90
		mat_pin_accent.roughness = 0.16

		# Suspended Weight: Polished Aerospace Aluminum
		mat_mass_metal.albedo_color = Color(0.86, 0.88, 0.92)
		mat_mass_metal.metallic = 0.95
		mat_mass_metal.roughness = 0.18

		mat_laser.albedo_color = Color(0.0, 0.443, 0.89, 0.85)

	# Precision Turned Architectural Brass / Gold Joint Pins
	mat_joint_brass = StandardMaterial3D.new()
	mat_joint_brass.albedo_color = Color(0.96, 0.78, 0.32)
	mat_joint_brass.metallic = 0.96
	mat_joint_brass.roughness = 0.14

	# Stainless Steel Structural Bracket / Hook
	mat_pin_steel = StandardMaterial3D.new()
	mat_pin_steel.albedo_color = Color(0.92, 0.93, 0.95)
	mat_pin_steel.metallic = 0.98
	mat_pin_steel.roughness = 0.12

	# Chunky Glossy Chrome Upper Spring (Mirror Finish)
	mat_spring_chrome = StandardMaterial3D.new()
	mat_spring_chrome.albedo_color = Color(0.98, 0.98, 1.0)
	mat_spring_chrome.metallic = 1.0
	mat_spring_chrome.roughness = 0.06


func _build_rig_hierarchy() -> void:
	# 1. Top Gantry Attachment Clamp (Machined Billet Bracket)
	var bracket := MeshInstance3D.new()
	var b_box := BoxMesh.new()
	b_box.size = Vector3(0.32, 0.09, 0.16)
	bracket.mesh = b_box
	bracket.position = Vector3(0, 0.045, 0)
	bracket.material_override = mat_pin_steel
	add_child(bracket)

	# 2. Containers
	links_container = Node3D.new()
	links_container.name = "LinksContainer"
	add_child(links_container)

	pins_container = Node3D.new()
	pins_container.name = "PinsContainer"
	add_child(pins_container)

	# 3. Create Chunky Tactile Link Arms
	arm_nodes.clear()
	var base_link_len: float = get_base_link_length()
	var arm_width: float = 0.092
	var arm_thick: float = 0.036

	for stage in range(n_stages):
		var m_stage: float = [1.0, 2.0, 3.0][stage] if is_scaled_123 else 1.0
		var arm_vis_len: float = base_link_len * m_stage * visual_scale

		for arm_idx in range(4):
			var arm_node := Node3D.new()
			arm_node.name = "Arm_S%d_%d" % [stage, arm_idx]

			# Main tactile arm bar
			var arm_mesh_inst := MeshInstance3D.new()
			var arm_box := BoxMesh.new()
			arm_box.size = Vector3(arm_width, arm_vis_len * 0.90, arm_thick)
			arm_mesh_inst.mesh = arm_box
			arm_mesh_inst.material_override = mat_arm_body
			arm_node.add_child(arm_mesh_inst)

			# Contrasting center inlay groove
			var groove := MeshInstance3D.new()
			var g_box := BoxMesh.new()
			g_box.size = Vector3(arm_width * 0.44, arm_vis_len * 0.78, arm_thick + 0.003)
			groove.mesh = g_box
			groove.material_override = mat_arm_chamfer
			arm_node.add_child(groove)

			# Rounded end fillet caps
			for cap_sign in [-1.0, 1.0]:
				var cap := MeshInstance3D.new()
				var cyl := CylinderMesh.new()
				cyl.top_radius = arm_width * 0.5
				cyl.bottom_radius = arm_width * 0.5
				cyl.height = arm_thick
				cyl.radial_segments = 24
				cap.mesh = cyl
				cap.rotation.x = deg_to_rad(90)
				cap.position = Vector3(0, cap_sign * (arm_vis_len * 0.45), 0)
				cap.material_override = mat_arm_body
				arm_node.add_child(cap)

			links_container.add_child(arm_node)
			arm_nodes.append(arm_node)

	# 4. Architectural Brass / Gold Pivot Pins
	pin_nodes.clear()
	var total_pins: int = 1 + n_stages * 3
	for p in range(total_pins):
		var pin_root := Node3D.new()
		pin_root.name = "Pin_%d" % p

		var pin_mesh := MeshInstance3D.new()
		var p_cyl := CylinderMesh.new()
		p_cyl.top_radius = 0.026
		p_cyl.bottom_radius = 0.026
		p_cyl.height = 0.092
		p_cyl.radial_segments = 24
		pin_mesh.mesh = p_cyl
		pin_mesh.rotation.x = deg_to_rad(90)
		pin_mesh.material_override = mat_joint_brass
		pin_root.add_child(pin_mesh)

		# Accent anodized collar rings on front & back
		for z_side in [-0.044, 0.044]:
			var washer := MeshInstance3D.new()
			var w_cyl := CylinderMesh.new()
			w_cyl.top_radius = 0.035
			w_cyl.bottom_radius = 0.035
			w_cyl.height = 0.008
			w_cyl.radial_segments = 24
			washer.mesh = w_cyl
			washer.rotation.x = deg_to_rad(90)
			washer.position = Vector3(0, 0, z_side)
			washer.material_override = mat_pin_accent
			pin_root.add_child(washer)

		pins_container.add_child(pin_root)
		pin_nodes.append(pin_root)

	# 5. Chunky Chrome Helical Spring (Located across Stage 0)
	base_spring_vis_height = get_base_resting_H() * visual_scale
	spring_mesh_instance = MeshInstance3D.new()
	spring_mesh_instance.name = "UpperLinearSpring"
	spring_mesh_instance.material_override = mat_spring_chrome
	spring_mesh_instance.mesh = SpringMeshGenerator.generate_spring(
		base_spring_vis_height,
		0.048,
		7.5,
		0.010,
		90,
		10
	)
	add_child(spring_mesh_instance)

	# 6. Bottom Suspended Mass Assembly
	mass_assembly = Node3D.new()
	mass_assembly.name = "SuspendedMassAssembly"
	add_child(mass_assembly)

	var hook := MeshInstance3D.new()
	var hook_cyl := CylinderMesh.new()
	hook_cyl.top_radius = 0.008
	hook_cyl.bottom_radius = 0.008
	hook_cyl.height = 0.08
	hook.mesh = hook_cyl
	hook.position = Vector3(0, -0.04, 0)
	hook.material_override = mat_pin_steel
	mass_assembly.add_child(hook)

	mass_cylinder = MeshInstance3D.new()
	mass_cylinder.name = "MassCylinder"
	mass_cylinder.material_override = mat_mass_metal
	var cyl_mesh := CylinderMesh.new()
	cyl_mesh.radial_segments = 28
	mass_cylinder.mesh = cyl_mesh
	mass_assembly.add_child(mass_cylinder)

	# 7. Clean Laser Engraved Mass Indicator on Weight
	mass_label = Label3D.new()
	mass_label.name = "MassLabel"
	mass_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	mass_label.pixel_size = 0.0032
	mass_label.font_size = 20
	mass_label.shaded = false
	mass_label.modulate = Color(0.12, 0.13, 0.16)
	mass_label.outline_size = 4
	mass_label.outline_modulate = Color(1.0, 1.0, 1.0, 0.95)
	mass_assembly.add_child(mass_label)

	# 8. Overhead Rig Header
	rig_title_label = Label3D.new()
	rig_title_label.name = "RigTitleLabel"
	rig_title_label.position = Vector3(0, 0.38, 0.12)
	rig_title_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	rig_title_label.pixel_size = 0.0040
	rig_title_label.font_size = 24
	rig_title_label.shaded = false

	var theme: String = rig_color_theme.to_lower()
	if theme == "green" or is_scaled_123:
		rig_title_label.text = "RIG C  (1:2:3)"
		rig_title_label.modulate = Color(0.19, 0.82, 0.35)
	elif theme == "orange" or not is_left_rig:
		rig_title_label.text = "RIG B  (n=5)"
		rig_title_label.modulate = Color(0.95, 0.36, 0.0)
	else:
		rig_title_label.text = "RIG A  (n=3)"
		rig_title_label.modulate = Color(0.0, 0.443, 0.89)

	rig_title_label.outline_size = 5
	rig_title_label.outline_modulate = Color(1.0, 1.0, 1.0, 0.95)
	add_child(rig_title_label)

	# 9. Build Extension Dimension Lasers & Ticks
	_build_dimension_lasers()


func _process(delta: float) -> void:
	anim_time += delta
	_update_physics_targets()
	_update_kinematics(delta)
	_update_visuals()
	_broadcast_telemetry()


func _update_physics_targets() -> void:
	var effective_n: float = 6.0 if is_scaled_123 else float(n_stages)
	var struct_weight_factor: float = 3.0 if is_scaled_123 else (float(n_stages) * 0.5)

	effective_load_P = suspended_mass * gravity + struct_weight_factor * link_mass_per_stage * gravity
	var eta_safe: float = clampf(efficiency_eta, 0.50, 1.00)
	tensile_force_T = (effective_n * effective_load_P) / eta_safe

	spring_delta_H = tensile_force_T / spring_k
	var base_link_len: float = get_base_link_length()
	var base_rest_h: float = get_base_resting_H()
	var max_rhombus_h: float = base_link_len * 2.0 * 0.96
	target_H = clampf(base_rest_h + spring_delta_H, 0.035, max_rhombus_h)

	total_delta_L = effective_n * (target_H - base_rest_h)
	transmission_ratio_lambda = effective_n


func _update_kinematics(delta: float) -> void:
	# Prevent time spikes from causing numerical instability
	var dt: float = clampf(delta, 0.0005, 0.033)

	if not oscillations_enabled:
		# Butter-smooth critically damped glide with ZERO overshoot or jitter
		var smooth_speed: float = 14.0
		current_H = lerpf(current_H, target_H, clampf(dt * smooth_speed, 0.0, 1.0))
		velocity_H = 0.0
	else:
		# Physically derived natural frequency from stiffness k and suspended load:
		# omega_n = sqrt(k_eff / m_eff)
		var effective_n: float = 6.0 if is_scaled_123 else float(n_stages)
		var struct_weight_factor: float = 3.0 if is_scaled_123 else (float(n_stages) * 0.5)
		var total_m: float = maxf(suspended_mass + struct_weight_factor * link_mass_per_stage, 0.08)
		# Reflected mass at the upper spring: m_refl = m_total / (n^2)
		var m_eff_spring: float = total_m / maxf(effective_n * effective_n * 0.15, 1.0)
		var omega_phys: float = sqrt(spring_k / m_eff_spring)
		var omega: float = clampf(omega_phys, 8.0, 32.0)
		var damping: float = 2.0 * omega * damping_ratio_zeta

		# Stable sub-stepped symplectic integration
		var sub_steps: int = 4
		var sub_dt: float = dt / float(sub_steps)

		for step in range(sub_steps):
			var error: float = target_H - current_H
			var accel: float = omega * omega * error - damping * velocity_H
			velocity_H += accel * sub_dt
			current_H += velocity_H * sub_dt

	var base_link_len: float = get_base_link_length()
	current_H = clampf(current_H, 0.030, base_link_len * 2.0 * 0.96)

	var half_h: float = current_H * 0.5
	var ratio: float = clampf(half_h / base_link_len, 0.0, 0.999)
	current_theta = acos(ratio)
	current_W = 2.0 * base_link_len * sin(current_theta)

	if is_scaled_123:
		current_L = 6.0 * current_H
	else:
		current_L = float(n_stages) * current_H


func _update_visuals() -> void:
	var H_vis: float = current_H * visual_scale
	var W_vis: float = current_W * visual_scale
	var L_vis: float = current_L * visual_scale

	# 1. Update Scissor Arms
	var arm_counter: int = 0
	var current_y: float = 0.0

	for stage in range(n_stages):
		var m_stage: float = [1.0, 2.0, 3.0][stage] if is_scaled_123 else 1.0
		var h_s: float = m_stage * H_vis
		var w_s: float = m_stage * W_vis

		var y_top: float = current_y
		var y_mid: float = current_y - 0.5 * h_s
		var y_bot: float = current_y - h_s
		current_y = y_bot

		var p_top := Vector3(0, y_top, 0)
		var p_left := Vector3(-w_s * 0.5, y_mid, 0)
		var p_right := Vector3(w_s * 0.5, y_mid, 0)
		var p_bot := Vector3(0, y_bot, 0)

		_position_arm(arm_nodes[arm_counter], p_top, p_left, 0.020)
		arm_counter += 1

		_position_arm(arm_nodes[arm_counter], p_top, p_right, -0.020)
		arm_counter += 1

		_position_arm(arm_nodes[arm_counter], p_left, p_bot, -0.020)
		arm_counter += 1

		_position_arm(arm_nodes[arm_counter], p_right, p_bot, 0.020)
		arm_counter += 1

	# 2. Update Joint Pins
	var pin_counter: int = 0
	pin_nodes[pin_counter].position = Vector3(0, 0, 0)
	pin_counter += 1

	var pin_y: float = 0.0
	for stage in range(n_stages):
		var m_stage: float = [1.0, 2.0, 3.0][stage] if is_scaled_123 else 1.0
		var h_s: float = m_stage * H_vis
		var w_s: float = m_stage * W_vis

		var y_mid: float = pin_y - 0.5 * h_s
		var y_bot: float = pin_y - h_s
		pin_y = y_bot

		pin_nodes[pin_counter].position = Vector3(-w_s * 0.5, y_mid, 0)
		pin_counter += 1

		pin_nodes[pin_counter].position = Vector3(w_s * 0.5, y_mid, 0)
		pin_counter += 1

		pin_nodes[pin_counter].position = Vector3(0, y_bot, 0)
		pin_counter += 1

	# 3. Dynamic Spring Scale (Stage 0)
	var stretch_factor: float = H_vis / base_spring_vis_height
	spring_mesh_instance.scale = Vector3(1.0, stretch_factor, 1.0)

	# 4. Suspended Mass Assembly
	mass_assembly.position = Vector3(0, -L_vis, 0)

	var mass_ratio: float = clampf(suspended_mass / 1.5, 0.0, 1.0)
	var mass_h: float = 0.07 + 0.12 * mass_ratio
	var mass_r: float = 0.065 + 0.035 * mass_ratio

	var cyl_mesh: CylinderMesh = mass_cylinder.mesh as CylinderMesh
	if cyl_mesh:
		cyl_mesh.height = mass_h
		cyl_mesh.top_radius = mass_r
		cyl_mesh.bottom_radius = mass_r
	mass_cylinder.position = Vector3(0, -0.06 - mass_h * 0.5, 0)

	mass_label.position = Vector3(0, -0.06 - mass_h * 0.5, mass_r + 0.02)
	mass_label.text = "%.2f kg" % suspended_mass

	# 5. Extension Dimension Lasers & Ticks
	_update_dimension_lines(H_vis, W_vis, L_vis)


func _build_dimension_lasers() -> void:
	dimension_lines_container = Node3D.new()
	dimension_lines_container.name = "DimensionLasers"
	add_child(dimension_lines_container)

	var v_box := BoxMesh.new()
	v_box.size = Vector3(0.016, 1.0, 0.016)

	var h_box := BoxMesh.new()
	h_box.size = Vector3(1.0, 0.014, 0.014)

	# Vertical H line
	line_h = MeshInstance3D.new()
	line_h.mesh = v_box
	line_h.material_override = mat_laser
	dimension_lines_container.add_child(line_h)

	# Vertical L line
	line_l = MeshInstance3D.new()
	line_l.mesh = v_box
	line_l.material_override = mat_laser
	dimension_lines_container.add_child(line_l)

	# Clear Horizontal Tick Marks
	tick_top = MeshInstance3D.new()
	tick_top.mesh = h_box
	tick_top.material_override = mat_laser
	dimension_lines_container.add_child(tick_top)

	tick_mid = MeshInstance3D.new()
	tick_mid.mesh = h_box
	tick_mid.material_override = mat_laser
	dimension_lines_container.add_child(tick_mid)

	tick_bot = MeshInstance3D.new()
	tick_bot.mesh = h_box
	tick_bot.material_override = mat_laser
	dimension_lines_container.add_child(tick_bot)

	# Extension Arrowheads
	var cone_mesh := CylinderMesh.new()
	cone_mesh.top_radius = 0.0
	cone_mesh.bottom_radius = 0.028
	cone_mesh.height = 0.056
	cone_mesh.radial_segments = 18

	arrow_h_top = MeshInstance3D.new()
	arrow_h_top.mesh = cone_mesh
	arrow_h_top.material_override = mat_laser
	dimension_lines_container.add_child(arrow_h_top)

	arrow_h_bot = MeshInstance3D.new()
	arrow_h_bot.mesh = cone_mesh
	arrow_h_bot.rotation = Vector3(deg_to_rad(180), 0, 0)
	arrow_h_bot.material_override = mat_laser
	dimension_lines_container.add_child(arrow_h_bot)

	arrow_l_top = MeshInstance3D.new()
	arrow_l_top.mesh = cone_mesh
	arrow_l_top.material_override = mat_laser
	dimension_lines_container.add_child(arrow_l_top)

	arrow_l_bot = MeshInstance3D.new()
	arrow_l_bot.mesh = cone_mesh
	arrow_l_bot.rotation = Vector3(deg_to_rad(180), 0, 0)
	arrow_l_bot.material_override = mat_laser
	dimension_lines_container.add_child(arrow_l_bot)

	var label_color: Color
	var theme: String = rig_color_theme.to_lower()
	if theme == "green" or is_scaled_123:
		label_color = Color(0.25, 0.95, 0.45, 1.0) # Vivid Emerald Green
	elif theme == "orange" or not is_left_rig:
		label_color = Color(1.0, 0.52, 0.10, 1.0) # Vivid Ultra Orange
	else:
		label_color = Color(0.15, 0.65, 1.0, 1.0) # Vivid Electric Cyan-Blue

	# Bold System Font
	var bold_font := SystemFont.new()
	bold_font.font_weight = 800
	bold_font.font_names = PackedStringArray(["SF Pro Display", "Helvetica Neue", "Arial", "Segoe UI", "Sans-Serif"])

	dim_label_h = Label3D.new()
	dim_label_h.name = "DimLabelH"
	dim_label_h.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	dim_label_h.font = bold_font
	dim_label_h.pixel_size = 0.0035
	dim_label_h.font_size = 26
	dim_label_h.shaded = false
	dim_label_h.modulate = label_color
	dim_label_h.outline_size = 12
	dim_label_h.outline_modulate = Color(0.0, 0.0, 0.0, 1.0) # Solid black outline around text
	dim_label_h.render_priority = 2
	dimension_lines_container.add_child(dim_label_h)

	dim_label_l = Label3D.new()
	dim_label_l.name = "DimLabelL"
	dim_label_l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	dim_label_l.font = bold_font
	dim_label_l.pixel_size = 0.0035
	dim_label_l.font_size = 26
	dim_label_l.shaded = false
	dim_label_l.modulate = label_color
	dim_label_l.outline_size = 12
	dim_label_l.outline_modulate = Color(0.0, 0.0, 0.0, 1.0) # Solid black outline around text
	dim_label_l.render_priority = 2
	dimension_lines_container.add_child(dim_label_l)

	dimension_lines_container.visible = true


func _update_dimension_lines(h_vis: float, w_vis: float, l_vis: float) -> void:
	if not dimension_lines_container or not dimension_lines_container.visible:
		return
	if not line_h or not line_l or not dim_label_h or not dim_label_l:
		return

	var side_sign: float = laser_side_sign
	var max_w: float = (w_vis * 3.0) if is_scaled_123 else w_vis
	var x_h: float = side_sign * (max_w * 0.5 + 0.16)
	var x_l: float = side_sign * (max_w * 0.5 + 0.34)

	# 1. Vertical H Line (Anchor to Stage 0 bottom)
	line_h.position = Vector3(x_h, -h_vis * 0.5, 0.0)
	line_h.scale = Vector3(1.0, maxf(h_vis, 0.01), 1.0)

	arrow_h_top.position = Vector3(x_h, -0.024, 0.0)
	arrow_h_bot.position = Vector3(x_h, -h_vis + 0.024, 0.0)

	# 2. Vertical L Line (Anchor to bottom weight)
	line_l.position = Vector3(x_l, -l_vis * 0.5, 0.0)
	line_l.scale = Vector3(1.0, maxf(l_vis, 0.01), 1.0)

	arrow_l_top.position = Vector3(x_l, -0.024, 0.0)
	arrow_l_bot.position = Vector3(x_l, -l_vis + 0.024, 0.0)

	# 3. Horizontal Ticks
	var x_inner_top: float = side_sign * (max_w * 0.5 * 0.25)
	var x_outer_top: float = x_l + side_sign * 0.05
	var len_top: float = absf(x_outer_top - x_inner_top)
	tick_top.position = Vector3((x_inner_top + x_outer_top) * 0.5, 0.0, 0.0)
	tick_top.scale = Vector3(len_top, 1.0, 1.0)

	var x_inner_mid: float = side_sign * (max_w * 0.5 * 0.12)
	var x_outer_mid: float = x_h + side_sign * 0.05
	var len_mid: float = absf(x_outer_mid - x_inner_mid)
	tick_mid.position = Vector3((x_inner_mid + x_outer_mid) * 0.5, -h_vis, 0.0)
	tick_mid.scale = Vector3(len_mid, 1.0, 1.0)

	var x_inner_bot: float = side_sign * (max_w * 0.5 * 0.15)
	var x_outer_bot: float = x_l + side_sign * 0.05
	var len_bot: float = absf(x_outer_bot - x_inner_bot)
	tick_bot.position = Vector3((x_inner_bot + x_outer_bot) * 0.5, -l_vis, 0.0)
	tick_bot.scale = Vector3(len_bot, 1.0, 1.0)

	# 4. Dimension Callout Text with Black Outline
	var prefix_h: String = "H0" if is_scaled_123 else "H"
	dim_label_h.position = Vector3(x_h + side_sign * 0.12, -h_vis * 0.5, 0.02)
	dim_label_h.text = "%s = %.1f cm" % [prefix_h, current_H * 100.0]

	var mult_str: String = " (6×)" if is_scaled_123 else (" (%d×)" % n_stages)
	dim_label_l.position = Vector3(x_l + side_sign * 0.14, -l_vis * 0.5, 0.02)
	dim_label_l.text = "L = %.1f cm%s" % [current_L * 100.0, mult_str]


func _position_arm(arm_node: Node3D, p_a: Vector3, p_b: Vector3, z_offset: float) -> void:
	var midpoint: Vector3 = (p_a + p_b) * 0.5
	midpoint.z = z_offset
	arm_node.position = midpoint

	var dir: Vector3 = p_b - p_a
	var angle_z: float = atan2(dir.x, -dir.y)
	arm_node.rotation = Vector3(0, 0, angle_z)


func _broadcast_telemetry() -> void:
	var effective_n: float = 6.0 if is_scaled_123 else float(n_stages)
	var base_rest_h: float = get_base_resting_H()
	var work_in: float = tensile_force_T * maxf(0.0, current_H - base_rest_h)
	var work_out: float = effective_load_P * maxf(0.0, current_L - effective_n * base_rest_h)

	var data: Dictionary = {
		"rig_name": rig_name,
		"n_stages": n_stages,
		"is_scaled_123": is_scaled_123,
		"mass": suspended_mass,
		"k": spring_k,
		"gravity": gravity,
		"efficiency_eta": efficiency_eta,
		"effective_load_P": effective_load_P,
		"tensile_force_T": tensile_force_T,
		"delta_H_cm": (current_H - base_rest_h) * 100.0,
		"H_cm": current_H * 100.0,
		"delta_L_cm": (current_L - effective_n * base_rest_h) * 100.0,
		"L_cm": current_L * 100.0,
		"W_cm": current_W * 100.0,
		"theta_deg": rad_to_deg(current_theta),
		"transmission_lambda": current_L / current_H if current_H > 0.0001 else effective_n,
		"work_in_Joules": work_in,
		"work_out_Joules": work_out,
		"work_ratio_pct": efficiency_eta * 100.0
	}
	telemetry_updated.emit(data)


func set_mass(val: float) -> void:
	suspended_mass = clampf(val, 0.0, 1.5)


func set_stiffness(val: float) -> void:
	spring_k = clampf(val, 500.0, 1500.0)


func set_efficiency(val: float) -> void:
	efficiency_eta = clampf(val, 0.50, 1.00)


func set_gravity(val: float) -> void:
	gravity = clampf(val, 0.0, 25.0)


func set_oscillations_enabled(val: bool) -> void:
	oscillations_enabled = val
	if not oscillations_enabled:
		velocity_H = 0.0


func set_damping_ratio(val: float) -> void:
	damping_ratio_zeta = clampf(val, 0.05, 1.50)


func set_natural_frequency(val: float) -> void:
	natural_frequency_omega = clampf(val, 10.0, 35.0)


func apply_impulse(velocity_kick: float = 0.08) -> void:
	velocity_H += velocity_kick


func set_laser_visibility(enable_lasers: bool) -> void:
	if dimension_lines_container:
		dimension_lines_container.visible = enable_lasers
