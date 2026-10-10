class_name Main
extends Node3D

## Apple "Light Liquid Glass" Showroom Architecture (VisionOS Minimalist Aesthetic)
## Pure Light Studio | Tactile Physical Hardware Linkages | Frosted Glassmorphism UI

@onready var camera: OrbitCamera = $OrbitCamera
@onready var rig_a: PantographRig = $RigA
@onready var rig_b: PantographRig = $RigB

# Liquid Glass UI Elements
var ui_layer: CanvasLayer
var mass_slider: HSlider
var mass_val_label: Label
var stiffness_slider: HSlider
var stiffness_val_label: Label
var efficiency_slider: HSlider
var efficiency_val_label: Label
var self_weight_check: CheckBox
var live_graph: LiveGraph

# Comparison Pill Labels
var label_a_delta_h: Label
var label_b_delta_h: Label

var label_a_h: Label
var label_b_h: Label

var label_a_l: Label
var label_b_l: Label

var label_a_lambda: Label
var label_b_lambda: Label

var label_a_t: Label
var label_b_t: Label

var label_a_work: Label
var label_b_work: Label

var ratio_bar_a: ProgressBar
var ratio_bar_b: ProgressBar

# State & Throttling
var telemetry_a: Dictionary = {}
var telemetry_b: Dictionary = {}
var is_slow_motion: bool = false
var lasers_enabled: bool = true
var ui_timer: float = 0.0


func _ready() -> void:
	_setup_pure_light_studio()
	_setup_showroom_bay()
	_setup_rigs()
	_build_liquid_glass_ui()
	_apply_preset(0.5, 1000.0, 1.0)


func _process(delta: float) -> void:
	ui_timer += delta
	if ui_timer >= 0.033:
		ui_timer = 0.0
		_update_ui_telemetry()


func _setup_pure_light_studio() -> void:
	var env_node := get_node_or_null("WorldEnvironment") as WorldEnvironment
	if env_node == null:
		env_node = WorldEnvironment.new()
		env_node.name = "WorldEnvironment"
		add_child(env_node)

	var env := Environment.new()

	# 1. Apple Keynote Showroom Sky Gradient (#F6F7F9 to #E2E4EB)
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.965, 0.968, 0.976) # Studio pure off-white #F6F7F9
	sky_mat.sky_horizon_color = Color(0.885, 0.895, 0.92) # Soft cool studio grey #E2E4EB
	sky_mat.ground_bottom_color = Color(0.84, 0.85, 0.88)
	sky_mat.ground_horizon_color = Color(0.885, 0.895, 0.92)
	sky_mat.sun_angle_max = 25.0
	sky.sky_material = sky_mat
	env.sky = sky

	# 2. Balanced Studio Ambient Light (Preserves 3D form shading on white PLA)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.88, 0.89, 0.92)
	env.ambient_light_energy = 0.65

	# 3. Tonemapping & SSAO Photorealism (No harsh bloom)
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.tonemap_exposure = 1.04
	env.ssao_enabled = true
	env.ssao_radius = 1.6
	env.ssao_intensity = 1.3
	env.ssao_power = 1.4
	env.ssr_enabled = true
	env.ssr_max_steps = 32
	env.glow_enabled = false # Clean Apple hardware showcase

	env_node.environment = env

	# 4. Warm-Neutral Key Directional Light (Soft diffused contact shadows)
	var dir_light := get_node_or_null("DirectionalLight3D") as DirectionalLight3D
	if dir_light == null:
		dir_light = DirectionalLight3D.new()
		dir_light.name = "DirectionalLight3D"
		add_child(dir_light)
	dir_light.light_color = Color(1.0, 0.992, 0.98)
	dir_light.light_energy = 1.35
	dir_light.rotation = Vector3(deg_to_rad(-34.0), deg_to_rad(30.0), 0.0)
	dir_light.shadow_enabled = true
	dir_light.shadow_bias = 0.015
	dir_light.shadow_blur = 1.2
	dir_light.shadow_opacity = 0.65

	# 5. Soft Studio Fill Light (Front-Top Diffused Softbox)
	var fill_light := DirectionalLight3D.new()
	fill_light.light_color = Color(0.92, 0.94, 0.98)
	fill_light.light_energy = 0.45
	fill_light.rotation = Vector3(deg_to_rad(-12.0), deg_to_rad(-35.0), 0.0)
	fill_light.shadow_enabled = false
	add_child(fill_light)

	# 6. Subtle Rim Backlight (Accentuates physical edges and rounded chamfers)
	var rim_light := DirectionalLight3D.new()
	rim_light.light_color = Color(0.98, 0.98, 1.0)
	rim_light.light_energy = 0.40
	rim_light.rotation = Vector3(deg_to_rad(25.0), deg_to_rad(155.0), 0.0)
	rim_light.shadow_enabled = false
	add_child(rim_light)


