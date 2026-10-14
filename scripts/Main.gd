class_name Main
extends Node3D

## Apple "Light Liquid Glass" Showroom Architecture (VisionOS Minimalist Aesthetic)
## Pure Light Studio | Tactile Physical Hardware Linkages | Frosted Glassmorphism UI

@onready var camera: OrbitCamera = $OrbitCamera
@onready var rig_a: PantographRig = $RigA
@onready var rig_c: PantographRig = $RigC
@onready var rig_b: PantographRig = $RigB

# Dual Theme & Focus Mode State
var is_dark_theme: bool = false
var is_focus_mode: bool = false

# 3D Environment & Showroom Lighting References
var world_env: WorldEnvironment
var env_res: Environment
var sky_proc_mat: ProceduralSkyMaterial
var dir_light: DirectionalLight3D
var fill_light: DirectionalLight3D
var rim_light: DirectionalLight3D
var mat_floor: StandardMaterial3D
var mat_gantry: StandardMaterial3D
var mat_gantry_accent: StandardMaterial3D

# Liquid Glass UI Panels & Containers
var ui_layer: CanvasLayer
var header_panel: PanelContainer
var left_panel: PanelContainer
var left_margin: MarginContainer
var left_vbox: VBoxContainer
var right_panel: PanelContainer
var right_margin: MarginContainer
var right_vbox: VBoxContainer
var bottom_panel: PanelContainer
var graph_margin: MarginContainer
var graph_vbox: VBoxContainer
var is_graph_maximized: bool = false

var main_title: Label
var sub_title: Label
var btn_formulas: Button
var btn_reset_cam: Button
var btn_slowmo: Button
var btn_lasers: Button
var btn_theme_toggle: Button
var btn_focus_toggle: Button
var btn_restore_ui: Button
var btn_graph_expand: Button
var btn_graph_theme: Button
var formulas_modal: PanelContainer

# Right Panel Tabs (Integrated Joint Inspector)
var btn_tab_telemetry: Button
var btn_tab_joint: Button
var telemetry_view: VBoxContainer
var joint_view: VBoxContainer

# Mobile Native Top Bar & Slide-Out Sidebar Architecture
var is_mobile_layout: bool = false
var mobile_top_bar: PanelContainer
var btn_mobile_menu: Button
var btn_focus_all: Button
var btn_focus_a: Button
var btn_focus_c: Button
var btn_focus_b: Button
var btn_mob_theme: Button
var btn_mob_reset: Button

var backdrop_scrim: ColorRect
var mobile_sidebar: PanelContainer
var btn_close_sidebar: Button
var btn_mob_tab_0: Button
var btn_mob_tab_1: Button
var btn_mob_tab_2: Button
var btn_mob_tab_3: Button
var mob_scroll_controls: ScrollContainer
var mob_scroll_telem: ScrollContainer
var mob_scroll_joint: ScrollContainer
var mob_scroll_graph: ScrollContainer
var current_mobile_tab: int = 0

var mobile_pin_card: PanelContainer
var lbl_mob_pin_summary: Label
var btn_mob_pin_inspect: Button
var btn_mob_pin_close: Button

# UI Theme Collections for Dynamic Switching
var theme_panels: Array[PanelContainer] = []
var theme_buttons: Array[Button] = []
var theme_labels_primary: Array[Label] = []
var theme_labels_secondary: Array[Label] = []
var theme_sliders: Array[HSlider] = []
var theme_checkboxes: Array[CheckBox] = []
var theme_progress_bars: Array[Dictionary] = []

# Sliders & Controls
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

# 3D Joint Force Vector Visualizer
var force_visualizer_root: Node3D
var pin_highlight_ring: MeshInstance3D
var mat_ring: StandardMaterial3D

var arrow_fy_data: Dictionary = {}
var arrow_fx_data: Dictionary = {}
var arrow_res_data: Dictionary = {}
var arrow_fric_data: Dictionary = {}

var inspected_rig: PantographRig = null
var inspected_pin_idx: int = -1

# 2D Joint Telemetry Glass Card
var joint_card: PanelContainer
var joint_card_title: Label
var joint_card_desc: Label
var joint_val_fy: Label
var joint_val_fx: Label
var joint_val_res: Label
var joint_val_fric: Label
var joint_val_tau: Label
var joint_val_theta: Label


func _ready() -> void:
	_setup_pure_light_studio()
	_setup_showroom_bay()
	_setup_rigs()
	_build_force_visualizer()
	_build_liquid_glass_ui()
	_apply_preset(0.5, 1000.0, 1.0, 9.81)
	_apply_theme(false)
	get_viewport().size_changed.connect(_check_responsive_layout)
	call_deferred("_check_responsive_layout")


func _process(delta: float) -> void:
	ui_timer += delta
	if ui_timer >= 0.033:
		ui_timer = 0.0
		_update_ui_telemetry()
	if inspected_rig != null and is_instance_valid(inspected_rig):
		_update_force_visualizer()


func _setup_pure_light_studio() -> void:
	world_env = get_node_or_null("WorldEnvironment") as WorldEnvironment
	if world_env == null:
		world_env = WorldEnvironment.new()
		world_env.name = "WorldEnvironment"
		add_child(world_env)

	env_res = Environment.new()

	# 1. Apple Keynote Showroom Sky Gradient
	env_res.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	sky_proc_mat = ProceduralSkyMaterial.new()
	sky_proc_mat.sky_top_color = Color(0.965, 0.968, 0.976)
	sky_proc_mat.sky_horizon_color = Color(0.885, 0.895, 0.92)
	sky_proc_mat.ground_bottom_color = Color(0.84, 0.85, 0.88)
	sky_proc_mat.ground_horizon_color = Color(0.885, 0.895, 0.92)
	sky_proc_mat.sun_angle_max = 25.0
	sky.sky_material = sky_proc_mat
	env_res.sky = sky

	# 2. Balanced Studio Ambient Light
	env_res.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env_res.ambient_light_color = Color(0.88, 0.89, 0.92)
	env_res.ambient_light_energy = 0.65

	# 3. Tonemapping & SSAO Photorealism
	env_res.tonemap_mode = Environment.TONE_MAPPER_ACES
	env_res.tonemap_exposure = 1.04
	env_res.ssao_enabled = true
	env_res.ssao_radius = 1.6
	env_res.ssao_intensity = 1.3
	env_res.ssao_power = 1.4
	env_res.ssr_enabled = true
	env_res.ssr_max_steps = 32
	env_res.glow_enabled = false
	env_res.glow_bloom = 0.18
	env_res.glow_intensity = 0.60
	env_res.glow_blend_mode = Environment.GLOW_BLEND_MODE_SOFTLIGHT

	world_env.environment = env_res

	# 4. Warm-Neutral Key Directional Light
	dir_light = get_node_or_null("DirectionalLight3D") as DirectionalLight3D
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
	fill_light = DirectionalLight3D.new()
	fill_light.light_color = Color(0.92, 0.94, 0.98)
	fill_light.light_energy = 0.45
	fill_light.rotation = Vector3(deg_to_rad(-12.0), deg_to_rad(-35.0), 0.0)
	fill_light.shadow_enabled = false
	add_child(fill_light)

	# 6. Rim Backlight
	rim_light = DirectionalLight3D.new()
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
	mat_floor = StandardMaterial3D.new()
	mat_floor.albedo_color = Color(0.905, 0.91, 0.925)
	mat_floor.metallic = 0.02
	mat_floor.roughness = 0.45
	floor_inst.material_override = mat_floor
	bay.add_child(floor_inst)

	# 2. Architectural Gantry Frame
	mat_gantry = StandardMaterial3D.new()
	mat_gantry.albedo_color = Color(0.24, 0.25, 0.28)
	mat_gantry.metallic = 0.85
	mat_gantry.roughness = 0.28

	mat_gantry_accent = StandardMaterial3D.new()
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
		camera.default_distance = 6.85
		camera.fov = 54.0
		camera.target_pitch = deg_to_rad(-5.0)
		camera.pitch = deg_to_rad(-5.0)
		add_child(camera)
	else:
		camera.target_point = Vector3(0.0, 1.80, 0.0)
		camera.default_distance = 6.85
		camera.fov = 54.0
		camera.target_pitch = deg_to_rad(-5.0)
		camera.pitch = deg_to_rad(-5.0)

	# Connect telemetry signals
	rig_a.telemetry_updated.connect(_on_rig_a_telemetry)
	rig_c.telemetry_updated.connect(_on_rig_c_telemetry)
	rig_b.telemetry_updated.connect(_on_rig_b_telemetry)

	# Connect interactive pin click signals
	rig_a.pin_clicked.connect(_on_pin_clicked)
	rig_c.pin_clicked.connect(_on_pin_clicked)
	rig_b.pin_clicked.connect(_on_pin_clicked)
	camera.screen_tapped.connect(_on_screen_tapped)


