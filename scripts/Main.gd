class_name Main
extends Node3D

## Apple "Light Liquid Glass" Showroom Architecture (VisionOS Minimalist Aesthetic)
## Pure Light Studio | Tactile Physical Hardware Linkages | Frosted Glassmorphism UI

@onready var camera: OrbitCamera = $OrbitCamera
@onready var rig_a: PantographRig = $RigA
@onready var rig_c: PantographRig = $RigC
@onready var rig_b: PantographRig = $RigB

# Liquid Glass UI Elements
var ui_layer: CanvasLayer
var mass_slider: HSlider
var mass_val_label: Label
var stiffness_slider: HSlider
var stiffness_val_label: Label
var efficiency_slider: HSlider
var efficiency_val_label: Label
var gravity_slider: HSlider
var gravity_val_label: Label
var self_weight_check: CheckBox
var oscillations_check: CheckBox
var damping_slider: HSlider
var damping_val_label: Label
var live_graph: LiveGraph
var bottom_panel: PanelContainer
var is_graph_maximized: bool = false
var btn_graph_expand: Button
var btn_graph_theme: Button
var formulas_modal: PanelContainer

# Comparison Pill Labels
var label_a_delta_h: Label
var label_c_delta_h: Label
var label_b_delta_h: Label

var label_a_h: Label
var label_c_h: Label
var label_b_h: Label

var label_a_l: Label
var label_c_l: Label
var label_b_l: Label

var label_a_lambda: Label
var label_c_lambda: Label
var label_b_lambda: Label

var label_a_t: Label
var label_c_t: Label
var label_b_t: Label

var label_a_work: Label
var label_c_work: Label
var label_b_work: Label

var ratio_bar_a: ProgressBar
var ratio_bar_c: ProgressBar
var ratio_bar_b: ProgressBar

# State & Throttling
var telemetry_a: Dictionary = {}
var telemetry_c: Dictionary = {}
var telemetry_b: Dictionary = {}
var is_slow_motion: bool = false
var lasers_enabled: bool = true
var ui_timer: float = 0.0


func _ready() -> void:
	_setup_pure_light_studio()
	_setup_showroom_bay()
	_setup_rigs()
	_build_liquid_glass_ui()
	_apply_preset(0.5, 1000.0, 1.0, 9.81)


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

	# 1. Apple Keynote Showroom Sky Gradient
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.965, 0.968, 0.976)
	sky_mat.sky_horizon_color = Color(0.885, 0.895, 0.92)
	sky_mat.ground_bottom_color = Color(0.84, 0.85, 0.88)
	sky_mat.ground_horizon_color = Color(0.885, 0.895, 0.92)
	sky_mat.sun_angle_max = 25.0
	sky.sky_material = sky_mat
	env.sky = sky

	# 2. Balanced Studio Ambient Light
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.88, 0.89, 0.92)
	env.ambient_light_energy = 0.65

	# 3. Tonemapping & SSAO Photorealism
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.tonemap_exposure = 1.04
	env.ssao_enabled = true
	env.ssao_radius = 1.6
	env.ssao_intensity = 1.3
	env.ssao_power = 1.4
	env.ssr_enabled = true
	env.ssr_max_steps = 32
	env.glow_enabled = false

	env_node.environment = env

	# 4. Warm-Neutral Key Directional Light
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

	# 5. Soft Studio Fill Light
	var fill_light := DirectionalLight3D.new()
	fill_light.light_color = Color(0.92, 0.94, 0.98)
	fill_light.light_energy = 0.45
	fill_light.rotation = Vector3(deg_to_rad(-12.0), deg_to_rad(-35.0), 0.0)
	fill_light.shadow_enabled = false
	add_child(fill_light)

	# 6. Rim Backlight
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

	# 1. Studio Floor Plane
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

	# 2. Architectural Gantry Frame
	var mat_gantry := StandardMaterial3D.new()
	mat_gantry.albedo_color = Color(0.24, 0.25, 0.28)
	mat_gantry.metallic = 0.85
	mat_gantry.roughness = 0.28

	var mat_gantry_accent := StandardMaterial3D.new()
	mat_gantry_accent.albedo_color = Color(0.78, 0.80, 0.85)
	mat_gantry_accent.metallic = 0.95
	mat_gantry_accent.roughness = 0.18

	# Overhead horizontal beam (Span 6.0m)
	var overhead_bar := MeshInstance3D.new()
	var bar_mesh := BoxMesh.new()
	bar_mesh.size = Vector3(6.0, 0.16, 0.22)
	overhead_bar.mesh = bar_mesh
	overhead_bar.position = Vector3(0, 3.58, 0)
	overhead_bar.material_override = mat_gantry
	bay.add_child(overhead_bar)

	# Polished silver rail guide
	var rail := MeshInstance3D.new()
	var rail_mesh := BoxMesh.new()
	rail_mesh.size = Vector3(5.98, 0.02, 0.06)
	rail.mesh = rail_mesh
	rail.position = Vector3(0, 3.50, 0.11)
	rail.material_override = mat_gantry_accent
	bay.add_child(rail)

	# Support Pillars at X = -2.85 and +2.85
	for x_pos in [-2.85, 2.85]:
		var pillar := MeshInstance3D.new()
		var p_mesh := BoxMesh.new()
		p_mesh.size = Vector3(0.16, 3.50, 0.2)
		pillar.mesh = p_mesh
		pillar.position = Vector3(x_pos, 1.75, 0)
		pillar.material_override = mat_gantry
		bay.add_child(pillar)

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
		rig_a.rig_color_theme = "blue"
		rig_a.position = Vector3(-1.65, 3.5, 0.0)
		rig_a.is_left_rig = true
		rig_a.laser_side_sign = -1.0
		add_child(rig_a)
	else:
		rig_a.position = Vector3(-1.65, 3.5, 0.0)
		rig_a.n_stages = 3
		rig_a.rig_name = "Rig A (n=3)"
		rig_a.rig_color_theme = "blue"
		rig_a.is_left_rig = true
		rig_a.laser_side_sign = -1.0

	if rig_c == null:
		rig_c = PantographRig.new()
		rig_c.name = "RigC"
		rig_c.n_stages = 3
		rig_c.rig_name = "Rig C (1:2:3)"
		rig_c.is_scaled_123 = true
		rig_c.rig_color_theme = "green"
		rig_c.position = Vector3(0.0, 3.5, 0.0)
		rig_c.laser_side_sign = 1.0
		add_child(rig_c)
	else:
		rig_c.position = Vector3(0.0, 3.5, 0.0)
		rig_c.n_stages = 3
		rig_c.rig_name = "Rig C (1:2:3)"
		rig_c.is_scaled_123 = true
		rig_c.rig_color_theme = "green"
		rig_c.laser_side_sign = 1.0

	if rig_b == null:
		rig_b = PantographRig.new()
		rig_b.name = "RigB"
		rig_b.n_stages = 5
		rig_b.rig_name = "Rig B (n=5)"
		rig_b.rig_color_theme = "orange"
		rig_b.position = Vector3(1.65, 3.5, 0.0)
		rig_b.is_left_rig = false
		rig_b.laser_side_sign = 1.0
		add_child(rig_b)
	else:
		rig_b.position = Vector3(1.65, 3.5, 0.0)
		rig_b.n_stages = 5
		rig_b.rig_name = "Rig B (n=5)"
		rig_b.rig_color_theme = "orange"
		rig_b.is_left_rig = false
		rig_b.laser_side_sign = 1.0

	if camera == null:
		camera = OrbitCamera.new()
		camera.name = "OrbitCamera"
		camera.target_point = Vector3(0.0, 1.80, 0.0)
		camera.default_distance = 6.0
		camera.fov = 58.0
		camera.target_pitch = deg_to_rad(-5.0)
		camera.pitch = deg_to_rad(-5.0)
		add_child(camera)
	else:
		camera.target_point = Vector3(0.0, 1.80, 0.0)
		camera.default_distance = 6.0
		camera.fov = 58.0
		camera.target_pitch = deg_to_rad(-5.0)
		camera.pitch = deg_to_rad(-5.0)

	# Connect telemetry signals
	rig_a.telemetry_updated.connect(_on_rig_a_telemetry)
	rig_c.telemetry_updated.connect(_on_rig_c_telemetry)
	rig_b.telemetry_updated.connect(_on_rig_b_telemetry)