func _setup_showroom_bay() -> void:
	var bay := Node3D.new()
	bay.name = "ShowroomBay"
	add_child(bay)

	# 1. Seamless Studio Floor Plane (Soft studio grey #E5E5EA)
	var floor_inst := MeshInstance3D.new()
	var floor_mesh := PlaneMesh.new()
	floor_mesh.size = Vector2(80.0, 80.0)
	floor_inst.mesh = floor_mesh
	floor_inst.position = Vector3(0, 0.0, 0)
	var mat_floor := StandardMaterial3D.new()
	mat_floor.albedo_color = Color(0.905, 0.91, 0.925)
	mat_floor.metallic = 0.02
	mat_floor.roughness = 0.45
	floor_inst.material_override = mat_floor
	bay.add_child(floor_inst)

	# 2. Sleek Architectural Gantry Frame (Matte Anodized Space-Titanium #33363F)
	var mat_gantry := StandardMaterial3D.new()
	mat_gantry.albedo_color = Color(0.24, 0.25, 0.28)
	mat_gantry.metallic = 0.85
	mat_gantry.roughness = 0.28

	var mat_gantry_accent := StandardMaterial3D.new()
	mat_gantry_accent.albedo_color = Color(0.78, 0.80, 0.85)
	mat_gantry_accent.metallic = 0.95
	mat_gantry_accent.roughness = 0.18

	# Overhead horizontal beam at Y = 3.58 (Span 6.0m)
	var overhead_bar := MeshInstance3D.new()
	var bar_mesh := BoxMesh.new()
	bar_mesh.size = Vector3(6.0, 0.16, 0.22)
	overhead_bar.mesh = bar_mesh
	overhead_bar.position = Vector3(0, 3.58, 0)
	overhead_bar.material_override = mat_gantry
	bay.add_child(overhead_bar)

	# Polished silver rail guide running along the top beam
	var rail := MeshInstance3D.new()
	var rail_mesh := BoxMesh.new()
	rail_mesh.size = Vector3(5.98, 0.02, 0.06)
	rail.mesh = rail_mesh
	rail.position = Vector3(0, 3.50, 0.11)
	rail.material_override = mat_gantry_accent
	bay.add_child(rail)

	# Support Pillars at X = -2.75 and +2.75 (Ample clearance from UI cards)
	for x_pos in [-2.75, 2.75]:
		var pillar := MeshInstance3D.new()
		var p_mesh := BoxMesh.new()
		p_mesh.size = Vector3(0.16, 3.50, 0.2)
		pillar.mesh = p_mesh
		pillar.position = Vector3(x_pos, 1.75, 0)
		pillar.material_override = mat_gantry
		bay.add_child(pillar)

		# Precision aluminum footing plinth resting on the studio floor
		var footing := MeshInstance3D.new()
		var f_mesh := BoxMesh.new()
		f_mesh.size = Vector3(0.36, 0.08, 0.36)
		footing.mesh = f_mesh
		footing.position = Vector3(x_pos, 0.04, 0)
		footing.material_override = mat_gantry_accent
		bay.add_child(footing)


func _setup_rigs() -> void:
	if rig_a == null:
		rig_a = PantographRig.new()
		rig_a.name = "RigA"
		rig_a.n_stages = 3
		rig_a.rig_name = "Rig A (n=3)"
		rig_a.position = Vector3(-1.60, 3.5, 0.0)
		rig_a.is_left_rig = true
		add_child(rig_a)
	else:
		rig_a.position = Vector3(-1.60, 3.5, 0.0)
		rig_a.n_stages = 3
		rig_a.rig_name = "Rig A (n=3)"
		rig_a.is_left_rig = true

	if rig_b == null:
		rig_b = PantographRig.new()
		rig_b.name = "RigB"
		rig_b.n_stages = 5
		rig_b.rig_name = "Rig B (n=5)"
		rig_b.position = Vector3(1.60, 3.5, 0.0)
		rig_b.is_left_rig = false
		add_child(rig_b)
	else:
		rig_b.position = Vector3(1.60, 3.5, 0.0)
		rig_b.n_stages = 5
		rig_b.rig_name = "Rig B (n=5)"
		rig_b.is_left_rig = false

	if camera == null:
		camera = OrbitCamera.new()
		camera.name = "OrbitCamera"
		camera.target_point = Vector3(0.0, 1.75, 0.0)
		camera.default_distance = 5.9
		camera.fov = 57.0
		camera.target_pitch = deg_to_rad(-5.0)
		camera.pitch = deg_to_rad(-5.0)
		add_child(camera)
	else:
		camera.target_point = Vector3(0.0, 1.75, 0.0)
		camera.default_distance = 5.9
		camera.fov = 57.0
		camera.target_pitch = deg_to_rad(-5.0)
		camera.pitch = deg_to_rad(-5.0)

	# Connect telemetry signals
	rig_a.telemetry_updated.connect(_on_rig_a_telemetry)
	rig_b.telemetry_updated.connect(_on_rig_b_telemetry)