func _build_liquid_glass_ui() -> void:
	ui_layer = CanvasLayer.new()
	ui_layer.name = "UILayer"
	add_child(ui_layer)

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(root)

	# 1. FLOATING HEADER PILL (Centered with balanced padding and space distribution)
	header_panel = _create_liquid_glass_panel(Vector2(0, 16), Vector2(1180, 68), 24)
	header_panel.anchor_left = 0.5
	header_panel.anchor_right = 0.5
	header_panel.offset_left = -590.0
	header_panel.offset_right = 590.0
	header_panel.offset_top = 16.0
	header_panel.offset_bottom = 84.0
	root.add_child(header_panel)

	var header_margin := MarginContainer.new()
	header_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	header_margin.add_theme_constant_override("margin_left", 28)
	header_margin.add_theme_constant_override("margin_right", 20)
	header_margin.add_theme_constant_override("margin_top", 10)
	header_margin.add_theme_constant_override("margin_bottom", 10)
	header_panel.add_child(header_margin)

	var header_box := HBoxContainer.new()
	header_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	header_box.add_theme_constant_override("separation", 12)
	header_box.alignment = BoxContainer.ALIGNMENT_CENTER
	header_margin.add_child(header_box)

	var title_vbox := VBoxContainer.new()
	title_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	title_vbox.add_theme_constant_override("separation", 3)

	main_title = _create_title_label("Scissor Pantograph Verification  ·  Golden Rule of Mechanics", 14)
	title_vbox.add_child(main_title)

	sub_title = _create_subtitle_label("Sim-to-Real Multi-Linkage Physics Workbench  ·  Karen Ghardashyan", 11)
	title_vbox.add_child(sub_title)

	header_box.add_child(title_vbox)

	# Header Action Pills
	btn_formulas = _create_liquid_button("Formulas & Theory")
	btn_formulas.custom_minimum_size = Vector2(138, 32)
	var blue_accent := Color(0.0, 0.443, 0.89)
	btn_formulas.add_theme_color_override("font_color", blue_accent)
	btn_formulas.add_theme_color_override("font_pressed_color", blue_accent)
	btn_formulas.add_theme_color_override("font_hover_color", blue_accent)
	btn_formulas.pressed.connect(func():
		if OS.has_feature("web"):
			JavaScriptBridge.eval("window.openFormulasModal && window.openFormulasModal();")
		elif formulas_modal != null:
			formulas_modal.visible = not formulas_modal.visible
	)
	header_box.add_child(btn_formulas)

	btn_reset_cam = _create_liquid_button("Reset View")
	btn_reset_cam.custom_minimum_size = Vector2(92, 30)
	btn_reset_cam.pressed.connect(func(): camera.reset_camera())
	header_box.add_child(btn_reset_cam)

	btn_slowmo = _create_liquid_button("Slow Motion")
	btn_slowmo.custom_minimum_size = Vector2(92, 30)
	btn_slowmo.toggle_mode = true
	btn_slowmo.toggled.connect(func(toggled_on: bool):
		is_slow_motion = toggled_on
		Engine.time_scale = 0.3 if is_slow_motion else 1.0
		btn_slowmo.text = "Normal Speed" if is_slow_motion else "Slow Motion"
	)
	header_box.add_child(btn_slowmo)

	btn_lasers = _create_liquid_button("Hide Lasers")
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

	btn_theme_toggle = _create_liquid_button("🌙 Dark Theme")
	btn_theme_toggle.custom_minimum_size = Vector2(112, 30)
	btn_theme_toggle.pressed.connect(func():
		_apply_theme(not is_dark_theme)
	)
	header_box.add_child(btn_theme_toggle)

	btn_focus_toggle = _create_liquid_button("👁️ Focus Mode")
	btn_focus_toggle.custom_minimum_size = Vector2(98, 30)
	btn_focus_toggle.pressed.connect(func():
		_set_focus_mode(not is_focus_mode)
	)
	header_box.add_child(btn_focus_toggle)

	# Floating button to restore UI when in Focus Mode
	btn_restore_ui = _create_liquid_button("⛶ Show UI")
	btn_restore_ui.position = Vector2(24, 20)
	btn_restore_ui.custom_minimum_size = Vector2(108, 34)
	btn_restore_ui.visible = false
	btn_restore_ui.pressed.connect(func():
		_set_focus_mode(false)
	)
	root.add_child(btn_restore_ui)

	# 2. LEFT MINIMALIST CONTROL CARD
	left_panel = _create_liquid_glass_panel(Vector2(24, 96), Vector2(336, 750), 22)
	root.add_child(left_panel)

	left_margin = MarginContainer.new()
	left_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	left_margin.add_theme_constant_override("margin_top", 20)
	left_margin.add_theme_constant_override("margin_bottom", 20)
	left_margin.add_theme_constant_override("margin_left", 18)
	left_margin.add_theme_constant_override("margin_right", 18)
	left_panel.add_child(left_margin)

	left_vbox = VBoxContainer.new()
	left_vbox.add_theme_constant_override("separation", 10)
	left_margin.add_child(left_vbox)

	var panel_title := _create_title_label("Simulation Parameters", 15)
	left_vbox.add_child(panel_title)

	var sep1 := HSeparator.new()
	left_vbox.add_child(sep1)

	# 1. Suspended Mass Slider
	var mass_hbox := HBoxContainer.new()
	var mass_title := _create_label_cell("Suspended Mass (m)")
	mass_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
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
	var k_title := _create_label_cell("Spring Stiffness (k)")
	k_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
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
	var eta_title := _create_label_cell("Efficiency (η)")
	eta_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
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
	var g_title := _create_label_cell("Gravity Acceleration (g)")
	g_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
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
	theme_checkboxes.append(self_weight_check)
	left_vbox.add_child(self_weight_check)

	var sep2 := HSeparator.new()
	left_vbox.add_child(sep2)

	# 6. DYNAMIC OSCILLATIONS CONTROLS
	var osc_title := _create_title_label("Harmonic Oscillations", 13)
	left_vbox.add_child(osc_title)

	oscillations_check = CheckBox.new()
	oscillations_check.text = "Enable Spring Oscillation / Ringing"
	oscillations_check.button_pressed = true
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
	theme_checkboxes.append(oscillations_check)
	left_vbox.add_child(oscillations_check)

	var damp_hbox := HBoxContainer.new()
	var damp_title := _create_label_cell("Damping Ratio (ζ)")
	damp_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	damp_hbox.add_child(damp_title)

	damping_val_label = Label.new()
	damping_val_label.text = "0.25"
	damping_val_label.add_theme_font_size_override("font_size", 12)
	damping_val_label.add_theme_color_override("font_color", Color(0.0, 0.443, 0.89))
	damp_hbox.add_child(damping_val_label)
	left_vbox.add_child(damp_hbox)

	damping_slider = HSlider.new()
	damping_slider.min_value = 0.00
	damping_slider.max_value = 0.60
	damping_slider.step = 0.02
	damping_slider.value = 0.25
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
	blue_accent = Color(0.0, 0.443, 0.89)
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

	# 3. RIGHT COMPARISON CARD & JOINT INSPECTOR (Tabbed Liquid Glass Card)
	right_panel = _create_liquid_glass_panel(Vector2(0, 96), Vector2(350, 750), 22)
	right_panel.anchor_left = 1.0
	right_panel.anchor_right = 1.0
	right_panel.offset_left = -374.0
	right_panel.offset_right = -24.0
	right_panel.offset_top = 96.0
	right_panel.offset_bottom = 846.0
	root.add_child(right_panel)

	right_margin = MarginContainer.new()
	right_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	right_margin.add_theme_constant_override("margin_top", 18)
	right_margin.add_theme_constant_override("margin_bottom", 18)
	right_margin.add_theme_constant_override("margin_left", 16)
	right_margin.add_theme_constant_override("margin_right", 16)
	right_panel.add_child(right_margin)

	right_vbox = VBoxContainer.new()
	right_vbox.add_theme_constant_override("separation", 10)
	right_margin.add_child(right_vbox)

	# Tab Switcher Header (All Rigs Telemetry vs Joint Force Inspector)
	var tab_bar := HBoxContainer.new()
	tab_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tab_bar.add_theme_constant_override("separation", 8)
	right_vbox.add_child(tab_bar)

	btn_tab_telemetry = _create_liquid_button("📊 All Rigs")
	btn_tab_telemetry.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_tab_telemetry.custom_minimum_size = Vector2(0, 30)
	btn_tab_telemetry.pressed.connect(func(): _show_right_tab(0))
	tab_bar.add_child(btn_tab_telemetry)

	btn_tab_joint = _create_liquid_button("🔬 Joint Inspector")
	btn_tab_joint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_tab_joint.custom_minimum_size = Vector2(0, 30)
	btn_tab_joint.pressed.connect(func(): _show_right_tab(1))
	tab_bar.add_child(btn_tab_joint)

	var sep_tab := HSeparator.new()
	right_vbox.add_child(sep_tab)

	# --- TAB 1: TELEMETRY VIEW ---
	telemetry_view = VBoxContainer.new()
	telemetry_view.add_theme_constant_override("separation", 10)
	telemetry_view.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_vbox.add_child(telemetry_view)

	var telemetry_title := _create_title_label("Hardware Telemetry", 14)
	telemetry_view.add_child(telemetry_title)

	var sep4 := HSeparator.new()
	telemetry_view.add_child(sep4)

	# Hardware Metrics Table: 4 columns
	var table := GridContainer.new()
	table.columns = 4
	table.add_theme_constant_override("h_separation", 8)
	table.add_theme_constant_override("v_separation", 6)
	table.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	telemetry_view.add_child(table)

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
	telemetry_view.add_child(sep5)

	# Extension Gauges (3 Rigs)
	var bar_title := _create_header_cell("Extension Comparison")
	telemetry_view.add_child(bar_title)

	# Bar A
	var bar_a_lbl := Label.new()
	bar_a_lbl.text = "Rig A [Blue] (n=3) Span:"
	bar_a_lbl.add_theme_font_size_override("font_size", 11)
	bar_a_lbl.add_theme_color_override("font_color", Color(0.0, 0.443, 0.89))
	telemetry_view.add_child(bar_a_lbl)

	ratio_bar_a = ProgressBar.new()
	ratio_bar_a.min_value = 0.0
	ratio_bar_a.max_value = 65.0
	ratio_bar_a.show_percentage = true
	_style_progress_bar(ratio_bar_a, Color(0.0, 0.443, 0.89))
	telemetry_view.add_child(ratio_bar_a)

	# Bar C
	var bar_c_lbl := Label.new()
	bar_c_lbl.text = "Rig C [Green] (1:2:3) Span:"
	bar_c_lbl.add_theme_font_size_override("font_size", 11)
	bar_c_lbl.add_theme_color_override("font_color", Color(0.19, 0.82, 0.35))
	telemetry_view.add_child(bar_c_lbl)

	ratio_bar_c = ProgressBar.new()
	ratio_bar_c.min_value = 0.0
	ratio_bar_c.max_value = 65.0
	ratio_bar_c.show_percentage = true
	_style_progress_bar(ratio_bar_c, Color(0.19, 0.82, 0.35))
	telemetry_view.add_child(ratio_bar_c)

	# Bar B
	var bar_b_lbl := Label.new()
	bar_b_lbl.text = "Rig B [Orange] (n=5) Span:"
	bar_b_lbl.add_theme_font_size_override("font_size", 11)
	bar_b_lbl.add_theme_color_override("font_color", Color(1.0, 0.42, 0.05))
	telemetry_view.add_child(bar_b_lbl)

	ratio_bar_b = ProgressBar.new()
	ratio_bar_b.min_value = 0.0
	ratio_bar_b.max_value = 65.0
	ratio_bar_b.show_percentage = true
	_style_progress_bar(ratio_bar_b, Color(1.0, 0.42, 0.05))
	telemetry_view.add_child(ratio_bar_b)

	# --- TAB 2: JOINT INSPECTOR VIEW ---
	joint_view = VBoxContainer.new()
	joint_view.add_theme_constant_override("separation", 8)
	joint_view.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	joint_view.visible = false
	right_vbox.add_child(joint_view)

	var joint_header_row := HBoxContainer.new()
	joint_header_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	joint_view.add_child(joint_header_row)

	joint_card_title = Label.new()
	joint_card_title.text = "Select Any Pivot Pin in 3D"
	joint_card_title.add_theme_font_size_override("font_size", 13)
	joint_card_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	theme_labels_primary.append(joint_card_title)
	joint_header_row.add_child(joint_card_title)

	var btn_deselect := _create_liquid_button("✕ Deselect")
	btn_deselect.custom_minimum_size = Vector2(76, 26)
	btn_deselect.pressed.connect(func(): _deselect_pin())
	joint_header_row.add_child(btn_deselect)

	joint_card_desc = Label.new()
	joint_card_desc.text = "Click any pivot pin on Rig A, C, or B to analyze 3D force vectors."
	joint_card_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	joint_card_desc.add_theme_font_size_override("font_size", 10)
	theme_labels_secondary.append(joint_card_desc)
	joint_view.add_child(joint_card_desc)

	var sep_j1 := HSeparator.new()
	joint_view.add_child(sep_j1)

	var jgrid := GridContainer.new()
	jgrid.columns = 2
	jgrid.add_theme_constant_override("h_separation", 10)
	jgrid.add_theme_constant_override("v_separation", 6)
	joint_view.add_child(jgrid)

	jgrid.add_child(_create_body_label("Fy (Load / Tension):"))
	joint_val_fy = _create_value_cell("0.0 N", Color(0.0, 0.443, 0.89))
	jgrid.add_child(joint_val_fy)

	jgrid.add_child(_create_body_label("Fx (Lateral Thrust):"))
	joint_val_fx = _create_value_cell("0.0 N", Color(0.95, 0.22, 0.22))
	jgrid.add_child(joint_val_fx)

	jgrid.add_child(_create_body_label("Reaction Resultant R:"))
	joint_val_res = _create_value_cell("0.0 N", Color(0.12, 0.75, 0.35))
	jgrid.add_child(joint_val_res)

	jgrid.add_child(_create_body_label("Coulomb Friction fk:"))
	joint_val_fric = _create_value_cell("0.0 N", Color(0.95, 0.65, 0.05))
	jgrid.add_child(joint_val_fric)

	jgrid.add_child(_create_body_label("Friction Torque τ:"))
	joint_val_tau = _create_value_cell("0.000 N·m", Color(1.0, 0.75, 0.20))
	jgrid.add_child(joint_val_tau)

	jgrid.add_child(_create_body_label("Scissor Half-Angle θ:"))
	joint_val_theta = _create_value_cell("0.0°")
	jgrid.add_child(joint_val_theta)

	var sep_j2 := HSeparator.new()
	joint_view.add_child(sep_j2)

	var joint_note := Label.new()
	joint_note.text = "Physics Insights:\n• Lateral thrust Fx = P / (2 tan θ) increases sharply at flat scissor angles.\n• Coulomb pin friction fk = μ · R resists extension/contraction.\n• Vector arrows in 3D are rendered with true depth priority and separated directions."
	joint_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	joint_note.add_theme_font_size_override("font_size", 10)
	theme_labels_secondary.append(joint_note)
	joint_view.add_child(joint_note)

	var sep_j3 := HSeparator.new()
	joint_view.add_child(sep_j3)

	var quick_pins_title := Label.new()
	quick_pins_title.text = "Direct Pin Selector (Tap to Inspect):"
	quick_pins_title.add_theme_font_size_override("font_size", 10)
	theme_labels_secondary.append(quick_pins_title)
	joint_view.add_child(quick_pins_title)

	var quick_pins_grid := GridContainer.new()
	quick_pins_grid.columns = 3
	quick_pins_grid.add_theme_constant_override("h_separation", 6)
	quick_pins_grid.add_theme_constant_override("v_separation", 6)
	joint_view.add_child(quick_pins_grid)

	var quick_pin_defs := [
		{"name": "Rig A: Top", "get_rig": func(): return rig_a, "idx": 0},
		{"name": "Rig A: Mid", "get_rig": func(): return rig_a, "idx": 4},
		{"name": "Rig A: Mass", "get_rig": func(): return rig_a, "idx": 9},
		{"name": "Rig C: Top", "get_rig": func(): return rig_c, "idx": 0},
		{"name": "Rig C: Stg 2", "get_rig": func(): return rig_c, "idx": 6},
		{"name": "Rig C: Mass", "get_rig": func(): return rig_c, "idx": 9},
		{"name": "Rig B: Top", "get_rig": func(): return rig_b, "idx": 0},
		{"name": "Rig B: Mid", "get_rig": func(): return rig_b, "idx": 8},
		{"name": "Rig B: Mass", "get_rig": func(): return rig_b, "idx": 15},
	]

	for qp in quick_pin_defs:
		var btn_qp := _create_liquid_button(qp["name"])
		btn_qp.custom_minimum_size = Vector2(0, 26)
		btn_qp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_qp.add_theme_font_size_override("font_size", 9)
		var qp_copy: Dictionary = qp
		btn_qp.pressed.connect(func():
			var r: PantographRig = qp_copy["get_rig"].call()
			if r != null and is_instance_valid(r):
				var p_idx: int = qp_copy["idx"]
				_on_pin_clicked(r, p_idx, r.get_pin_global_position(p_idx))
		)
		quick_pins_grid.add_child(btn_qp)

	_show_right_tab(0)

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

	graph_margin = MarginContainer.new()
	graph_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	graph_margin.add_theme_constant_override("margin_top", 10)
	graph_margin.add_theme_constant_override("margin_bottom", 12)
	graph_margin.add_theme_constant_override("margin_left", 16)
	graph_margin.add_theme_constant_override("margin_right", 16)
	bottom_panel.add_child(graph_margin)

	graph_vbox = VBoxContainer.new()
	graph_vbox.add_theme_constant_override("separation", 6)
	graph_margin.add_child(graph_vbox)

	# Graph Card Control Bar
	var graph_bar := HBoxContainer.new()
	graph_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var graph_card_title := _create_header_cell("Theoretical Sim-to-Real Curves: L(m)")
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

	# 5. MOBILE TOP BAR & SLIDE-OUT SIDEBAR
	_build_mobile_ui(root)

	# 6. FLOATING FORMULAS & THEORY MODAL WINDOW
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
	t += "[font_size=15][b][color=#1D1D1F]1. Principle of Virtual Work & Mechanical Efficiency[/color][/b][/font_size]\n"
	t += "[color=#3A3A3C]In static equilibrium, input mechanical work supplied by spring tension T equals output work done lifting the load P_eff minus parasitic hinge friction losses:[/color]\n\n"
	t += "   [color=#0056B3][b]δA_in = T · δH[/b][/color]       [color=#0056B3][b]δA_out = P_eff · δL[/b][/color]\n"
	t += "   [color=#0056B3][b]δA_out = η · δA_in   ⟹   T = (λ · P_eff) / η[/b][/color]\n\n"
	t += "[color=#595C66]• Total Hinge Dissipation:   ΔE_loss = Σ (M_fric,i · Δθ_i) = (1 - η) · δA_in[/color]\n\n"

	t += "[font_size=15][b][color=#1D1D1F]2. Kinematic Transmission Ratios (λ ≡ δL / δH)[/color][/b][/font_size]\n"
	t += "[color=#0071E3]• Rig A (n = 3 uniform):[/color]     L(m) = 3 · H(m)     ⟹   [color=#0071E3][b]λ_A = 3.000×[/b][/color]\n"
	t += "[color=#1E9C3C]• Rig C (1:2:3 variable):[/color]    L(m) = 6 · H_0(m)   ⟹   [color=#1E9C3C][b]λ_C = 6.000×[/b][/color]\n"
	t += "[color=#FF6B0D]• Rig B (n = 5 uniform):[/color]     L(m) = 5 · H(m)     ⟹   [color=#FF6B0D][b]λ_B = 5.000×[/b][/color]\n\n"

	t += "[font_size=15][b][color=#1D1D1F]3. Equilibrium of Forces with Self-Weight & Gravity (g)[/color][/b][/font_size]\n"
	t += "   [b]P_eff = (m + m_struct) · g[/b]\n"
	t += "[color=#595C66]• Uniform rigs: m_struct = (n / 2) · m_link    |   Rig C (1:2:3): m_struct = 3.0 · m_link[/color]\n\n"

	t += "[font_size=15][b][color=#1D1D1F]4. Hooke's Law & Deflection (ΔH)[/color][/b][/font_size]\n"
	t += "   [color=#0056B3][b]ΔH(m) = (λ · P_eff) / (η · k)[/b][/color]\n"
	t += "   [color=#0056B3][b]ΔL(m) = (λ² · P_eff) / (η · k)[/b][/color]\n\n"

	t += "[font_size=15][b][color=#1D1D1F]5. Linear Regression Slope (Stiffness Extraction)[/color][/b][/font_size]\n"
	t += "   [color=#0056B3][b]tan(α) = (λ · g) / k   ⟹   k = (λ · g) / tan(α)[/b][/color]\n"
	t += "[color=#595C66]Empirical laboratory validation: k ≈ 981 N/m (Rig A)  |  k ≈ 1090 N/m (Rig B)[/color]\n\n"

	t += "[font_size=15][b][color=#1D1D1F]6. Dynamic 2nd-Order Damped Vibration Equation[/color][/b][/font_size]\n"
	t += "   [color=#0056B3][b]d²H/dt² + 2ζω · (dH/dt) + ω² · (H - H_target) = 0[/b][/color]\n"
	t += "   [color=#0056B3][b]ω = √(k_eff / m_eff)[/b][/color]\n"
	t += "[color=#595C66]Tip: In the web browser, click Formulas & Theory to view the full interactive LaTeX / KaTeX textbook equations![/color]\n"

	content_rtl.text = t