func _build_liquid_glass_ui() -> void:
	ui_layer = CanvasLayer.new()
	ui_layer.name = "UILayer"
	add_child(ui_layer)

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(root)

	# 1. FLOATING HEADER PILL
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
	main_title.add_theme_font_size_override("font_size", 14)
	main_title.add_theme_color_override("font_color", Color(0.114, 0.114, 0.122))
	title_vbox.add_child(main_title)

	var sub_title := Label.new()
	sub_title.text = "Sim-to-Real Multi-Linkage Physics Workbench  ·  Karen Ghardashyan"
	sub_title.add_theme_font_size_override("font_size", 11)
	sub_title.add_theme_color_override("font_color", Color(0.40, 0.42, 0.48))
	title_vbox.add_child(sub_title)

	header_box.add_child(title_vbox)

	# Header Action Pills
	var btn_formulas := _create_liquid_button("📘 Formulas & Theory")
	btn_formulas.custom_minimum_size = Vector2(135, 30)
	var blue_accent := Color(0.0, 0.443, 0.89)
	btn_formulas.add_theme_color_override("font_color", blue_accent)
	btn_formulas.add_theme_color_override("font_pressed_color", blue_accent)
	btn_formulas.add_theme_color_override("font_hover_color", blue_accent)
	btn_formulas.pressed.connect(func():
		if formulas_modal != null:
			formulas_modal.visible = not formulas_modal.visible
	)
	header_box.add_child(btn_formulas)

	var btn_reset_cam := _create_liquid_button("Reset View")
	btn_reset_cam.custom_minimum_size = Vector2(92, 30)
	btn_reset_cam.pressed.connect(func(): camera.reset_camera())
	header_box.add_child(btn_reset_cam)

	var btn_slowmo := _create_liquid_button("Slow Motion")
	btn_slowmo.custom_minimum_size = Vector2(92, 30)
	btn_slowmo.toggle_mode = true
	btn_slowmo.toggled.connect(func(toggled_on: bool):
		is_slow_motion = toggled_on
		Engine.time_scale = 0.3 if is_slow_motion else 1.0
		btn_slowmo.text = "Normal Speed" if is_slow_motion else "Slow Motion"
	)
	header_box.add_child(btn_slowmo)

	var btn_lasers := _create_liquid_button("Hide Lasers")
	btn_lasers.custom_minimum_size = Vector2(92, 30)
	btn_lasers.toggle_mode = true
	btn_lasers.button_pressed = true
	btn_lasers.toggled.connect(func(toggled_on: bool):
		lasers_enabled = toggled_on
		rig_a.set_laser_visibility(lasers_enabled)
		rig_c.set_laser_visibility(lasers_enabled)
		rig_b.set_laser_visibility(lasers_enabled)
		btn_lasers.text = "Hide Lasers" if lasers_enabled else "Show Lasers"
	)
	header_box.add_child(btn_lasers)

	# 2. LEFT MINIMALIST CONTROL CARD
	var left_panel := _create_liquid_glass_panel(Vector2(24, 96), Vector2(336, 750), 22)
	root.add_child(left_panel)

	var left_margin := MarginContainer.new()
	left_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	left_margin.add_theme_constant_override("margin_top", 20)
	left_margin.add_theme_constant_override("margin_bottom", 20)
	left_margin.add_theme_constant_override("margin_left", 18)
	left_margin.add_theme_constant_override("margin_right", 18)
	left_panel.add_child(left_margin)

	var left_vbox := VBoxContainer.new()
	left_vbox.add_theme_constant_override("separation", 10)
	left_margin.add_child(left_vbox)

	var panel_title := Label.new()
	panel_title.text = "Simulation Parameters"
	panel_title.add_theme_font_size_override("font_size", 15)
	panel_title.add_theme_color_override("font_color", Color(0.114, 0.114, 0.122))
	left_vbox.add_child(panel_title)

	var sep1 := HSeparator.new()
	left_vbox.add_child(sep1)

	# 1. Suspended Mass Slider
	var mass_hbox := HBoxContainer.new()
	var mass_title := Label.new()
	mass_title.text = "Suspended Mass (m)"
	mass_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mass_title.add_theme_font_size_override("font_size", 12)
	mass_title.add_theme_color_override("font_color", Color(0.114, 0.114, 0.122))
	mass_hbox.add_child(mass_title)

	mass_val_label = Label.new()
	mass_val_label.text = "0.50 kg"
	mass_val_label.add_theme_font_size_override("font_size", 12)
	mass_val_label.add_theme_color_override("font_color", Color(0.0, 0.443, 0.89))
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
	k_title.text = "Spring Stiffness (k)"
	k_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	k_title.add_theme_font_size_override("font_size", 12)
	k_title.add_theme_color_override("font_color", Color(0.114, 0.114, 0.122))
	k_hbox.add_child(k_title)

	stiffness_val_label = Label.new()
	stiffness_val_label.text = "1000 N/m"
	stiffness_val_label.add_theme_font_size_override("font_size", 12)
	stiffness_val_label.add_theme_color_override("font_color", Color(0.0, 0.443, 0.89))
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

	# 3. Transmission Efficiency Slider
	var eta_hbox := HBoxContainer.new()
	var eta_title := Label.new()
	eta_title.text = "Efficiency (η)"
	eta_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	eta_title.add_theme_font_size_override("font_size", 12)
	eta_title.add_theme_color_override("font_color", Color(0.114, 0.114, 0.122))
	eta_hbox.add_child(eta_title)

	efficiency_val_label = Label.new()
	efficiency_val_label.text = "100%"
	efficiency_val_label.add_theme_font_size_override("font_size", 12)
	efficiency_val_label.add_theme_color_override("font_color", Color(0.0, 0.443, 0.89))
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

	# 4. Gravity Variable (g) Slider & Presets
	var g_hbox := HBoxContainer.new()
	var g_title := Label.new()
	g_title.text = "Gravity Acceleration (g)"
	g_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	g_title.add_theme_font_size_override("font_size", 12)
	g_title.add_theme_color_override("font_color", Color(0.114, 0.114, 0.122))
	g_hbox.add_child(g_title)

	gravity_val_label = Label.new()
	gravity_val_label.text = "9.81 m/s² (Earth)"
	gravity_val_label.add_theme_font_size_override("font_size", 12)
	gravity_val_label.add_theme_color_override("font_color", Color(0.0, 0.443, 0.89))
	g_hbox.add_child(gravity_val_label)
	left_vbox.add_child(g_hbox)

	gravity_slider = HSlider.new()
	gravity_slider.min_value = 0.0
	gravity_slider.max_value = 25.0
	gravity_slider.step = 0.1
	gravity_slider.value = 9.81
	gravity_slider.value_changed.connect(_on_gravity_slider_changed)
	_style_tech_slider(gravity_slider)
	left_vbox.add_child(gravity_slider)

	# Planet presets bar
	var planet_grid := GridContainer.new()
	planet_grid.columns = 3
	planet_grid.add_theme_constant_override("h_separation", 6)
	planet_grid.add_theme_constant_override("v_separation", 4)
	planet_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_vbox.add_child(planet_grid)

	var btn_g_zero := _create_liquid_button("Zero-G (0.0)")
	btn_g_zero.custom_minimum_size = Vector2(88, 26)
	btn_g_zero.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_g_zero.pressed.connect(func(): gravity_slider.value = 0.0)
	planet_grid.add_child(btn_g_zero)

	var btn_g_moon := _create_liquid_button("Moon (1.62)")
	btn_g_moon.custom_minimum_size = Vector2(88, 26)
	btn_g_moon.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_g_moon.pressed.connect(func(): gravity_slider.value = 1.62)
	planet_grid.add_child(btn_g_moon)

	var btn_g_mars := _create_liquid_button("Mars (3.71)")
	btn_g_mars.custom_minimum_size = Vector2(88, 26)
	btn_g_mars.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_g_mars.pressed.connect(func(): gravity_slider.value = 3.71)
	planet_grid.add_child(btn_g_mars)

	var btn_g_earth := _create_liquid_button("Earth (9.81)")
	btn_g_earth.custom_minimum_size = Vector2(88, 26)
	btn_g_earth.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_g_earth.pressed.connect(func(): gravity_slider.value = 9.81)
	planet_grid.add_child(btn_g_earth)

	var btn_g_jupiter := _create_liquid_button("Jupiter (24.8)")
	btn_g_jupiter.custom_minimum_size = Vector2(88, 26)
	btn_g_jupiter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_g_jupiter.pressed.connect(func(): gravity_slider.value = 24.79)
	planet_grid.add_child(btn_g_jupiter)

	# 5. Linkage Self-Weight Checkbox
	self_weight_check = CheckBox.new()
	self_weight_check.text = "Compensate Link Weight (0.05 kg/n)"
	self_weight_check.button_pressed = true
	var dark_charcoal := Color(0.114, 0.114, 0.122)
	self_weight_check.add_theme_font_size_override("font_size", 12)
	self_weight_check.add_theme_color_override("font_color", dark_charcoal)
	self_weight_check.add_theme_color_override("font_pressed_color", dark_charcoal)
	self_weight_check.add_theme_color_override("font_hover_color", dark_charcoal)
	self_weight_check.add_theme_color_override("font_focus_color", dark_charcoal)
	self_weight_check.add_theme_color_override("font_hover_pressed_color", dark_charcoal)
	self_weight_check.toggled.connect(func(pressed: bool):
		var w: float = 0.05 if pressed else 0.0
		rig_a.link_mass_per_stage = w
		rig_c.link_mass_per_stage = w
		rig_b.link_mass_per_stage = w
		if live_graph != null:
			live_graph.set_link_mass(w)
	)
	left_vbox.add_child(self_weight_check)

	var sep2 := HSeparator.new()
	left_vbox.add_child(sep2)

	# 6. DYNAMIC OSCILLATIONS CONTROLS
	var osc_title := Label.new()
	osc_title.text = "Harmonic Oscillations"
	osc_title.add_theme_font_size_override("font_size", 13)
	osc_title.add_theme_color_override("font_color", Color(0.114, 0.114, 0.122))
	left_vbox.add_child(osc_title)

	oscillations_check = CheckBox.new()
	oscillations_check.text = "Enable Spring Oscillation / Ringing"
	oscillations_check.button_pressed = false
	oscillations_check.add_theme_font_size_override("font_size", 12)
	oscillations_check.add_theme_color_override("font_color", dark_charcoal)
	oscillations_check.add_theme_color_override("font_pressed_color", dark_charcoal)
	oscillations_check.add_theme_color_override("font_hover_color", dark_charcoal)
	oscillations_check.add_theme_color_override("font_focus_color", dark_charcoal)
	oscillations_check.add_theme_color_override("font_hover_pressed_color", dark_charcoal)
	oscillations_check.toggled.connect(func(pressed: bool):
		rig_a.set_oscillations_enabled(pressed)
		rig_c.set_oscillations_enabled(pressed)
		rig_b.set_oscillations_enabled(pressed)
	)
	left_vbox.add_child(oscillations_check)

	var damp_hbox := HBoxContainer.new()
	var damp_title := Label.new()
	damp_title.text = "Damping Ratio (ζ)"
	damp_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	damp_title.add_theme_font_size_override("font_size", 12)
	damp_title.add_theme_color_override("font_color", Color(0.114, 0.114, 0.122))
	damp_hbox.add_child(damp_title)

	damping_val_label = Label.new()
	damping_val_label.text = "0.65"
	damping_val_label.add_theme_font_size_override("font_size", 12)
	damping_val_label.add_theme_color_override("font_color", Color(0.0, 0.443, 0.89))
	damp_hbox.add_child(damping_val_label)
	left_vbox.add_child(damp_hbox)

	damping_slider = HSlider.new()
	damping_slider.min_value = 0.05
	damping_slider.max_value = 1.20
	damping_slider.step = 0.05
	damping_slider.value = 0.65
	damping_slider.value_changed.connect(func(val: float):
		damping_val_label.text = "%.2f" % val
		rig_a.set_damping_ratio(val)
		rig_c.set_damping_ratio(val)
		rig_b.set_damping_ratio(val)
	)
	_style_tech_slider(damping_slider)
	left_vbox.add_child(damping_slider)

	# Dynamic Impulse Button
	var btn_jolt := _create_liquid_button("Apply Dynamic Impulse (Kick)")
	btn_jolt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var blue_accent := Color(0.0, 0.443, 0.89)
	btn_jolt.add_theme_color_override("font_color", blue_accent)
	btn_jolt.add_theme_color_override("font_pressed_color", blue_accent)
	btn_jolt.add_theme_color_override("font_hover_color", blue_accent)
	btn_jolt.add_theme_color_override("font_focus_color", blue_accent)
	btn_jolt.add_theme_color_override("font_hover_pressed_color", blue_accent)
	btn_jolt.pressed.connect(func():
		oscillations_check.button_pressed = true
		rig_a.apply_impulse(0.09)
		rig_c.apply_impulse(0.09)
		rig_b.apply_impulse(0.09)
	)
	left_vbox.add_child(btn_jolt)

	# 3. RIGHT COMPARISON CARD (4 Columns: METRIC | RIG A | RIG C | RIG B)
	var right_panel := _create_liquid_glass_panel(Vector2(1240, 96), Vector2(336, 750), 22)
	root.add_child(right_panel)

	var right_margin := MarginContainer.new()
	right_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	right_margin.add_theme_constant_override("margin_top", 20)
	right_margin.add_theme_constant_override("margin_bottom", 20)
	right_margin.add_theme_constant_override("margin_left", 16)
	right_margin.add_theme_constant_override("margin_right", 16)
	right_panel.add_child(right_margin)

	var right_vbox := VBoxContainer.new()
	right_vbox.add_theme_constant_override("separation", 10)
	right_margin.add_child(right_vbox)

	var telemetry_title := Label.new()
	telemetry_title.text = "Hardware Telemetry"
	telemetry_title.add_theme_font_size_override("font_size", 15)
	telemetry_title.add_theme_color_override("font_color", Color(0.114, 0.114, 0.122))
	right_vbox.add_child(telemetry_title)

	var sep4 := HSeparator.new()
	right_vbox.add_child(sep4)

	# Hardware Metrics Table: 4 columns
	var table := GridContainer.new()
	table.columns = 4
	table.add_theme_constant_override("h_separation", 8)
	table.add_theme_constant_override("v_separation", 6)
	table.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_vbox.add_child(table)

	# Column Headers
	table.add_child(_create_header_cell("METRIC"))
	table.add_child(_create_header_cell("RIG A"))
	table.add_child(_create_header_cell("RIG C"))
	table.add_child(_create_header_cell("RIG B"))

	# Row 1: Ratio (lambda)
	table.add_child(_create_label_cell("Ratio (λ)"))
	label_a_lambda = _create_value_cell("3.000×", Color(0.0, 0.443, 0.89))
	label_c_lambda = _create_value_cell("6.000×", Color(0.19, 0.82, 0.35))
	label_b_lambda = _create_value_cell("5.000×", Color(1.0, 0.42, 0.05))
	table.add_child(label_a_lambda)
	table.add_child(label_c_lambda)
	table.add_child(label_b_lambda)

	# Row 2: Stretch Delta H
	table.add_child(_create_label_cell("Stretch ΔH"))
	label_a_delta_h = _create_value_cell("+0.00 cm", Color(0.0, 0.443, 0.89))
	label_c_delta_h = _create_value_cell("+0.00 cm", Color(0.19, 0.82, 0.35))
	label_b_delta_h = _create_value_cell("+0.00 cm", Color(1.0, 0.42, 0.05))
	table.add_child(label_a_delta_h)
	table.add_child(label_c_delta_h)
	table.add_child(label_b_delta_h)

	# Row 3: Height H
	table.add_child(_create_label_cell("Height H0"))
	label_a_h = _create_value_cell("7.50 cm")
	label_c_h = _create_value_cell("5.63 cm")
	label_b_h = _create_value_cell("7.50 cm")
	table.add_child(label_a_h)
	table.add_child(label_c_h)
	table.add_child(label_b_h)

	# Row 4: Total Length L
	table.add_child(_create_label_cell("Span (L)"))
	label_a_l = _create_value_cell("22.50 cm")
	label_c_l = _create_value_cell("33.75 cm")
	label_b_l = _create_value_cell("37.50 cm")
	table.add_child(label_a_l)
	table.add_child(label_c_l)
	table.add_child(label_b_l)

	# Row 5: Tensile Force T
	table.add_child(_create_label_cell("Tension T"))
	label_a_t = _create_value_cell("0.0 N")
	label_c_t = _create_value_cell("0.0 N")
	label_b_t = _create_value_cell("0.0 N")
	table.add_child(label_a_t)
	table.add_child(label_c_t)
	table.add_child(label_b_t)

	# Row 6: Work Ratio
	table.add_child(_create_label_cell("Work Ratio"))
	label_a_work = _create_value_cell("100.0%", Color(0.19, 0.82, 0.35))
	label_c_work = _create_value_cell("100.0%", Color(0.19, 0.82, 0.35))
	label_b_work = _create_value_cell("100.0%", Color(0.19, 0.82, 0.35))
	table.add_child(label_a_work)
	table.add_child(label_c_work)
	table.add_child(label_b_work)

	var sep5 := HSeparator.new()
	right_vbox.add_child(sep5)

	# Extension Gauges (3 Rigs)
	var bar_title := Label.new()
	bar_title.text = "Extension Comparison"
	bar_title.add_theme_font_size_override("font_size", 12)
	bar_title.add_theme_color_override("font_color", Color(0.17, 0.17, 0.19))
	right_vbox.add_child(bar_title)

	# Bar A
	var bar_a_lbl := Label.new()
	bar_a_lbl.text = "Rig A [Blue] (n=3) Span:"
	bar_a_lbl.add_theme_font_size_override("font_size", 11)
	bar_a_lbl.add_theme_color_override("font_color", Color(0.0, 0.443, 0.89))
	right_vbox.add_child(bar_a_lbl)

	ratio_bar_a = ProgressBar.new()
	ratio_bar_a.min_value = 0.0
	ratio_bar_a.max_value = 65.0
	ratio_bar_a.show_percentage = true
	_style_progress_bar(ratio_bar_a, Color(0.0, 0.443, 0.89))
	right_vbox.add_child(ratio_bar_a)

	# Bar C
	var bar_c_lbl := Label.new()
	bar_c_lbl.text = "Rig C [Green] (1:2:3) Span:"
	bar_c_lbl.add_theme_font_size_override("font_size", 11)
	bar_c_lbl.add_theme_color_override("font_color", Color(0.19, 0.82, 0.35))
	right_vbox.add_child(bar_c_lbl)

	ratio_bar_c = ProgressBar.new()
	ratio_bar_c.min_value = 0.0
	ratio_bar_c.max_value = 65.0
	ratio_bar_c.show_percentage = true
	_style_progress_bar(ratio_bar_c, Color(0.19, 0.82, 0.35))
	right_vbox.add_child(ratio_bar_c)

	# Bar B
	var bar_b_lbl := Label.new()
	bar_b_lbl.text = "Rig B [Orange] (n=5) Span:"
	bar_b_lbl.add_theme_font_size_override("font_size", 11)
	bar_b_lbl.add_theme_color_override("font_color", Color(1.0, 0.42, 0.05))
	right_vbox.add_child(bar_b_lbl)

	ratio_bar_b = ProgressBar.new()
	ratio_bar_b.min_value = 0.0
	ratio_bar_b.max_value = 65.0
	ratio_bar_b.show_percentage = true
	_style_progress_bar(ratio_bar_b, Color(1.0, 0.42, 0.05))
	right_vbox.add_child(ratio_bar_b)

	# 4. BOTTOM FLOATING REALTIME 2D PLOT (Enhanced VisionOS Glass Card)
	bottom_panel = _create_liquid_glass_panel(Vector2(0, 0), Vector2(920, 262), 22, 0.85)
	bottom_panel.anchor_left = 0.5
	bottom_panel.anchor_right = 0.5
	bottom_panel.anchor_top = 1.0
	bottom_panel.anchor_bottom = 1.0
	bottom_panel.offset_left = -460.0
	bottom_panel.offset_right = 460.0
	bottom_panel.offset_top = -278.0
	bottom_panel.offset_bottom = -16.0
	root.add_child(bottom_panel)

	var graph_margin := MarginContainer.new()
	graph_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	graph_margin.add_theme_constant_override("margin_top", 10)
	graph_margin.add_theme_constant_override("margin_bottom", 12)
	graph_margin.add_theme_constant_override("margin_left", 16)
	graph_margin.add_theme_constant_override("margin_right", 16)
	bottom_panel.add_child(graph_margin)

	var graph_vbox := VBoxContainer.new()
	graph_vbox.add_theme_constant_override("separation", 6)
	graph_margin.add_child(graph_vbox)

	# Graph Card Control Bar
	var graph_bar := HBoxContainer.new()
	graph_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var graph_card_title := Label.new()
	graph_card_title.text = "Theoretical Sim-to-Real Curves: L(m)"
	graph_card_title.add_theme_font_size_override("font_size", 12)
	graph_card_title.add_theme_color_override("font_color", Color(0.17, 0.17, 0.19))
	graph_bar.add_child(graph_card_title)

	var bar_spacer := Control.new()
	bar_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	graph_bar.add_child(bar_spacer)

	btn_graph_theme = _create_liquid_button("◑ Canvas Theme")
	btn_graph_theme.custom_minimum_size = Vector2(105, 26)
	btn_graph_theme.pressed.connect(func():
		if live_graph != null:
			live_graph.toggle_theme()
	)
	graph_bar.add_child(btn_graph_theme)

	btn_graph_expand = _create_liquid_button("⤢ Maximize Graph")
	btn_graph_expand.custom_minimum_size = Vector2(115, 26)
	btn_graph_expand.pressed.connect(func():
		is_graph_maximized = not is_graph_maximized
		if is_graph_maximized:
			bottom_panel.offset_top = -490.0
			bottom_panel.custom_minimum_size.y = 474.0
			btn_graph_expand.text = "⤡ Compact View"
		else:
			bottom_panel.offset_top = -278.0
			bottom_panel.custom_minimum_size.y = 262.0
			btn_graph_expand.text = "⤢ Maximize Graph"
		if live_graph != null:
			live_graph.queue_redraw()
	)
	graph_bar.add_child(btn_graph_expand)

	graph_vbox.add_child(graph_bar)

	live_graph = LiveGraph.new()
	live_graph.name = "LiveGraph"
	live_graph.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	live_graph.size_flags_vertical = Control.SIZE_EXPAND_FILL
	live_graph.mass_scrubbed.connect(func(new_m: float):
		mass_slider.value = new_m
	)
	graph_vbox.add_child(live_graph)

	# 5. FLOATING FORMULAS & THEORY MODAL WINDOW
	_build_formulas_modal(root)