func _build_liquid_glass_ui() -> void:
	ui_layer = CanvasLayer.new()
	ui_layer.name = "UILayer"
	add_child(ui_layer)

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(root)

	# 1. FLOATING HEADER PILL (Centered horizontally between 360 and 1240)
	var header_panel := _create_liquid_glass_panel(Vector2(360, 16), Vector2(880, 68), 24)
	root.add_child(header_panel)

	var header_box := HBoxContainer.new()
	header_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	header_box.offset_left = 22
	header_box.offset_right = -22
	header_box.offset_top = 8
	header_box.offset_bottom = -8
	header_box.alignment = BoxContainer.ALIGNMENT_CENTER
	header_panel.add_child(header_box)

	var title_vbox := VBoxContainer.new()
	title_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var main_title := Label.new()
	main_title.text = "Scissor Pantograph Verification  ·  Golden Rule of Mechanics"
	main_title.add_theme_font_size_override("font_size", 15)
	main_title.add_theme_color_override("font_color", Color(0.114, 0.114, 0.122)) # Deep Charcoal #1D1D1F
	title_vbox.add_child(main_title)

	var math_header := RichTextLabel.new()
	math_header.bbcode_enabled = true
	math_header.fit_content = true
	math_header.text = "[color=#0071E3][b]δA_out = η · δA_in[/b][/color]   ·   [color=#2C2C2E]P_eff · δL = η · (T · δH)[/color]   ·   [color=#1D1D1F][b]ΔL = n · ΔH[/b][/color]   ·   [color=#0071E3][b]T = (n · P_eff) / η[/b][/color]"
	math_header.add_theme_font_size_override("normal_font_size", 12)
	title_vbox.add_child(math_header)

	header_box.add_child(title_vbox)

	# Header Action Pills
	var btn_reset_cam := _create_liquid_button("Reset View")
	btn_reset_cam.pressed.connect(func(): camera.reset_camera())
	header_box.add_child(btn_reset_cam)

	var btn_slowmo := _create_liquid_button("Slow Motion")
	btn_slowmo.toggle_mode = true
	btn_slowmo.toggled.connect(func(toggled_on: bool):
		is_slow_motion = toggled_on
		Engine.time_scale = 0.3 if is_slow_motion else 1.0
		btn_slowmo.text = "Normal Speed" if is_slow_motion else "Slow Motion"
	)
	header_box.add_child(btn_slowmo)

	var btn_lasers := _create_liquid_button("Hide Lasers")
	btn_lasers.toggle_mode = true
	btn_lasers.button_pressed = true
	btn_lasers.toggled.connect(func(toggled_on: bool):
		lasers_enabled = toggled_on
		rig_a.set_laser_visibility(lasers_enabled)
		rig_b.set_laser_visibility(lasers_enabled)
		btn_lasers.text = "Hide Lasers" if lasers_enabled else "Show Lasers"
	)
	header_box.add_child(btn_lasers)

	# 2. LEFT MINIMALIST CONTROL CARD (Left 24 to 360)
	var left_panel := _create_liquid_glass_panel(Vector2(24, 96), Vector2(336, 580), 22)
	root.add_child(left_panel)

	var left_margin := MarginContainer.new()
	left_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	left_margin.add_theme_constant_override("margin_top", 24)
	left_margin.add_theme_constant_override("margin_bottom", 24)
	left_margin.add_theme_constant_override("margin_left", 20)
	left_margin.add_theme_constant_override("margin_right", 20)
	left_panel.add_child(left_margin)

	var left_vbox := VBoxContainer.new()
	left_vbox.add_theme_constant_override("separation", 14)
	left_margin.add_child(left_vbox)

	var panel_title := Label.new()
	panel_title.text = "Parameters"
	panel_title.add_theme_font_size_override("font_size", 16)
	panel_title.add_theme_color_override("font_color", Color(0.114, 0.114, 0.122))
	left_vbox.add_child(panel_title)

	var sep1 := HSeparator.new()
	left_vbox.add_child(sep1)

	# 1. Suspended Mass Slider
	var mass_hbox := HBoxContainer.new()
	var mass_title := Label.new()
	mass_title.text = "Suspended Mass"
	mass_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mass_title.add_theme_color_override("font_color", Color(0.114, 0.114, 0.122)) # Charcoal #1D1D1F
	mass_hbox.add_child(mass_title)

	mass_val_label = Label.new()
	mass_val_label.text = "0.50 kg"
	mass_val_label.add_theme_color_override("font_color", Color(0.0, 0.443, 0.89)) # Apple Tech-Blue #0071E3
	mass_hbox.add_child(mass_val_label)
	left_vbox.add_child(mass_hbox)

	mass_slider = HSlider.new()
	mass_slider.min_value = 0.0
	mass_slider.max_value = 1.5
	mass_slider.step = 0.01
	mass_slider.value = 0.5
	mass_slider.value_changed.connect(_on_mass_slider_changed)
	_style_tech_slider(mass_slider)
	left_vbox.add_child(mass_slider)

	# 2. Spring Constant Slider
	var k_hbox := HBoxContainer.new()
	var k_title := Label.new()
	k_title.text = "Spring Constant (k)"
	k_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	k_title.add_theme_color_override("font_color", Color(0.114, 0.114, 0.122)) # Charcoal #1D1D1F
	k_hbox.add_child(k_title)

	stiffness_val_label = Label.new()
	stiffness_val_label.text = "1000 N/m"
	stiffness_val_label.add_theme_color_override("font_color", Color(0.0, 0.443, 0.89)) # Apple Tech-Blue #0071E3
	k_hbox.add_child(stiffness_val_label)
	left_vbox.add_child(k_hbox)

	stiffness_slider = HSlider.new()
	stiffness_slider.min_value = 500.0
	stiffness_slider.max_value = 1500.0
	stiffness_slider.step = 25.0
	stiffness_slider.value = 1000.0
	stiffness_slider.value_changed.connect(_on_stiffness_slider_changed)
	_style_tech_slider(stiffness_slider)
	left_vbox.add_child(stiffness_slider)

	# 3. Mechanical Efficiency (η) Slider [50% - 100%]
	var eta_hbox := HBoxContainer.new()
	var eta_title := Label.new()
	eta_title.text = "Transmission Efficiency (η)"
	eta_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	eta_title.add_theme_color_override("font_color", Color(0.114, 0.114, 0.122)) # Charcoal #1D1D1F
	eta_hbox.add_child(eta_title)

	efficiency_val_label = Label.new()
	efficiency_val_label.text = "100%"
	efficiency_val_label.add_theme_color_override("font_color", Color(0.0, 0.443, 0.89)) # Apple Tech-Blue #0071E3
	eta_hbox.add_child(efficiency_val_label)
	left_vbox.add_child(eta_hbox)

	efficiency_slider = HSlider.new()
	efficiency_slider.min_value = 50.0
	efficiency_slider.max_value = 100.0
	efficiency_slider.step = 1.0
	efficiency_slider.value = 100.0
	efficiency_slider.value_changed.connect(_on_efficiency_slider_changed)
	_style_tech_slider(efficiency_slider)
	left_vbox.add_child(efficiency_slider)

	# 4. Linkage Self-Weight Checkbox (No text clipping)
	self_weight_check = CheckBox.new()
	self_weight_check.text = "Compensate Link Weight (0.05 kg/n)"
	self_weight_check.button_pressed = true
	var dark_charcoal := Color(0.114, 0.114, 0.122) # Charcoal #1D1D1F
	self_weight_check.add_theme_color_override("font_color", dark_charcoal)
	self_weight_check.add_theme_color_override("font_pressed_color", dark_charcoal)
	self_weight_check.add_theme_color_override("font_hover_color", dark_charcoal)
	self_weight_check.add_theme_color_override("font_focus_color", dark_charcoal)
	self_weight_check.add_theme_color_override("font_hover_pressed_color", dark_charcoal)
	self_weight_check.toggled.connect(func(pressed: bool):
		var w: float = 0.05 if pressed else 0.0
		rig_a.link_mass_per_stage = w
		rig_b.link_mass_per_stage = w
		if live_graph != null:
			live_graph.set_link_mass(w)
	)
	left_vbox.add_child(self_weight_check)

	var sep2 := HSeparator.new()
	left_vbox.add_child(sep2)

	# 5. Calibration Presets (Equal 50/50 fill, no clipping)
	var preset_title := Label.new()
	preset_title.text = "Mass Presets"
	preset_title.add_theme_font_size_override("font_size", 12)
	preset_title.add_theme_color_override("font_color", Color(0.17, 0.17, 0.19)) # #2C2C2E
	left_vbox.add_child(preset_title)

	var preset_grid := GridContainer.new()
	preset_grid.columns = 2
	preset_grid.add_theme_constant_override("h_separation", 10)
	preset_grid.add_theme_constant_override("v_separation", 8)
	preset_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_vbox.add_child(preset_grid)

	var btn_p0 := _create_liquid_button("0.0 kg (Zero)")
	btn_p0.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_p0.pressed.connect(func(): mass_slider.value = 0.0)
	preset_grid.add_child(btn_p0)

	var btn_p1 := _create_liquid_button("0.5 kg (Std)")
	btn_p1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_p1.pressed.connect(func(): mass_slider.value = 0.5)
	preset_grid.add_child(btn_p1)

	var btn_p2 := _create_liquid_button("1.0 kg (Heavy)")
	btn_p2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_p2.pressed.connect(func(): mass_slider.value = 1.0)
	preset_grid.add_child(btn_p2)

	var btn_p3 := _create_liquid_button("1.5 kg (Max)")
	btn_p3.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_p3.pressed.connect(func(): mass_slider.value = 1.5)
	preset_grid.add_child(btn_p3)

	var sep3 := HSeparator.new()
	left_vbox.add_child(sep3)

	# 6. Smooth Kinetic Impulse Trigger
	var btn_jolt := _create_liquid_button("Apply Dynamic Impulse")
	btn_jolt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var blue_accent := Color(0.0, 0.443, 0.89) # Apple Tech-Blue #0071E3
	btn_jolt.add_theme_color_override("font_color", blue_accent)
	btn_jolt.add_theme_color_override("font_pressed_color", blue_accent)
	btn_jolt.add_theme_color_override("font_hover_color", blue_accent)
	btn_jolt.add_theme_color_override("font_focus_color", blue_accent)
	btn_jolt.add_theme_color_override("font_hover_pressed_color", blue_accent)
	btn_jolt.pressed.connect(func():
		rig_a.apply_impulse(0.09)
		rig_b.apply_impulse(0.09)
	)
	left_vbox.add_child(btn_jolt)

	# 3. RIGHT COMPARISON PILL (Right 1240 to 1576)
	var right_panel := _create_liquid_glass_panel(Vector2(1240, 96), Vector2(336, 580), 22)
	root.add_child(right_panel)

	var right_margin := MarginContainer.new()
	right_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	right_margin.add_theme_constant_override("margin_top", 24)
	right_margin.add_theme_constant_override("margin_bottom", 24)
	right_margin.add_theme_constant_override("margin_left", 20)
	right_margin.add_theme_constant_override("margin_right", 20)
	right_panel.add_child(right_margin)

	var right_vbox := VBoxContainer.new()
	right_vbox.add_theme_constant_override("separation", 14)
	right_margin.add_child(right_vbox)

	var telemetry_title := Label.new()
	telemetry_title.text = "Hardware Telemetry"
	telemetry_title.add_theme_font_size_override("font_size", 16)
	telemetry_title.add_theme_color_override("font_color", Color(0.114, 0.114, 0.122))
	right_vbox.add_child(telemetry_title)

	var sep4 := HSeparator.new()
	right_vbox.add_child(sep4)

	# Hardware Metrics Table (h_separation = 16, v_separation = 8)
	var table := GridContainer.new()
	table.columns = 3
	table.add_theme_constant_override("h_separation", 16)
	table.add_theme_constant_override("v_separation", 8)
	table.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_vbox.add_child(table)

	# Headers (High contrast dark charcoal #2C2C2E)
	table.add_child(_create_header_cell("METRIC"))
	table.add_child(_create_header_cell("RIG A [BLUE]"))
	table.add_child(_create_header_cell("RIG B [ORANGE]"))

	# Row 1: Stages n
	table.add_child(_create_label_cell("Stages (n)"))
	table.add_child(_create_value_cell("n = 3", Color(0.0, 0.443, 0.89)))
	table.add_child(_create_value_cell("n = 5", Color(1.0, 0.42, 0.05)))

	# Row 2: Stretch Delta H
	table.add_child(_create_label_cell("Stretch (ΔH)"))
	label_a_delta_h = _create_value_cell("+0.00 cm", Color(0.0, 0.443, 0.89))
	label_b_delta_h = _create_value_cell("+0.00 cm", Color(1.0, 0.42, 0.05))
	table.add_child(label_a_delta_h)
	table.add_child(label_b_delta_h)

	# Row 3: Single Rhombus H
	table.add_child(_create_label_cell("Height (H)"))
	label_a_h = _create_value_cell("7.50 cm")
	label_b_h = _create_value_cell("7.50 cm")
	table.add_child(label_a_h)
	table.add_child(label_b_h)

	# Row 4: Total Length L
	table.add_child(_create_label_cell("Total Span (L)"))
	label_a_l = _create_value_cell("22.50 cm")
	label_b_l = _create_value_cell("37.50 cm")
	table.add_child(label_a_l)
	table.add_child(label_b_l)

	# Row 5: Transmission Ratio lambda = L / H
	table.add_child(_create_label_cell("Ratio (λ ≡ L/H)"))
	label_a_lambda = _create_value_cell("3.000×", Color(0.0, 0.443, 0.89))
	label_b_lambda = _create_value_cell("5.000×", Color(1.0, 0.42, 0.05))
	table.add_child(label_a_lambda)
	table.add_child(label_b_lambda)

	# Row 6: Tensile Force T
	table.add_child(_create_label_cell("Tension (T)"))
	label_a_t = _create_value_cell("0.0 N")
	label_b_t = _create_value_cell("0.0 N")
	table.add_child(label_a_t)
	table.add_child(label_b_t)

	# Row 7: Work Ratio
	table.add_child(_create_label_cell("Work Ratio"))
	label_a_work = _create_value_cell("100.0%", Color(0.204, 0.78, 0.35))
	label_b_work = _create_value_cell("100.0%", Color(0.204, 0.78, 0.35))
	table.add_child(label_a_work)
	table.add_child(label_b_work)

	var sep5 := HSeparator.new()
	right_vbox.add_child(sep5)

	# Extension Gauges
	var bar_title := Label.new()
	bar_title.text = "Extension Comparison"
	bar_title.add_theme_font_size_override("font_size", 12)
	bar_title.add_theme_color_override("font_color", Color(0.17, 0.17, 0.19))
	right_vbox.add_child(bar_title)

	var bar_a_lbl := Label.new()
	bar_a_lbl.text = "Rig A [Blue] (n=3) Span:"
	bar_a_lbl.add_theme_font_size_override("font_size", 11)
	bar_a_lbl.add_theme_color_override("font_color", Color(0.114, 0.114, 0.122))
	right_vbox.add_child(bar_a_lbl)

	ratio_bar_a = ProgressBar.new()
	ratio_bar_a.min_value = 0.0
	ratio_bar_a.max_value = 60.0
	ratio_bar_a.show_percentage = true
	_style_progress_bar(ratio_bar_a, Color(0.0, 0.443, 0.89)) # Apple Tech-Blue
	right_vbox.add_child(ratio_bar_a)

	var bar_b_lbl := Label.new()
	bar_b_lbl.text = "Rig B [Orange] (n=5) Span:"
	bar_b_lbl.add_theme_font_size_override("font_size", 11)
	bar_b_lbl.add_theme_color_override("font_color", Color(0.114, 0.114, 0.122))
	right_vbox.add_child(bar_b_lbl)

	ratio_bar_b = ProgressBar.new()
	ratio_bar_b.min_value = 0.0
	ratio_bar_b.max_value = 60.0
	ratio_bar_b.show_percentage = true
	_style_progress_bar(ratio_bar_b, Color(1.0, 0.42, 0.05)) # Apple Ultra Orange
	right_vbox.add_child(ratio_bar_b)

	# 4. BOTTOM FLOATING REALTIME 2D PLOT (Anchored bottom-center, margin_bottom = -16, height = 186)
	var bottom_panel := _create_liquid_glass_panel(Vector2(0, 0), Vector2(880, 186), 22, 0.78)
	bottom_panel.anchor_left = 0.5
	bottom_panel.anchor_right = 0.5
	bottom_panel.anchor_top = 1.0
	bottom_panel.anchor_bottom = 1.0
	bottom_panel.offset_left = -440.0
	bottom_panel.offset_right = 440.0
	bottom_panel.offset_top = -202.0 # 186px height + 16px bottom margin
	bottom_panel.offset_bottom = -16.0
	root.add_child(bottom_panel)

	var graph_margin := MarginContainer.new()
	graph_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	graph_margin.add_theme_constant_override("margin_top", 24)
	graph_margin.add_theme_constant_override("margin_bottom", 24)
	graph_margin.add_theme_constant_override("margin_left", 20)
	graph_margin.add_theme_constant_override("margin_right", 20)
	bottom_panel.add_child(graph_margin)

	live_graph = LiveGraph.new()
	live_graph.name = "LiveGraph"
	live_graph.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	live_graph.size_flags_vertical = Control.SIZE_EXPAND_FILL
	live_graph.mass_scrubbed.connect(func(new_m: float):
		mass_slider.value = new_m
	)
	graph_margin.add_child(live_graph)