func _build_mobile_ui(root: Control) -> void:
	# 1. Fullscreen Backdrop Scrim (Dims 3D scene when Sidebar is open)
	backdrop_scrim = ColorRect.new()
	backdrop_scrim.name = "MobileBackdropScrim"
	backdrop_scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop_scrim.color = Color(0.0, 0.0, 0.0, 0.45)
	backdrop_scrim.visible = false
	backdrop_scrim.gui_input.connect(func(ev: InputEvent):
		if (ev is InputEventMouseButton and ev.pressed) or (ev is InputEventScreenTouch and ev.pressed):
			_toggle_mobile_sidebar(false)
	)
	root.add_child(backdrop_scrim)

	# 2. Sleek Floating Mobile Top Bar (VisionOS Capsule)
	mobile_top_bar = _create_liquid_glass_panel(Vector2.ZERO, Vector2(360, 48), 24, 0.88)
	mobile_top_bar.name = "MobileTopBar"
	mobile_top_bar.anchor_left = 0.0
	mobile_top_bar.anchor_right = 1.0
	mobile_top_bar.offset_left = 8.0
	mobile_top_bar.offset_right = -8.0
	mobile_top_bar.offset_top = 8.0
	mobile_top_bar.offset_bottom = 56.0
	mobile_top_bar.visible = false
	root.add_child(mobile_top_bar)

	var top_margin := MarginContainer.new()
	top_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	top_margin.add_theme_constant_override("margin_left", 8)
	top_margin.add_theme_constant_override("margin_right", 8)
	top_margin.add_theme_constant_override("margin_top", 4)
	top_margin.add_theme_constant_override("margin_bottom", 4)
	mobile_top_bar.add_child(top_margin)

	var top_hbox := HBoxContainer.new()
	top_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	top_hbox.add_theme_constant_override("separation", 6)
	top_margin.add_child(top_hbox)

	btn_mobile_menu = _create_liquid_button("☰ Menu")
	btn_mobile_menu.custom_minimum_size = Vector2(74, 34)
	btn_mobile_menu.add_theme_font_size_override("font_size", 12)
	btn_mobile_menu.pressed.connect(func():
		_toggle_mobile_sidebar(not mobile_sidebar.visible)
	)
	top_hbox.add_child(btn_mobile_menu)

	# Camera Quick Rig Focus Pills
	btn_focus_all = _create_liquid_button("All")
	btn_focus_all.custom_minimum_size = Vector2(36, 32)
	btn_focus_all.add_theme_font_size_override("font_size", 11)
	btn_focus_all.pressed.connect(func(): camera.focus_rig("ALL"))
	top_hbox.add_child(btn_focus_all)

	btn_focus_a = _create_liquid_button("A")
	btn_focus_a.custom_minimum_size = Vector2(32, 32)
	btn_focus_a.add_theme_font_size_override("font_size", 11)
	btn_focus_a.add_theme_color_override("font_color", Color(0.0, 0.443, 0.89))
	btn_focus_a.pressed.connect(func(): camera.focus_rig("A"))
	top_hbox.add_child(btn_focus_a)

	btn_focus_c = _create_liquid_button("C")
	btn_focus_c.custom_minimum_size = Vector2(32, 32)
	btn_focus_c.add_theme_font_size_override("font_size", 11)
	btn_focus_c.add_theme_color_override("font_color", Color(0.19, 0.82, 0.35))
	btn_focus_c.pressed.connect(func(): camera.focus_rig("C"))
	top_hbox.add_child(btn_focus_c)

	btn_focus_b = _create_liquid_button("B")
	btn_focus_b.custom_minimum_size = Vector2(32, 32)
	btn_focus_b.add_theme_font_size_override("font_size", 11)
	btn_focus_b.add_theme_color_override("font_color", Color(1.0, 0.42, 0.05))
	btn_focus_b.pressed.connect(func(): camera.focus_rig("B"))
	top_hbox.add_child(btn_focus_b)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_hbox.add_child(spacer)

	btn_mob_theme = _create_liquid_button("🌙" if not is_dark_theme else "☀️")
	btn_mob_theme.custom_minimum_size = Vector2(34, 32)
	btn_mob_theme.pressed.connect(func():
		_apply_theme(not is_dark_theme)
		btn_mob_theme.text = "☀️" if is_dark_theme else "🌙"
	)
	top_hbox.add_child(btn_mob_theme)

	btn_mob_reset = _create_liquid_button("↺")
	btn_mob_reset.custom_minimum_size = Vector2(34, 32)
	btn_mob_reset.pressed.connect(func(): camera.reset_camera())
	top_hbox.add_child(btn_mob_reset)

	# 3. Mobile Slide-Out Sidebar Drawer
	mobile_sidebar = _create_liquid_glass_panel(Vector2.ZERO, Vector2(350, 700), 22, 0.94)
	mobile_sidebar.name = "MobileSidebar"
	mobile_sidebar.anchor_left = 0.0
	mobile_sidebar.anchor_right = 0.0
	mobile_sidebar.anchor_top = 0.0
	mobile_sidebar.anchor_bottom = 1.0
	mobile_sidebar.offset_left = 0.0
	mobile_sidebar.offset_right = 350.0
	mobile_sidebar.offset_top = 0.0
	mobile_sidebar.offset_bottom = 0.0
	mobile_sidebar.visible = false
	root.add_child(mobile_sidebar)

	var sb_margin := MarginContainer.new()
	sb_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	sb_margin.add_theme_constant_override("margin_top", 14)
	sb_margin.add_theme_constant_override("margin_bottom", 14)
	sb_margin.add_theme_constant_override("margin_left", 14)
	sb_margin.add_theme_constant_override("margin_right", 14)
	mobile_sidebar.add_child(sb_margin)

	var sb_vbox := VBoxContainer.new()
	sb_vbox.add_theme_constant_override("separation", 10)
	sb_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sb_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sb_margin.add_child(sb_vbox)

	# Sidebar Header
	var sb_header := HBoxContainer.new()
	sb_header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sb_vbox.add_child(sb_header)

	var sb_titles := VBoxContainer.new()
	sb_titles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sb_main_lbl := _create_title_label("Scissor Pantograph Lab", 15)
	sb_titles.add_child(sb_main_lbl)
	var sb_sub_lbl := _create_subtitle_label("Sim-to-Real Multi-Linkage Physics", 10)
	sb_titles.add_child(sb_sub_lbl)
	sb_header.add_child(sb_titles)

	btn_close_sidebar = _create_liquid_button("✕")
	btn_close_sidebar.custom_minimum_size = Vector2(36, 32)
	btn_close_sidebar.pressed.connect(func(): _toggle_mobile_sidebar(false))
	sb_header.add_child(btn_close_sidebar)

	var sep_sb := HSeparator.new()
	sb_vbox.add_child(sep_sb)

	# Segmented Navigation Tabs
	var sb_tabs := HBoxContainer.new()
	sb_tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sb_tabs.add_theme_constant_override("separation", 6)
	sb_vbox.add_child(sb_tabs)

	btn_mob_tab_0 = _create_liquid_button("⚙️ Controls")
	btn_mob_tab_0.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_mob_tab_0.custom_minimum_size.y = 32
	btn_mob_tab_0.pressed.connect(func(): _show_mobile_tab(0))
	sb_tabs.add_child(btn_mob_tab_0)

	btn_mob_tab_1 = _create_liquid_button("📊 Data")
	btn_mob_tab_1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_mob_tab_1.custom_minimum_size.y = 32
	btn_mob_tab_1.pressed.connect(func(): _show_mobile_tab(1))
	sb_tabs.add_child(btn_mob_tab_1)

	btn_mob_tab_2 = _create_liquid_button("🔬 Joint")
	btn_mob_tab_2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_mob_tab_2.custom_minimum_size.y = 32
	btn_mob_tab_2.pressed.connect(func(): _show_mobile_tab(2))
	sb_tabs.add_child(btn_mob_tab_2)

	btn_mob_tab_3 = _create_liquid_button("📈 Curves")
	btn_mob_tab_3.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_mob_tab_3.custom_minimum_size.y = 32
	btn_mob_tab_3.pressed.connect(func(): _show_mobile_tab(3))
	sb_tabs.add_child(btn_mob_tab_3)

	# Content Scroll Containers
	mob_scroll_controls = ScrollContainer.new()
	mob_scroll_controls.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mob_scroll_controls.size_flags_vertical = Control.SIZE_EXPAND_FILL
	mob_scroll_controls.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sb_vbox.add_child(mob_scroll_controls)

	mob_scroll_telem = ScrollContainer.new()
	mob_scroll_telem.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mob_scroll_telem.size_flags_vertical = Control.SIZE_EXPAND_FILL
	mob_scroll_telem.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	mob_scroll_telem.visible = false
	sb_vbox.add_child(mob_scroll_telem)

	mob_scroll_joint = ScrollContainer.new()
	mob_scroll_joint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mob_scroll_joint.size_flags_vertical = Control.SIZE_EXPAND_FILL
	mob_scroll_joint.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	mob_scroll_joint.visible = false
	sb_vbox.add_child(mob_scroll_joint)

	mob_scroll_graph = ScrollContainer.new()
	mob_scroll_graph.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mob_scroll_graph.size_flags_vertical = Control.SIZE_EXPAND_FILL
	mob_scroll_graph.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	mob_scroll_graph.visible = false
	sb_vbox.add_child(mob_scroll_graph)

	# 4. Floating Bottom Pin Chip (Appears only when a pin is selected in 3D)
	mobile_pin_card = _create_liquid_glass_panel(Vector2.ZERO, Vector2(340, 48), 24, 0.90)
	mobile_pin_card.name = "MobilePinCard"
	mobile_pin_card.anchor_left = 0.5
	mobile_pin_card.anchor_right = 0.5
	mobile_pin_card.anchor_top = 1.0
	mobile_pin_card.anchor_bottom = 1.0
	mobile_pin_card.offset_left = -170.0
	mobile_pin_card.offset_right = 170.0
	mobile_pin_card.offset_top = -62.0
	mobile_pin_card.offset_bottom = -14.0
	mobile_pin_card.visible = false
	root.add_child(mobile_pin_card)

	var pin_card_margin := MarginContainer.new()
	pin_card_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	pin_card_margin.add_theme_constant_override("margin_left", 12)
	pin_card_margin.add_theme_constant_override("margin_right", 8)
	pin_card_margin.add_theme_constant_override("margin_top", 4)
	pin_card_margin.add_theme_constant_override("margin_bottom", 4)
	mobile_pin_card.add_child(pin_card_margin)

	var pin_card_hbox := HBoxContainer.new()
	pin_card_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	pin_card_hbox.add_theme_constant_override("separation", 8)
	pin_card_margin.add_child(pin_card_hbox)

	lbl_mob_pin_summary = Label.new()
	lbl_mob_pin_summary.text = "Pin Selected"
	lbl_mob_pin_summary.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_mob_pin_summary.add_theme_font_size_override("font_size", 11)
	lbl_mob_pin_summary.add_theme_color_override("font_color", Color(0.0, 0.443, 0.89))
	pin_card_hbox.add_child(lbl_mob_pin_summary)

	btn_mob_pin_inspect = _create_liquid_button("Details ❯")
	btn_mob_pin_inspect.custom_minimum_size = Vector2(74, 28)
	btn_mob_pin_inspect.add_theme_font_size_override("font_size", 11)
	btn_mob_pin_inspect.pressed.connect(func():
		_toggle_mobile_sidebar(true)
		_show_mobile_tab(2)
	)
	pin_card_hbox.add_child(btn_mob_pin_inspect)

	btn_mob_pin_close = _create_liquid_button("✕")
	btn_mob_pin_close.custom_minimum_size = Vector2(28, 28)
	btn_mob_pin_close.pressed.connect(func(): _deselect_pin())
	pin_card_hbox.add_child(btn_mob_pin_close)



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

	var is_dark: bool = is_dark_theme
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.08, 0.12, 0.82) if is_dark else Color(1.0, 1.0, 1.0, bg_alpha)
	style.border_color = Color(0.35, 0.40, 0.55, 0.40) if is_dark else Color(1.0, 1.0, 1.0, 0.8)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.corner_detail = 12
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.35) if is_dark else Color(0.0, 0.0, 0.0, 0.06)
	style.shadow_size = 14
	style.shadow_offset = Vector2(0, 5)

	panel.add_theme_stylebox_override("panel", style)
	theme_panels.append(panel)
	return panel