func _build_formulas_modal(root: Control) -> void:
	formulas_modal = _create_liquid_glass_panel(Vector2(0, 0), Vector2(760, 560), 22, 0.96)
	formulas_modal.anchor_left = 0.5
	formulas_modal.anchor_right = 0.5
	formulas_modal.anchor_top = 0.5
	formulas_modal.anchor_bottom = 0.5
	formulas_modal.offset_left = -380.0
	formulas_modal.offset_right = 380.0
	formulas_modal.offset_top = -280.0
	formulas_modal.offset_bottom = 280.0
	formulas_modal.visible = false
	root.add_child(formulas_modal)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	margin.add_theme_constant_override("margin_left", 22)
	margin.add_theme_constant_override("margin_right", 22)
	formulas_modal.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)

	# Modal Header
	var modal_header := HBoxContainer.new()
	modal_header.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var modal_title := Label.new()
	modal_title.text = "Mathematical Formulation & Principles of Mechanics"
	modal_title.add_theme_font_size_override("font_size", 16)
	modal_title.add_theme_color_override("font_color", Color(0.114, 0.114, 0.122))
	modal_header.add_child(modal_title)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	modal_header.add_child(spacer)

	var btn_close := _create_liquid_button("✕ Close")
	btn_close.custom_minimum_size = Vector2(85, 28)
	btn_close.pressed.connect(func(): formulas_modal.visible = false)
	modal_header.add_child(btn_close)

	vbox.add_child(modal_header)

	var sep := HSeparator.new()
	vbox.add_child(sep)

	# Scroll Container for Formulas
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)

	var content_rtl := RichTextLabel.new()
	content_rtl.bbcode_enabled = true
	content_rtl.fit_content = true
	content_rtl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_rtl.mouse_filter = Control.MOUSE_FILTER_PASS
	scroll.add_child(content_rtl)

	var t := ""
	t += "[font_size=15][b]1. Conservation of Mechanical Energy & Virtual Work[/b][/font_size]\n"
	t += "[color=#2C2C2E]In an ideal static linkage, mechanical work done by input spring tension [b]T[/b] over upper rhombus vertical displacement [b]δH[/b] equals the work performed on the suspended load [b]P_eff[/b] over total mechanism extension [b]δL[/b]:[/color]\n\n"
	t += "   [color=#0071E3][b]δA_in = δA_out   ⟺   T · δH = P_eff · δL[/b][/color]\n\n"
	t += "[color=#595C66]Taking transmission efficiency η ∈ [0.5, 1.0] into account:[/color]\n"
	t += "   [color=#0071E3][b]P_eff · δL = η · (T · δH)   ⟺   T = (λ · P_eff) / η[/b][/color]\n\n"

	t += "[font_size=15][b]2. Kinematic Transmission Ratios (λ ≡ δL / δH)[/b][/font_size]\n"
	t += "[color=#0071E3]• [b]Rig A (n = 3 uniform):[/b][/color]   [b]L(m) = 3 · H(m)[/b]   ⟹   [color=#0071E3][b]λ_A = 3.000×[/b][/color]\n"
	t += "[color=#1E9C3C]• [b]Rig C (1:2:3 variable scissor):[/b][/color]   [b]L(m) = (1 + 2 + 3) · H_0(m) = 6 · H_0(m)[/b]   ⟹   [color=#1E9C3C][b]λ_C = 6.000×[/b][/color]\n"
	t += "[color=#FF6B0D]• [b]Rig B (n = 5 uniform):[/b][/color]   [b]L(m) = 5 · H(m)[/b]   ⟹   [color=#FF6B0D][b]λ_B = 5.000×[/b][/color]\n\n"

	t += "[font_size=15][b]3. Equilibrium of Forces with Linkage Self-Weight & Planetary Gravity (g)[/b][/font_size]\n"
	t += "[color=#2C2C2E]The total effective gravitational load acting on the mechanism includes both suspended mass [b]m[/b] and structural linkage self-weight [b]m_link[/b] (evaluated at the center of mass):[/color]\n\n"
	t += "   [b]P_eff = m · g + m_struct · g[/b]\n"
	t += "   [color=#595C66]• Uniform rigs (n stages):   m_struct = (n / 2) · m_link[/color]\n"
	t += "   [color=#595C66]• 1:2:3 progressive rig:      m_struct = 3.0 · m_link[/color]\n"
	t += "   [color=#595C66]• Planetary gravity presets: Zero-G (0.0), Moon (1.62), Mars (3.71), Earth (9.81), Jupiter (24.79)[/color]\n\n"

	t += "[font_size=15][b]4. Hooke's Law & Deflection (ΔH)[/b][/font_size]\n"
	t += "[color=#2C2C2E]Under linear spring stiffness [b]k[/b], upper rhombus elongation [b]ΔH[/b] and total mechanism span elongation [b]ΔL[/b] are:[/color]\n\n"
	t += "   [color=#0071E3][b]ΔH(m) = T(m) / k = (λ · P_eff) / (η · k)[/b][/color]\n"
	t += "   [color=#0071E3][b]ΔL(m) = λ · ΔH(m) = (λ² · P_eff) / (η · k)[/b][/color]\n\n"

	t += "[font_size=15][b]5. Experimental Stiffness Extraction (Linear Regression)[/b][/font_size]\n"
	t += "[color=#2C2C2E]Plotting ΔH vs. suspended load mass m yields a linear regression slope [b]tan(α) = (λ · g) / k[/b]:[/color]\n\n"
	t += "   [b]k = (λ · g) / tan(α)[/b]\n"
	t += "   [color=#595C66]Empirical laboratory results: k ≈ 981 N/m (Rig A)  |  k ≈ 1090 N/m (Rig B)[/color]\n\n"

	t += "[font_size=15][b]6. 2nd-Order Dynamic Harmonic Vibration ODE[/b][/font_size]\n"
	t += "[color=#2C2C2E]Spring-mass kinetic equation under viscous damping ratio [b]ζ[/b] and natural frequency [b]ω[/b]:[/color]\n\n"
	t += "   [b]d²H/dt² + 2ζω · (dH/dt) + ω² · (H - H_target) = 0[/b]\n"
	t += "   [color=#595C66]Integrated via 4-substep Symplectic Euler with numerical stability protection.[/color]\n"

	content_rtl.text = t