func _on_mass_slider_changed(val: float) -> void:
	mass_val_label.text = "%.2f kg" % val
	rig_a.set_mass(val)
	rig_b.set_mass(val)
	if live_graph != null:
		live_graph.set_mass(val)


func _on_stiffness_slider_changed(val: float) -> void:
	stiffness_val_label.text = "%d N/m" % int(val)
	rig_a.set_stiffness(val)
	rig_b.set_stiffness(val)
	if live_graph != null:
		live_graph.set_stiffness(val)


func _on_efficiency_slider_changed(val: float) -> void:
	efficiency_val_label.text = "%d%%" % int(val)
	var eta_norm: float = val / 100.0
	rig_a.set_efficiency(eta_norm)
	rig_b.set_efficiency(eta_norm)
	if live_graph != null:
		live_graph.set_efficiency(eta_norm)


func _apply_preset(m: float, k: float, eta: float = 1.0) -> void:
	mass_slider.value = m
	stiffness_slider.value = k
	efficiency_slider.value = eta * 100.0
	if live_graph != null:
		live_graph.set_mass(m)
		live_graph.set_stiffness(k)
		live_graph.set_efficiency(eta)


func _on_rig_a_telemetry(data: Dictionary) -> void:
	telemetry_a = data


func _on_rig_b_telemetry(data: Dictionary) -> void:
	telemetry_b = data