func _create_liquid_button(text: String) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(105, 30)
	btn.add_theme_font_size_override("font_size", 11)

	var is_dark: bool = is_dark_theme
	var text_col: Color = Color(0.92, 0.94, 0.98) if is_dark else Color(0.114, 0.114, 0.122)
	btn.add_theme_color_override("font_color", text_col)
	btn.add_theme_color_override("font_pressed_color", text_col)
	btn.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0) if is_dark else text_col)
	btn.add_theme_color_override("font_focus_color", text_col)
	btn.add_theme_color_override("font_hover_pressed_color", text_col)

	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.12, 0.14, 0.20, 0.80) if is_dark else Color(1.0, 1.0, 1.0, 0.65)
	normal.border_color = Color(0.30, 0.35, 0.48, 0.50) if is_dark else Color(1.0, 1.0, 1.0, 0.9)
	normal.border_width_left = 1
	normal.border_width_top = 1
	normal.border_width_right = 1
	normal.border_width_bottom = 1
	normal.corner_radius_top_left = 14
	normal.corner_radius_top_right = 14
	normal.corner_radius_bottom_left = 14
	normal.corner_radius_bottom_right = 14
	normal.corner_detail = 10
	normal.shadow_color = Color(0.0, 0.0, 0.0, 0.20) if is_dark else Color(0.0, 0.0, 0.0, 0.04)
	normal.shadow_size = 6
	normal.shadow_offset = Vector2(0, 2)
	btn.add_theme_stylebox_override("normal", normal)

	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(0.18, 0.21, 0.30, 0.95) if is_dark else Color(1.0, 1.0, 1.0, 0.9)
	hover.border_color = Color(1.0, 0.55, 0.15, 0.80) if is_dark else Color(0.0, 0.443, 0.89, 0.4)
	hover.border_width_left = 1
	hover.border_width_top = 1
	hover.border_width_right = 1
	hover.border_width_bottom = 1
	hover.corner_radius_top_left = 14
	hover.corner_radius_top_right = 14
	hover.corner_radius_bottom_left = 14
	hover.corner_radius_bottom_right = 14
	hover.corner_detail = 10
	hover.shadow_color = Color(1.0, 0.55, 0.15, 0.25) if is_dark else Color(0.0, 0.0, 0.0, 0.08)
	hover.shadow_size = 8
	hover.shadow_offset = Vector2(0, 3)
	btn.add_theme_stylebox_override("hover", hover)

	var pressed := StyleBoxFlat.new()
	pressed.bg_color = Color(1.0, 0.55, 0.15, 0.20) if is_dark else Color(0.0, 0.443, 0.89, 0.15)
	pressed.border_color = Color(1.0, 0.55, 0.15, 1.0) if is_dark else Color(0.0, 0.443, 0.89, 0.80)
	pressed.border_width_left = 1
	pressed.border_width_top = 1
	pressed.border_width_right = 1
	pressed.border_width_bottom = 1
	pressed.corner_radius_top_left = 14
	pressed.corner_radius_top_right = 14
	pressed.corner_radius_bottom_left = 14
	pressed.corner_radius_bottom_right = 14
	pressed.corner_detail = 10
	btn.add_theme_stylebox_override("pressed", pressed)

	var focus := StyleBoxFlat.new()
	focus.draw_center = false
	focus.border_color = Color(1.0, 0.55, 0.15, 0.70) if is_dark else Color(0.0, 0.443, 0.89, 0.50)
	focus.border_width_left = 1
	focus.border_width_top = 1
	focus.border_width_right = 1
	focus.border_width_bottom = 1
	focus.corner_radius_top_left = 14
	focus.corner_radius_top_right = 14
	focus.corner_radius_bottom_left = 14
	focus.corner_radius_bottom_right = 14
	btn.add_theme_stylebox_override("focus", focus)

	theme_buttons.append(btn)
	return btn