func _on_mass_slider_changed(val: float) -> void:
	mass_val_label.text = "%.2f kg" % val
	rig_a.set_mass(val)
	rig_c.set_mass(val)
	rig_b.set_mass(val)
	if live_graph != null:
		live_graph.set_mass(val)


func _on_stiffness_slider_changed(val: float) -> void:
	stiffness_val_label.text = "%d N/m" % int(val)
	rig_a.set_stiffness(val)
	rig_c.set_stiffness(val)
	rig_b.set_stiffness(val)
	if live_graph != null:
		live_graph.set_stiffness(val)


func _on_efficiency_slider_changed(val: float) -> void:
	efficiency_val_label.text = "%d%%" % int(val)
	var eta_norm: float = val / 100.0
	rig_a.set_efficiency(eta_norm)
	rig_c.set_efficiency(eta_norm)
	rig_b.set_efficiency(eta_norm)
	if live_graph != null:
		live_graph.set_efficiency(eta_norm)


func _on_gravity_slider_changed(val: float) -> void:
	var desc := ""
	if is_equal_approx(val, 0.0):
		desc = " (Zero-G)"
	elif absf(val - 1.62) < 0.2:
		desc = " (Moon)"
	elif absf(val - 3.71) < 0.2:
		desc = " (Mars)"
	elif absf(val - 9.81) < 0.2:
		desc = " (Earth)"
	elif absf(val - 24.79) < 0.5:
		desc = " (Jupiter)"

	gravity_val_label.text = "%.2f m/s²%s" % [val, desc]
	rig_a.set_gravity(val)
	rig_c.set_gravity(val)
	rig_b.set_gravity(val)
	if live_graph != null:
		live_graph.set_gravity(val)