func _update_ui_telemetry() -> void:
	if telemetry_a.is_empty() or telemetry_b.is_empty():
		return

	# Update Rig A numbers
	label_a_delta_h.text = "+%.2f cm" % telemetry_a.get("delta_H_cm", 0.0)
	label_a_h.text = "%.2f cm" % telemetry_a.get("H_cm", 0.0)
	label_a_l.text = "%.2f cm" % telemetry_a.get("L_cm", 0.0)
	label_a_lambda.text = "%.3f×" % telemetry_a.get("transmission_lambda", 3.0)
	label_a_t.text = "%.2f N" % telemetry_a.get("tensile_force_T", 0.0)
	label_a_work.text = "%.1f%%" % telemetry_a.get("work_ratio_pct", 100.0)

	# Update Rig B numbers
	label_b_delta_h.text = "+%.2f cm" % telemetry_b.get("delta_H_cm", 0.0)
	label_b_h.text = "%.2f cm" % telemetry_b.get("H_cm", 0.0)
	label_b_l.text = "%.2f cm" % telemetry_b.get("L_cm", 0.0)
	label_b_lambda.text = "%.3f×" % telemetry_b.get("transmission_lambda", 5.0)
	label_b_t.text = "%.2f N" % telemetry_b.get("tensile_force_T", 0.0)
	label_b_work.text = "%.1f%%" % telemetry_b.get("work_ratio_pct", 100.0)

	# Update Extension comparison bars
	ratio_bar_a.value = telemetry_a.get("L_cm", 0.0)
	ratio_bar_b.value = telemetry_b.get("L_cm", 0.0)