func _style_tech_slider(slider: HSlider) -> void:
	var track := StyleBoxFlat.new()
	track.bg_color = Color(0.18, 0.20, 0.28) if is_dark_theme else Color(0.84, 0.85, 0.88)
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
	theme_sliders.append(slider)


func _style_progress_bar(bar: ProgressBar, fill_color: Color) -> void:
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.15, 0.17, 0.24) if is_dark_theme else Color(0.86, 0.87, 0.90)
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

	theme_progress_bars.append({"bar": bar, "fill_color": fill_color})


func _create_header_cell(text: String) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 10)
	lbl.add_theme_color_override("font_color", Color(0.72, 0.75, 0.84) if is_dark_theme else Color(0.17, 0.17, 0.19))
	theme_labels_secondary.append(lbl)
	return lbl


func _create_label_cell(text: String) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 11)
	lbl.add_theme_color_override("font_color", Color(0.95, 0.96, 0.98) if is_dark_theme else Color(0.114, 0.114, 0.122))
	theme_labels_primary.append(lbl)
	return lbl


func _create_title_label(text: String, font_size: int = 15) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", font_size)
	lbl.add_theme_color_override("font_color", Color(0.95, 0.96, 0.98) if is_dark_theme else Color(0.114, 0.114, 0.122))
	theme_labels_primary.append(lbl)
	return lbl


func _create_subtitle_label(text: String, font_size: int = 11) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", font_size)
	lbl.add_theme_color_override("font_color", Color(0.65, 0.68, 0.76) if is_dark_theme else Color(0.40, 0.42, 0.48))
	theme_labels_secondary.append(lbl)
	return lbl


func _create_body_label(text: String, font_size: int = 11) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", font_size)
	lbl.add_theme_color_override("font_color", Color(0.85, 0.88, 0.94) if is_dark_theme else Color(0.114, 0.114, 0.122))
	theme_labels_primary.append(lbl)
	return lbl


func _create_value_cell(text: String, color: Color = Color(0.114, 0.114, 0.122)) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 11)
	lbl.add_theme_color_override("font_color", color)
	return lbl


# --- 3D Joint Force Vector Visualizer Engine ---
func _build_force_visualizer() -> void:
	force_visualizer_root = Node3D.new()
	force_visualizer_root.name = "ForceVisualizerRoot"
	force_visualizer_root.visible = false
	add_child(force_visualizer_root)

	# 1. Glowing Pin Highlight Ring
	pin_highlight_ring = MeshInstance3D.new()
	pin_highlight_ring.name = "PinHighlightRing"
	var ring_mesh := TorusMesh.new()
	ring_mesh.inner_radius = 0.075
	ring_mesh.outer_radius = 0.092
	ring_mesh.rings = 28
	ring_mesh.ring_segments = 14
	pin_highlight_ring.mesh = ring_mesh
	pin_highlight_ring.rotation.x = deg_to_rad(90)
	mat_ring = StandardMaterial3D.new()
	mat_ring.albedo_color = Color(1.0, 0.65, 0.15)
	mat_ring.emission_enabled = false
	mat_ring.roughness = 0.25
	mat_ring.metallic = 0.70
	pin_highlight_ring.material_override = mat_ring
	force_visualizer_root.add_child(pin_highlight_ring)

	# 2. Vector Arrows: Fy (Load), Fx (Thrust), R (Reaction Resultant), F_fric (Pin Friction)
	arrow_fy_data = _create_arrow_node("ArrowFy", Color(0.0, 0.44, 0.95))
	arrow_fx_data = _create_arrow_node("ArrowFx", Color(0.95, 0.22, 0.22))
	arrow_res_data = _create_arrow_node("ArrowResultant", Color(0.12, 0.75, 0.35))
	arrow_fric_data = _create_arrow_node("ArrowFriction", Color(0.95, 0.65, 0.05))


func _create_arrow_node(arrow_name: String, col: Color) -> Dictionary:
	var root := Node3D.new()
	root.name = arrow_name
	force_visualizer_root.add_child(root)

	var mat := StandardMaterial3D.new()
	mat.albedo_color = col
	mat.roughness = 0.25
	mat.metallic = 0.30
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.no_depth_test = true # Ensures always visible over 3D model!
	mat.render_priority = 10 # Renders on top of rig meshes!
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL

	var stem := MeshInstance3D.new()
	stem.name = "Stem"
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.016
	cyl.bottom_radius = 0.016
	cyl.height = 1.0
	cyl.radial_segments = 16
	stem.mesh = cyl
	stem.material_override = mat
	root.add_child(stem)

	var tip := MeshInstance3D.new()
	tip.name = "Tip"
	var cone := CylinderMesh.new()
	cone.top_radius = 0.0
	cone.bottom_radius = 0.038
	cone.height = 0.09
	cone.radial_segments = 16
	tip.mesh = cone
	tip.material_override = mat
	root.add_child(tip)

	var lbl := Label3D.new()
	lbl.name = "Label"
	lbl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	lbl.pixel_size = 0.0030
	lbl.font_size = 20
	lbl.shaded = false
	lbl.no_depth_test = true
	lbl.render_priority = 15
	lbl.modulate = col
	lbl.outline_size = 8
	lbl.outline_modulate = Color(1.0, 1.0, 1.0, 0.98)
	root.add_child(lbl)

	return {
		"root": root,
		"stem": stem,
		"tip": tip,
		"label": lbl,
		"mat": mat,
		"base_color": col
	}


func _update_arrow_vector(arrow_dict: Dictionary, origin: Vector3, dir_unit: Vector3, visual_length: float, label_text: String) -> void:
	var root: Node3D = arrow_dict["root"]
	if visual_length < 0.05 or dir_unit.length_squared() < 0.001:
		root.visible = false
		return
	root.visible = true

	var tip_len: float = 0.09
	var stem_len: float = maxf(visual_length - tip_len, 0.01)

	var dir: Vector3 = dir_unit.normalized()
	var up_ref := Vector3.UP if absf(dir.y) < 0.95 else Vector3.FORWARD
	var right := up_ref.cross(dir).normalized()
	var forward := dir.cross(right).normalized()
	var basis := Basis(right, dir, forward)

	root.global_transform = Transform3D(basis, origin)

	var stem: MeshInstance3D = arrow_dict["stem"]
	stem.position = Vector3(0, stem_len * 0.5, 0)
	stem.scale = Vector3(1.0, stem_len, 1.0)

	var tip: MeshInstance3D = arrow_dict["tip"]
	tip.position = Vector3(0, stem_len + tip_len * 0.5, 0)

	var lbl: Label3D = arrow_dict["label"]
	lbl.position = Vector3(0, stem_len + tip_len + 0.07, 0)
	lbl.text = label_text