func _apply_preset(m: float, k: float, eta: float = 1.0, g: float = 9.81) -> void:
	mass_slider.value = m
	stiffness_slider.value = k
	efficiency_slider.value = eta * 100.0
	gravity_slider.value = g
	if live_graph != null:
		live_graph.set_mass(m)
		live_graph.set_stiffness(k)
		live_graph.set_efficiency(eta)
		live_graph.set_gravity(g)


func _on_rig_a_telemetry(data: Dictionary) -> void:
	telemetry_a = data


func _on_rig_c_telemetry(data: Dictionary) -> void:
	telemetry_c = data


func _on_rig_b_telemetry(data: Dictionary) -> void:
	telemetry_b = data


func _update_ui_telemetry() -> void:
	if telemetry_a.is_empty() or telemetry_c.is_empty() or telemetry_b.is_empty():
		return

	# Update Rig A numbers
	label_a_delta_h.text = "+%.2f cm" % telemetry_a.get("delta_H_cm", 0.0)
	label_a_h.text = "%.2f cm" % telemetry_a.get("H_cm", 0.0)
	label_a_l.text = "%.2f cm" % telemetry_a.get("L_cm", 0.0)
	label_a_lambda.text = "%.3f×" % telemetry_a.get("transmission_lambda", 3.0)
	label_a_t.text = "%.2f N" % telemetry_a.get("tensile_force_T", 0.0)
	label_a_work.text = "%.1f%%" % telemetry_a.get("work_ratio_pct", 100.0)

	# Update Rig C numbers
	label_c_delta_h.text = "+%.2f cm" % telemetry_c.get("delta_H_cm", 0.0)
	label_c_h.text = "%.2f cm" % telemetry_c.get("H_cm", 0.0)
	label_c_l.text = "%.2f cm" % telemetry_c.get("L_cm", 0.0)
	label_c_lambda.text = "%.3f×" % telemetry_c.get("transmission_lambda", 6.0)
	label_c_t.text = "%.2f N" % telemetry_c.get("tensile_force_T", 0.0)
	label_c_work.text = "%.1f%%" % telemetry_c.get("work_ratio_pct", 100.0)

	# Update Rig B numbers
	label_b_delta_h.text = "+%.2f cm" % telemetry_b.get("delta_H_cm", 0.0)
	label_b_h.text = "%.2f cm" % telemetry_b.get("H_cm", 0.0)
	label_b_l.text = "%.2f cm" % telemetry_b.get("L_cm", 0.0)
	label_b_lambda.text = "%.3f×" % telemetry_b.get("transmission_lambda", 5.0)
	label_b_t.text = "%.2f N" % telemetry_b.get("tensile_force_T", 0.0)
	label_b_work.text = "%.1f%%" % telemetry_b.get("work_ratio_pct", 100.0)

	# Update Extension comparison bars
	ratio_bar_a.value = telemetry_a.get("L_cm", 0.0)
	ratio_bar_c.value = telemetry_c.get("L_cm", 0.0)
	ratio_bar_b.value = telemetry_b.get("L_cm", 0.0)