# --- VisionOS Liquid Glass UI Helpers ---
func _create_liquid_glass_panel(pos: Vector2, size: Vector2, radius: int = 22, bg_alpha: float = 0.50) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.position = pos
	panel.custom_minimum_size = size
	panel.size = size

	var style := StyleBoxFlat.new()
	# Translucent frosted white background (#FFFFFF at specified alpha)
	style.bg_color = Color(1.0, 1.0, 1.0, bg_alpha)
	# Crisp hairline highlight (#FFFFFF at alpha 0.80)
	style.border_color = Color(1.0, 1.0, 1.0, 0.8)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	# Smooth modern pill/card corner radius
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.corner_detail = 12
	# Subtle diffuse soft shadow (#000000 at alpha 0.06)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.06)
	style.shadow_size = 14
	style.shadow_offset = Vector2(0, 5)

	panel.add_theme_stylebox_override("panel", style)
	return panel


func _create_liquid_button(text: String) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(105, 32)
	btn.add_theme_font_size_override("font_size", 12)

	# Strictly enforce high-contrast dark charcoal (#1D1D1F) across ALL button states
	var dark_charcoal := Color(0.114, 0.114, 0.122)
	btn.add_theme_color_override("font_color", dark_charcoal)
	btn.add_theme_color_override("font_pressed_color", dark_charcoal)
	btn.add_theme_color_override("font_hover_color", dark_charcoal)
	btn.add_theme_color_override("font_focus_color", dark_charcoal)
	btn.add_theme_color_override("font_hover_pressed_color", dark_charcoal)

	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(1.0, 1.0, 1.0, 0.65)
	normal.border_color = Color(1.0, 1.0, 1.0, 0.9)
	normal.border_width_left = 1
	normal.border_width_top = 1
	normal.border_width_right = 1
	normal.border_width_bottom = 1
	normal.corner_radius_top_left = 16
	normal.corner_radius_top_right = 16
	normal.corner_radius_bottom_left = 16
	normal.corner_radius_bottom_right = 16
	normal.corner_detail = 10
	normal.shadow_color = Color(0.0, 0.0, 0.0, 0.04)
	normal.shadow_size = 6
	normal.shadow_offset = Vector2(0, 2)
	btn.add_theme_stylebox_override("normal", normal)

	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(1.0, 1.0, 1.0, 0.9)
	hover.border_color = Color(0.0, 0.443, 0.89, 0.4)
	hover.border_width_left = 1
	hover.border_width_top = 1
	hover.border_width_right = 1
	hover.border_width_bottom = 1
	hover.corner_radius_top_left = 16
	hover.corner_radius_top_right = 16
	hover.corner_radius_bottom_left = 16
	hover.corner_radius_bottom_right = 16
	hover.corner_detail = 10
	hover.shadow_color = Color(0.0, 0.0, 0.0, 0.08)
	hover.shadow_size = 8
	hover.shadow_offset = Vector2(0, 3)
	btn.add_theme_stylebox_override("hover", hover)

	# Active / Toggled Pressed State: Subtle Apple Tech Blue (#0071E3 at 15% opacity) with crisp border
	var pressed := StyleBoxFlat.new()
	pressed.bg_color = Color(0.0, 0.443, 0.89, 0.15)
	pressed.border_color = Color(0.0, 0.443, 0.89, 0.80)
	pressed.border_width_left = 1
	pressed.border_width_top = 1
	pressed.border_width_right = 1
	pressed.border_width_bottom = 1
	pressed.corner_radius_top_left = 16
	pressed.corner_radius_top_right = 16
	pressed.corner_radius_bottom_left = 16
	pressed.corner_radius_bottom_right = 16
	pressed.corner_detail = 10
	pressed.shadow_color = Color(0.0, 0.443, 0.89, 0.12)
	pressed.shadow_size = 6
	pressed.shadow_offset = Vector2(0, 2)
	btn.add_theme_stylebox_override("pressed", pressed)

	var focus := StyleBoxFlat.new()
	focus.draw_center = false
	focus.border_color = Color(0.0, 0.443, 0.89, 0.50)
	focus.border_width_left = 1
	focus.border_width_top = 1
	focus.border_width_right = 1
	focus.border_width_bottom = 1
	focus.corner_radius_top_left = 16
	focus.corner_radius_top_right = 16
	focus.corner_radius_bottom_left = 16
	focus.corner_radius_bottom_right = 16
	btn.add_theme_stylebox_override("focus", focus)

	return btn