func _calculate_joint_forces(rig: PantographRig, pin_idx: int) -> Dictionary:
	var m: float = rig.suspended_mass
	var g: float = rig.gravity
	var n: int = rig.n_stages
	var link_m: float = rig.link_mass_per_stage
	var theta: float = rig.current_theta # radians relative to horizontal
	# Epsilon clamping guard against division-by-zero singularities (theta >= 3° to 87°)
	var theta_clamped: float = clampf(theta, deg_to_rad(3.0), deg_to_rad(87.0))
	var tan_theta: float = tan(theta_clamped)
	var mu: float = 0.20 # Coulomb pin friction coefficient
	var r_pin: float = 0.026 # Pin contact radius in meters

	# Motion direction from Symplectic Euler integrator:
	# vel_H > 0: extending downward; vel_H < 0: contracting upward
	var vel_h: float = rig.velocity_H
	var motion_dir: float = signf(vel_h)
	if absf(vel_h) < 0.001:
		motion_dir = 1.0 # Static equilibrium incipient extension under gravity

	var F_y: float = 0.0
	var F_x: float = 0.0
	var R: float = 0.0
	var F_fric: float = 0.0
	var tau_fric: float = 0.0

	var dir_fy := Vector3.ZERO
	var dir_fx := Vector3.ZERO
	var dir_res := Vector3.ZERO
	var dir_fric := Vector3.ZERO

	var title := ""
	var desc := ""

	if pin_idx == 0:
		# Top Gantry Anchor
		var p_tot: float = m * g + float(n) * link_m * g
		F_y = p_tot
		dir_fy = Vector3(0, 1, 0) # Points up (balancing total suspended weight)

		F_x = rig.tensile_force_T / (2.0 * tan_theta)
		dir_fx = Vector3(1, 0, 0) # Top slider thrust

		var raw_res := Vector3(F_x, F_y, 0.0)
		R = raw_res.length()
		dir_res = raw_res.normalized()
		F_fric = mu * R
		tau_fric = mu * R * r_pin
		# Friction counter-force opposing slider extension/contraction
		dir_fric = Vector3(-motion_dir, 0, 0)

		title = "%s · Top Gantry Pivot [Pin #0]" % rig.rig_name
		desc = "Ceiling support reaction balancing total suspended mass + mechanism weight."
	else:
		var s: int = (pin_idx - 1) / 3
		var type: int = (pin_idx - 1) % 3
		var stages_below: float = float(n - 1 - s)
		var p_below: float = m * g + stages_below * link_m * g
		var p_stage: float = p_below + link_m * g * 0.5

		if type == 0:
			# Left Lateral Hinge
			F_y = -p_stage * 0.5
			dir_fy = Vector3(0, -1, 0) # Downward load on left branch

			F_x = p_stage / (2.0 * tan_theta)
			dir_fx = Vector3(-1, 0, 0) # Outward thrust pointing left

			var raw_res := Vector3(-F_x, F_y, 0.0)
			R = raw_res.length()
			dir_res = raw_res.normalized()
			F_fric = mu * R
			tau_fric = mu * R * r_pin
			# When extending (motion_dir > 0), left hinge moves inward (+X). Friction opposes outward (-X).
			dir_fric = Vector3(-motion_dir, 0, 0)

			title = "%s · Stage %d Left Lateral Joint [Pin #%d]" % [rig.rig_name, s + 1, pin_idx]
			desc = "Lateral scissor hinge experiencing outward thrust Fx and vertical load transmission Fy."

		elif type == 1:
			# Right Lateral Hinge
			F_y = -p_stage * 0.5
			dir_fy = Vector3(0, -1, 0) # Downward load on right branch

			F_x = p_stage / (2.0 * tan_theta)
			dir_fx = Vector3(1, 0, 0) # Outward thrust pointing right

			var raw_res := Vector3(F_x, F_y, 0.0)
			R = raw_res.length()
			dir_res = raw_res.normalized()
			F_fric = mu * R
			tau_fric = mu * R * r_pin
			# When extending (motion_dir > 0), right hinge moves inward (-X). Friction opposes outward (+X).
			dir_fric = Vector3(motion_dir, 0, 0)

			title = "%s · Stage %d Right Lateral Joint [Pin #%d]" % [rig.rig_name, s + 1, pin_idx]
			desc = "Lateral scissor hinge experiencing outward thrust Fx and vertical load transmission Fy."

		else:
			# Central Hinge
			if s == n - 1:
				# Bottommost pin supporting mass directly
				F_y = -m * g
				dir_fy = Vector3(0, -1, 0)
				F_x = 0.0
				dir_fx = Vector3.ZERO
				R = m * g
				dir_res = Vector3(0, -1, 0)
				F_fric = mu * R
				tau_fric = mu * R * r_pin
				# Opposes vertical downward extension by pointing upward (+Y)
				dir_fric = Vector3(0, motion_dir, 0)

				title = "%s · Bottom Payload Suspension Pin [Pin #%d]" % [rig.rig_name, pin_idx]
				desc = "Lowest pivot transmitting payload gravity directly into the bottom scissor stage."
			else:
				# Intermediate central coupling hinge
				F_y = -p_below
				dir_fy = Vector3(0, -1, 0)
				F_x = p_below / (2.0 * tan_theta)
				dir_fx = Vector3(1, 0, 0) # Scissor cross-shear
				var raw_res := Vector3(F_x * 0.5, F_y, 0.0)
				R = raw_res.length()
				dir_res = raw_res.normalized()
				F_fric = mu * R
				tau_fric = mu * R * r_pin
				# Opposes vertical downward expansion motion
				dir_fric = Vector3(0, motion_dir, 0)

				title = "%s · Stage %d Central Coupling Joint [Pin #%d]" % [rig.rig_name, s + 1, pin_idx]
				desc = "Intermediate coupling pivot transferring vertical load between consecutive scissor stages."

	# Visual lengths with guaranteed readability:
	# Even if force is small (e.g. 0.81 N), vis_len >= 0.38m!
	var len_fy: float = clampf(0.38 + absf(F_y) * 0.034, 0.38, 1.05) if absf(F_y) > 0.01 else 0.0
	var len_fx: float = clampf(0.38 + absf(F_x) * 0.034, 0.38, 1.05) if absf(F_x) > 0.01 else 0.0
	var len_res: float = clampf(0.42 + R * 0.034, 0.42, 1.15) if R > 0.01 else 0.0
	var len_fric: float = clampf(0.38 + F_fric * 0.055, 0.38, 0.85) if F_fric > 0.01 else 0.0

	return {
		"dir_fy": dir_fy,
		"len_fy": len_fy,
		"dir_fx": dir_fx,
		"len_fx": len_fx,
		"dir_res": dir_res,
		"len_res": len_res,
		"dir_fric": dir_fric,
		"len_fric": len_fric,
		"lbl_fy": "Fy = %+.2f N" % F_y,
		"lbl_fx": "Fx = %+.2f N" % F_x,
		"lbl_res": "R = %.2f N" % R,
		"lbl_fric": "F_fric = %.2f N (μ=%.2f)" % [F_fric, mu],
		"F_y": F_y,
		"F_x": F_x,
		"R": R,
		"F_fric": F_fric,
		"tau_fric": tau_fric,
		"theta_deg": rad_to_deg(theta),
		"title": title,
		"desc": desc
	}


func _update_force_visualizer() -> void:
	if inspected_rig == null or not is_instance_valid(inspected_rig):
		_deselect_pin()
		return

	var pin_pos: Vector3 = inspected_rig.get_pin_global_position(inspected_pin_idx)
	pin_highlight_ring.global_position = pin_pos

	var data: Dictionary = _calculate_joint_forces(inspected_rig, inspected_pin_idx)

	# Fy, Fx, R originate at pin center
	_update_arrow_vector(arrow_fy_data, pin_pos, data.dir_fy, data.len_fy, data.lbl_fy)
	_update_arrow_vector(arrow_fx_data, pin_pos, data.dir_fx, data.len_fx, data.lbl_fx)
	_update_arrow_vector(arrow_res_data, pin_pos, data.dir_res, data.len_res, data.lbl_res)

	# F_fric originates on the front washer face of the pin (+0.065m Z) so it NEVER clips or collides with other arrows
	var fric_origin: Vector3 = pin_pos + Vector3(0, 0, 0.065)
	_update_arrow_vector(arrow_fric_data, fric_origin, data.dir_fric, data.len_fric, data.lbl_fric)

	if joint_val_fy != null:
		joint_card_title.text = data.title
		joint_card_desc.text = data.desc
		joint_val_fy.text = "%+.2f N  (Vertical Load / Reaction)" % data.F_y
		joint_val_fx.text = "%+.2f N  (Lateral Scissor Thrust)" % data.F_x
		joint_val_res.text = "%.2f N  (Joint Resultant Contact R)" % data.R
		joint_val_fric.text = "%.2f N  (Coulomb Hinge Friction f_k)" % data.F_fric
		if joint_val_tau != null:
			joint_val_tau.text = "%.3f N·m  (Pin Resistance Torque τ)" % data.tau_fric
		joint_val_theta.text = "%.1f°  (Scissor Half-Angle θ)" % data.theta_deg


func _on_pin_clicked(rig: PantographRig, pin_idx: int, _pos: Vector3) -> void:
	if inspected_rig == rig and inspected_pin_idx == pin_idx:
		_deselect_pin()
	else:
		inspected_rig = rig
		inspected_pin_idx = pin_idx
		force_visualizer_root.visible = true
		if is_mobile_layout:
			if mobile_sidebar != null and mobile_sidebar.visible:
				_show_mobile_tab(2)
			elif mobile_pin_card != null and not is_focus_mode:
				mobile_pin_card.visible = true
				var data: Dictionary = _calculate_joint_forces(rig, pin_idx)
				if lbl_mob_pin_summary != null:
					lbl_mob_pin_summary.text = "%s [Pin #%d] · R=%.1fN, Fx=%.1fN" % [rig.rig_name, pin_idx, data.R, data.F_x]
		else:
			_show_right_tab(1)
		_update_force_visualizer()


func _deselect_pin() -> void:
	inspected_rig = null
	inspected_pin_idx = -1
	if force_visualizer_root != null:
		force_visualizer_root.visible = false
	if mobile_pin_card != null:
		mobile_pin_card.visible = false
	if not is_mobile_layout:
		_show_right_tab(0)