# --- VisionOS Liquid Glass UI Helpers ---
func _create_liquid_glass_panel(pos: Vector2, size: Vector2, radius: int = 22, bg_alpha: float = 0.50) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.position = pos
	panel.custom_minimum_size = size
	panel.size = size

	var style := StyleBoxFlat.new()
	style.bg_color = Color(1.0, 1.0, 1.0, bg_alpha)
	style.border_color = Color(1.0, 1.0, 1.0, 0.8)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.corner_detail = 12
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.06)
	style.shadow_size = 14
	style.shadow_offset = Vector2(0, 5)

	panel.add_theme_stylebox_override("panel", style)
	return panel


func _create_liquid_button(text: String) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(105, 30)
	btn.add_theme_font_size_override("font_size", 11)

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
	normal.corner_radius_top_left = 14
	normal.corner_radius_top_right = 14
	normal.corner_radius_bottom_left = 14
	normal.corner_radius_bottom_right = 14
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
	hover.corner_radius_top_left = 14
	hover.corner_radius_top_right = 14
	hover.corner_radius_bottom_left = 14
	hover.corner_radius_bottom_right = 14
	hover.corner_detail = 10
	hover.shadow_color = Color(0.0, 0.0, 0.0, 0.08)
	hover.shadow_size = 8
	hover.shadow_offset = Vector2(0, 3)
	btn.add_theme_stylebox_override("hover", hover)

	var pressed := StyleBoxFlat.new()
	pressed.bg_color = Color(0.0, 0.443, 0.89, 0.15)
	pressed.border_color = Color(0.0, 0.443, 0.89, 0.80)
	pressed.border_width_left = 1
	pressed.border_width_top = 1
	pressed.border_width_right = 1
	pressed.border_width_bottom = 1
	pressed.corner_radius_top_left = 14
	pressed.corner_radius_top_right = 14
	pressed.corner_radius_bottom_left = 14
	pressed.corner_radius_bottom_right = 14
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
	focus.corner_radius_top_left = 14
	focus.corner_radius_top_right = 14
	focus.corner_radius_bottom_left = 14
	focus.corner_radius_bottom_right = 14
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
	active.bg_color = Color(0.0, 0.443, 0.89)
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
	lbl.add_theme_font_size_override("font_size", 10)
	lbl.add_theme_color_override("font_color", Color(0.17, 0.17, 0.19))
	return lbl


func _create_label_cell(text: String) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 11)
	lbl.add_theme_color_override("font_color", Color(0.114, 0.114, 0.122))
	return lbl


func _create_value_cell(text: String, color: Color = Color(0.114, 0.114, 0.122)) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 11)
	lbl.add_theme_color_override("font_color", color)
	return lbl