func _style_tech_slider(slider: HSlider) -> void:
	var track := StyleBoxFlat.new()
	track.bg_color = Color(0.84, 0.85, 0.88)
	track.corner_radius_top_left = 3
	track.corner_radius_top_right = 3
	track.corner_radius_bottom_left = 3
	track.corner_radius_bottom_right = 3
	track.content_margin_top = 3
	track.content_margin_bottom = 3
	slider.add_theme_stylebox_override("slider", track)

	var active := StyleBoxFlat.new()
	active.bg_color = Color(0.0, 0.443, 0.89) # Apple Tech-Blue #0071E3
	active.corner_radius_top_left = 3
	active.corner_radius_bottom_left = 3
	slider.add_theme_stylebox_override("grabber_area", active)
	slider.add_theme_stylebox_override("grabber_area_highlight", active)


func _style_progress_bar(bar: ProgressBar, fill_color: Color) -> void:
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.86, 0.87, 0.90)
	bg.corner_radius_top_left = 5
	bg.corner_radius_top_right = 5
	bg.corner_radius_bottom_left = 5
	bg.corner_radius_bottom_right = 5
	bar.add_theme_stylebox_override("background", bg)

	var fill := StyleBoxFlat.new()
	fill.bg_color = fill_color
	fill.corner_radius_top_left = 5
	fill.corner_radius_bottom_left = 5
	bar.add_theme_stylebox_override("fill", fill)


func _create_header_cell(text: String) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 11)
	lbl.add_theme_color_override("font_color", Color(0.17, 0.17, 0.19)) # High contrast #2C2C2E
	return lbl


func _create_label_cell(text: String) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.add_theme_color_override("font_color", Color(0.114, 0.114, 0.122)) # Charcoal #1D1D1F
	return lbl


func _create_value_cell(text: String, color: Color = Color(0.114, 0.114, 0.122)) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.add_theme_color_override("font_color", color)
	return lbl