# --- Theme & Focus Mode Switching Logic ---
func _set_focus_mode(focus: bool) -> void:
	is_focus_mode = focus
	if is_mobile_layout:
		if mobile_top_bar != null:
			mobile_top_bar.visible = not focus
		if mobile_sidebar != null:
			mobile_sidebar.visible = false
		if backdrop_scrim != null:
			backdrop_scrim.visible = false
		if mobile_pin_card != null:
			mobile_pin_card.visible = (not focus) if inspected_rig != null else false
	else:
		if header_panel != null:
			header_panel.visible = not focus
		if left_panel != null:
			left_panel.visible = not focus
		if right_panel != null:
			right_panel.visible = not focus
		if bottom_panel != null:
			bottom_panel.visible = not focus
	if formulas_modal != null:
		formulas_modal.visible = false
	if btn_restore_ui != null:
		btn_restore_ui.visible = focus
	if btn_focus_toggle != null:
		btn_focus_toggle.text = "Exit Focus" if focus else "👁️ Focus Mode"


func _apply_theme(is_dark: bool) -> void:
	is_dark_theme = is_dark

	# 1. WorldEnvironment Sky & Ambient Light
	if sky_proc_mat != null:
		if is_dark:
			sky_proc_mat.sky_top_color = Color(0.04, 0.05, 0.08)
			sky_proc_mat.sky_horizon_color = Color(0.08, 0.10, 0.16)
			sky_proc_mat.ground_bottom_color = Color(0.02, 0.025, 0.04)
			sky_proc_mat.ground_horizon_color = Color(0.06, 0.08, 0.12)
		else:
			sky_proc_mat.sky_top_color = Color(0.965, 0.968, 0.976)
			sky_proc_mat.sky_horizon_color = Color(0.885, 0.895, 0.92)
			sky_proc_mat.ground_bottom_color = Color(0.84, 0.85, 0.88)
			sky_proc_mat.ground_horizon_color = Color(0.885, 0.895, 0.92)

	if env_res != null:
		if is_dark:
			env_res.ambient_light_color = Color(0.18, 0.20, 0.28)
			env_res.ambient_light_energy = 0.42
			env_res.glow_enabled = true
			env_res.glow_bloom = 0.06
			env_res.glow_intensity = 0.28
			env_res.glow_blend_mode = Environment.GLOW_BLEND_MODE_SOFTLIGHT
		else:
			env_res.ambient_light_color = Color(0.88, 0.89, 0.92)
			env_res.ambient_light_energy = 0.65
			env_res.glow_enabled = false

	# 2. Directional Lights
	if dir_light != null:
		dir_light.light_color = Color(0.95, 0.96, 1.0) if is_dark else Color(1.0, 0.992, 0.98)
		dir_light.light_energy = 0.95 if is_dark else 1.35
	if fill_light != null:
		fill_light.light_color = Color(0.25, 0.45, 0.70) if is_dark else Color(0.92, 0.94, 0.98)
		fill_light.light_energy = 0.30 if is_dark else 0.45
	if rim_light != null:
		rim_light.light_color = Color(1.0, 0.55, 0.15) if is_dark else Color(0.98, 0.98, 1.0)
		rim_light.light_energy = 0.90 if is_dark else 0.40

	# 3. Showroom Bay Materials
	if mat_floor != null:
		mat_floor.albedo_color = Color(0.065, 0.075, 0.095) if is_dark else Color(0.905, 0.91, 0.925)
		mat_floor.metallic = 0.22 if is_dark else 0.02
		mat_floor.roughness = 0.35 if is_dark else 0.45
	if mat_gantry != null:
		mat_gantry.albedo_color = Color(0.12, 0.13, 0.16) if is_dark else Color(0.24, 0.25, 0.28)
	if mat_gantry_accent != null:
		mat_gantry_accent.albedo_color = Color(1.0, 0.55, 0.12) if is_dark else Color(0.78, 0.80, 0.85)
		mat_gantry_accent.emission_enabled = is_dark
		mat_gantry_accent.emission = Color(1.0, 0.55, 0.12) * 0.40 if is_dark else Color.BLACK

	# 4. Rigs
	if rig_a != null:
		rig_a.set_dark_theme(is_dark)
	if rig_c != null:
		rig_c.set_dark_theme(is_dark)
	if rig_b != null:
		rig_b.set_dark_theme(is_dark)

	# 5. LiveGraph
	if live_graph != null:
		live_graph.dark_theme = is_dark
		live_graph.queue_redraw()

	# 6. UI Panels StyleBoxes
	var panel_bg := Color(0.07, 0.08, 0.12, 0.82) if is_dark else Color(1.0, 1.0, 1.0, 0.50)
	var panel_border := Color(0.35, 0.40, 0.55, 0.40) if is_dark else Color(1.0, 1.0, 1.0, 0.80)
	var panel_shadow := Color(0.0, 0.0, 0.0, 0.35) if is_dark else Color(0.0, 0.0, 0.0, 0.06)

	for p in theme_panels:
		var sb: StyleBoxFlat = p.get_theme_stylebox("panel") as StyleBoxFlat
		if sb:
			sb.bg_color = panel_bg
			sb.border_color = panel_border
			sb.shadow_color = panel_shadow

	# 7. UI Buttons
	var btn_normal_bg := Color(0.12, 0.14, 0.20, 0.80) if is_dark else Color(1.0, 1.0, 1.0, 0.65)
	var btn_normal_border := Color(0.30, 0.35, 0.48, 0.50) if is_dark else Color(1.0, 1.0, 1.0, 0.90)
	var btn_text_color := Color(0.92, 0.94, 0.98) if is_dark else Color(0.114, 0.114, 0.122)

	var btn_hover_bg := Color(0.18, 0.21, 0.30, 0.95) if is_dark else Color(1.0, 1.0, 1.0, 0.90)
	var btn_hover_border := Color(1.0, 0.55, 0.15, 0.80) if is_dark else Color(0.0, 0.443, 0.89, 0.40)

	var btn_pressed_bg := Color(1.0, 0.55, 0.15, 0.20) if is_dark else Color(0.0, 0.443, 0.89, 0.15)
	var btn_pressed_border := Color(1.0, 0.55, 0.15, 1.0) if is_dark else Color(0.0, 0.443, 0.89, 0.80)

	for b in theme_buttons:
		b.add_theme_color_override("font_color", btn_text_color)
		b.add_theme_color_override("font_pressed_color", btn_text_color)
		b.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0) if is_dark else btn_text_color)
		b.add_theme_color_override("font_focus_color", btn_text_color)

		var s_norm: StyleBoxFlat = b.get_theme_stylebox("normal") as StyleBoxFlat
		if s_norm:
			s_norm.bg_color = btn_normal_bg
			s_norm.border_color = btn_normal_border
		var s_hov: StyleBoxFlat = b.get_theme_stylebox("hover") as StyleBoxFlat
		if s_hov:
			s_hov.bg_color = btn_hover_bg
			s_hov.border_color = btn_hover_border
		var s_press: StyleBoxFlat = b.get_theme_stylebox("pressed") as StyleBoxFlat
		if s_press:
			s_press.bg_color = btn_pressed_bg
			s_press.border_color = btn_pressed_border

	# 8. Labels
	var col_title := Color(0.95, 0.96, 0.98) if is_dark else Color(0.114, 0.114, 0.122)
	var col_sec := Color(0.65, 0.68, 0.76) if is_dark else Color(0.40, 0.42, 0.48)

	for lbl in theme_labels_primary:
		lbl.add_theme_color_override("font_color", col_title)
	for lbl in theme_labels_secondary:
		lbl.add_theme_color_override("font_color", col_sec)

	# 9. Sliders & Progress Bars
	var track_color := Color(0.18, 0.20, 0.28) if is_dark else Color(0.84, 0.85, 0.88)
	for sl in theme_sliders:
		var st: StyleBoxFlat = sl.get_theme_stylebox("slider") as StyleBoxFlat
		if st:
			st.bg_color = track_color

	var bar_bg_color := Color(0.15, 0.17, 0.24) if is_dark else Color(0.86, 0.87, 0.90)
	for item in theme_progress_bars:
		var bar: ProgressBar = item["bar"]
		var bg_sb: StyleBoxFlat = bar.get_theme_stylebox("background") as StyleBoxFlat
		if bg_sb:
			bg_sb.bg_color = bar_bg_color

	# 10. Checkboxes
	for cb in theme_checkboxes:
		cb.add_theme_color_override("font_color", btn_text_color)
		cb.add_theme_color_override("font_pressed_color", btn_text_color)
		cb.add_theme_color_override("font_hover_color", btn_text_color)

	# 11. Force Visualizer Materials
	_apply_visualizer_theme(is_dark)

	# 12. Update Button Labels
	if btn_theme_toggle != null:
		btn_theme_toggle.text = "☀️ Light Theme" if is_dark else "🌙 Dark Theme"
	if btn_mob_theme != null:
		btn_mob_theme.text = "☀️" if is_dark else "🌙"


func _apply_visualizer_theme(is_dark: bool) -> void:
	if mat_ring != null:
		mat_ring.emission_enabled = is_dark
		mat_ring.emission = Color(1.0, 0.65, 0.15) * 0.40 if is_dark else Color.BLACK
		mat_ring.emission_energy_multiplier = 0.50 if is_dark else 0.0

	var arrows := [
		{"data": arrow_fy_data, "col": Color(0.15, 0.75, 1.0) if is_dark else Color(0.0, 0.44, 0.95)},
		{"data": arrow_fx_data, "col": Color(1.0, 0.35, 0.20) if is_dark else Color(0.95, 0.22, 0.22)},
		{"data": arrow_res_data, "col": Color(0.25, 1.0, 0.50) if is_dark else Color(0.12, 0.75, 0.35)},
		{"data": arrow_fric_data, "col": Color(1.0, 0.82, 0.15) if is_dark else Color(0.95, 0.65, 0.05)}
	]

	for a in arrows:
		var dict: Dictionary = a["data"]
		if dict.is_empty():
			continue
		var mat: StandardMaterial3D = dict["mat"]
		var col: Color = a["col"]
		mat.albedo_color = col
		mat.emission_enabled = is_dark
		mat.emission = col * 0.40 if is_dark else Color.BLACK
		mat.emission_energy_multiplier = 0.45 if is_dark else 0.0
		var lbl: Label3D = dict["label"]
		lbl.modulate = col
		lbl.outline_modulate = Color(0.04, 0.05, 0.08, 0.95) if is_dark else Color(1.0, 1.0, 1.0, 0.98)


func _show_right_tab(tab_idx: int) -> void:
	if tab_idx == 0:
		if telemetry_view != null:
			telemetry_view.visible = true
		if joint_view != null:
			joint_view.visible = false
		if btn_tab_telemetry != null:
			btn_tab_telemetry.add_theme_color_override("font_color", Color(0.0, 0.443, 0.89))
		if btn_tab_joint != null:
			var default_col: Color = Color(0.92, 0.94, 0.98) if is_dark_theme else Color(0.114, 0.114, 0.122)
			btn_tab_joint.add_theme_color_override("font_color", default_col)
	else:
		if telemetry_view != null:
			telemetry_view.visible = false
		if joint_view != null:
			joint_view.visible = true
		if btn_tab_joint != null:
			btn_tab_joint.add_theme_color_override("font_color", Color(0.0, 0.443, 0.89))
		if btn_tab_telemetry != null:
			var default_col: Color = Color(0.92, 0.94, 0.98) if is_dark_theme else Color(0.114, 0.114, 0.122)
			btn_tab_telemetry.add_theme_color_override("font_color", default_col)


func _toggle_mobile_sidebar(open: bool) -> void:
	if mobile_sidebar == null:
		return
	mobile_sidebar.visible = open
	if backdrop_scrim != null:
		backdrop_scrim.visible = open
	if mobile_pin_card != null:
		if open:
			mobile_pin_card.visible = false
		elif inspected_rig != null and not is_focus_mode:
			mobile_pin_card.visible = true
	if open:
		_show_mobile_tab(current_mobile_tab)


func _show_mobile_tab(tab_idx: int) -> void:
	current_mobile_tab = tab_idx
	if mob_scroll_controls:
		mob_scroll_controls.visible = (tab_idx == 0)
	if mob_scroll_telem:
		mob_scroll_telem.visible = (tab_idx == 1)
	if mob_scroll_joint:
		mob_scroll_joint.visible = (tab_idx == 2)
	if mob_scroll_graph:
		mob_scroll_graph.visible = (tab_idx == 3)

	var active_color := Color(0.0, 0.443, 0.89)
	var default_color: Color = Color(0.92, 0.94, 0.98) if is_dark_theme else Color(0.114, 0.114, 0.122)

	var tab_btns := [btn_mob_tab_0, btn_mob_tab_1, btn_mob_tab_2, btn_mob_tab_3]
	for i in range(tab_btns.size()):
		var b: Button = tab_btns[i]
		if b != null:
			b.add_theme_color_override("font_color", active_color if i == tab_idx else default_color)


func _on_screen_tapped(screen_pos: Vector2) -> void:
	if not is_inside_tree() or camera == null:
		return
	if is_mobile_layout and mobile_sidebar != null and mobile_sidebar.visible:
		return

	var ray_origin := camera.project_ray_origin(screen_pos)
	var ray_dir := camera.project_ray_normal(screen_pos)

	var best_rig: PantographRig = null
	var best_pin: int = -1
	var best_dist: float = 0.32

	for rig in [rig_a, rig_c, rig_b]:
		if rig == null or not is_instance_valid(rig):
			continue
		for i in range(rig.get_pin_count()):
			var p: Vector3 = rig.get_pin_global_position(i)
			var v := p - ray_origin
			var proj := v.dot(ray_dir)
			if proj > 0.0:
				var closest_pt: Vector3 = ray_origin + ray_dir * proj
				var dist: float = closest_pt.distance_to(p)
				if dist < best_dist:
					best_dist = dist
					best_rig = rig
					best_pin = i

	if best_rig != null and best_pin != -1:
		_on_pin_clicked(best_rig, best_pin, best_rig.get_pin_global_position(best_pin))
	elif inspected_rig != null:
		_deselect_pin()


func _check_responsive_layout() -> void:
	if not is_inside_tree() or get_viewport() == null:
		return
	var vp_size: Vector2 = get_viewport().get_visible_rect().size
	if vp_size.x <= 0 or vp_size.y <= 0:
		return
	if camera != null and camera.has_method("update_aspect_ratio_framing"):
		camera.update_aspect_ratio_framing(vp_size)
	var is_mobile := (vp_size.x < 1050.0) or (vp_size.x / maxf(vp_size.y, 1.0) < 1.18)
	if is_mobile != is_mobile_layout:
		_apply_responsive_layout(is_mobile, vp_size)
	else:
		if is_mobile:
			_adjust_mobile_sizes(vp_size)
		else:
			_adjust_desktop_sizes(vp_size)


func _apply_responsive_layout(is_mobile: bool, vp_size: Vector2) -> void:
	is_mobile_layout = is_mobile
	if camera != null:
		camera.set_mobile_mode(is_mobile)

	if is_mobile:
		# 1. Hide Desktop Panels
		if header_panel != null:
			header_panel.visible = false
		if left_panel != null:
			left_panel.visible = false
		if right_panel != null:
			right_panel.visible = false
		if bottom_panel != null:
			bottom_panel.visible = false

		# 2. Reparent Content VBoxes into Mobile ScrollContainers
		if left_vbox != null and mob_scroll_controls != null and left_vbox.get_parent() != mob_scroll_controls:
			left_vbox.reparent(mob_scroll_controls, false)
			left_vbox.visible = true
		if telemetry_view != null and mob_scroll_telem != null and telemetry_view.get_parent() != mob_scroll_telem:
			telemetry_view.reparent(mob_scroll_telem, false)
			telemetry_view.visible = true
		if joint_view != null and mob_scroll_joint != null and joint_view.get_parent() != mob_scroll_joint:
			joint_view.reparent(mob_scroll_joint, false)
			joint_view.visible = true
		if graph_vbox != null and mob_scroll_graph != null and graph_vbox.get_parent() != mob_scroll_graph:
			graph_vbox.reparent(mob_scroll_graph, false)
			graph_vbox.visible = true

		# 3. Configure Mobile Top Bar
		if mobile_top_bar != null:
			mobile_top_bar.visible = not is_focus_mode
			mobile_top_bar.offset_left = 8.0
			mobile_top_bar.offset_right = -8.0
			mobile_top_bar.offset_top = 8.0
			mobile_top_bar.offset_bottom = 56.0

		# 4. Configure Mobile Sidebar
		if mobile_sidebar != null:
			var sb_w: float = minf(vp_size.x * 0.88, 380.0)
			mobile_sidebar.offset_right = sb_w
			mobile_sidebar.offset_bottom = vp_size.y

		# 5. Mobile Pin Chip
		if mobile_pin_card != null:
			var pill_w: float = minf(vp_size.x - 24.0, 360.0)
			mobile_pin_card.offset_left = -pill_w * 0.5
			mobile_pin_card.offset_right = pill_w * 0.5
			mobile_pin_card.offset_top = -64.0
			mobile_pin_card.offset_bottom = -16.0
			mobile_pin_card.visible = (inspected_rig != null and not is_focus_mode and not (mobile_sidebar != null and mobile_sidebar.visible))

	else:
		# Desktop Mode:
		# 1. Hide Mobile Controls
		if mobile_top_bar != null:
			mobile_top_bar.visible = false
		if mobile_sidebar != null:
			mobile_sidebar.visible = false
		if backdrop_scrim != null:
			backdrop_scrim.visible = false
		if mobile_pin_card != null:
			mobile_pin_card.visible = false

		# 2. Reparent Content VBoxes back to Desktop Panels
		if left_vbox != null and left_margin != null and left_vbox.get_parent() != left_margin:
			left_vbox.reparent(left_margin, false)
		if telemetry_view != null and right_vbox != null and telemetry_view.get_parent() != right_vbox:
			telemetry_view.reparent(right_vbox, false)
		if joint_view != null and right_vbox != null and joint_view.get_parent() != right_vbox:
			joint_view.reparent(right_vbox, false)
		if right_vbox != null:
			right_vbox.move_child(telemetry_view, 2)
			right_vbox.move_child(joint_view, 3)
		if graph_vbox != null and graph_margin != null and graph_vbox.get_parent() != graph_margin:
			graph_vbox.reparent(graph_margin, false)

		# 3. Restore Desktop Panels
		_adjust_desktop_sizes(vp_size)
		if header_panel != null:
			header_panel.visible = not is_focus_mode
		if left_panel != null:
			left_panel.visible = not is_focus_mode
		if right_panel != null:
			right_panel.visible = not is_focus_mode
		if bottom_panel != null:
			bottom_panel.visible = not is_focus_mode

		_show_right_tab(0 if inspected_rig == null else 1)


func _adjust_mobile_sizes(vp_size: Vector2) -> void:
	if mobile_top_bar != null:
		mobile_top_bar.offset_left = 8.0
		mobile_top_bar.offset_right = -8.0
		mobile_top_bar.offset_top = 8.0
		mobile_top_bar.offset_bottom = 56.0

	if mobile_sidebar != null:
		var sb_w: float = minf(vp_size.x * 0.88, 380.0)
		mobile_sidebar.offset_right = sb_w
		mobile_sidebar.offset_bottom = vp_size.y

	if mobile_pin_card != null:
		var pill_w: float = minf(vp_size.x - 24.0, 360.0)
		mobile_pin_card.offset_left = -pill_w * 0.5
		mobile_pin_card.offset_right = pill_w * 0.5
		mobile_pin_card.offset_top = -64.0
		mobile_pin_card.offset_bottom = -16.0


func _adjust_desktop_sizes(vp_size: Vector2) -> void:
	if left_panel != null:
		left_panel.anchor_left = 0.0
		left_panel.anchor_right = 0.0
		left_panel.anchor_top = 0.0
		left_panel.anchor_bottom = 0.0
		left_panel.offset_left = 24.0
		left_panel.offset_top = 96.0
		left_panel.offset_right = 360.0
		var max_h: float = minf(750.0, vp_size.y - 120.0)
		left_panel.offset_bottom = 96.0 + max_h

	if right_panel != null:
		right_panel.anchor_left = 1.0
		right_panel.anchor_right = 1.0
		right_panel.anchor_top = 0.0
		right_panel.anchor_bottom = 0.0
		right_panel.offset_left = -374.0
		right_panel.offset_right = -24.0
		right_panel.offset_top = 96.0
		var max_h: float = minf(750.0, vp_size.y - 120.0)
		right_panel.offset_bottom = 96.0 + max_h

	if bottom_panel != null:
		bottom_panel.anchor_left = 0.5
		bottom_panel.anchor_right = 0.5
		bottom_panel.anchor_top = 1.0
		bottom_panel.anchor_bottom = 1.0
		bottom_panel.offset_left = -460.0
		bottom_panel.offset_right = 460.0
		bottom_panel.offset_top = -490.0 if is_graph_maximized else -278.0
		bottom_panel.offset_bottom = -16.0
