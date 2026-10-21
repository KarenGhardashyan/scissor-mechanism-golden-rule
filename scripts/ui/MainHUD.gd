class_name MainHUD
extends CanvasLayer

const ThemeManager = preload("res://scripts/ui/ThemeManager.gd")

## MainHUD: SpaceX Crew Dragon / Astro UXDS Scientific Telemetry Interface for Godot 4.5
## Modular responsive control deck with Desktop Split-Screen (60/40) and Mobile Portrait Layout.
## Pure containerized architecture with zero hardcoded panel positions.

signal mass_changed(val: float)
signal stiffness_changed(val: float)
signal efficiency_changed(val: float)
signal friction_changed(val: float)
signal stiction_toggled(enabled: bool)
signal gravity_changed(val: float)
signal rig_selection_changed(rig_id: String)
signal beam_reaction_toggled(is_upper: bool)
signal slow_mo_toggled(is_slow_mo: bool)
signal theme_toggled(is_dark: bool)
signal formulas_requested()
signal reset_view_requested()
signal sim_speed_changed(val: float)
signal sim_pause_toggled(is_paused: bool)
signal jolt_requested()
signal deselect_pin_requested()

# State
var is_dark_theme: bool = true
var is_slow_mo: bool = false
var is_upper_beam: bool = true
var is_stiction_on: bool = true
var current_rig_id: String = "ALL"
var current_mass: float = 0.50
var current_stiffness: float = 981.0
var current_efficiency: float = 0.94
var current_friction: float = 0.20
var current_gravity: float = 9.81
var current_sim_speed: float = 1.00
var is_sim_paused: bool = false

# Root Nodes
var root_control: Control
var desktop_container: VBoxContainer
var mobile_container: VBoxContainer

# Desktop Nodes
var top_bar: PanelContainer
var desktop_split: HBoxContainer
var desktop_3d_viewport_spacer: Control
var desktop_right_stack: VBoxContainer
var control_card: PanelContainer
var graph_card: PanelContainer
var live_graph: LiveGraph

# Brand & Card Labels
var lbl_title: Label
var lbl_sub: Label
var card_title: Label

# Parameter Sub-Tabs & Panels
var param_tab_buttons: Array[Button] = []
var param_panels: Array[Control] = []
var current_param_tab: int = 0
var all_param_tag_labels: Array[Label] = []
var all_param_val_labels: Array[Label] = []
var all_param_preset_buttons: Array[Button] = []

var lbl_m_tag: Label
var lbl_fric_tag: Label
var lbl_k_tag: Label
var lbl_eta_tag: Label
var lbl_g_tag: Label
var lbl_speed_tag: Label

# Desktop Controls
var lbl_mass_val: Label
var slider_mass: HSlider
var btn_mass_dec: Button
var btn_mass_inc: Button

var lbl_k_val: Label
var slider_stiffness: HSlider

var lbl_eta_val: Label
var slider_efficiency: HSlider

var lbl_fric_val: Label
var slider_friction: HSlider

var lbl_g_val: Label
var slider_gravity: HSlider

var lbl_speed_val: Label
var slider_sim_speed: HSlider
var btn_play_pause: Button
var btn_jolt: Button
var btn_deselect_pin: Button

var btn_beam_toggle: Button
var btn_friction_toggle: Button
var btn_slow_mo: Button
var btn_theme: Button
var btn_formulas: Button
var btn_reset_view: Button

# Telemetry Metric Tiles (3x2 Grid)
var tile_val_h: Label
var tile_val_l: Label
var tile_val_r: Label
var tile_val_fx: Label
var tile_val_fy: Label
var tile_val_fric: Label

# Rig Selection Buttons
var rig_buttons: Dictionary = {}

# Mobile Nodes
var mobile_top_bar: PanelContainer
var mobile_3d_spacer: Control
var mobile_bottom_sheet: PanelContainer
var mobile_tab_controls: VBoxContainer
var mobile_tab_graph: VBoxContainer
var btn_mob_tab_ctrl: Button
var btn_mob_tab_graph: Button
var btn_mob_slow: Button
var btn_mob_th: Button
var btn_mob_form: Button
var slider_mob_mass: HSlider
var lbl_mob_mass_val: Label
var lbl_mob_telem_row: Label

# Formulas & Theory Modal
var formulas_layer: CanvasLayer
var formulas_modal: PanelContainer
var formulas_backdrop: ColorRect


func _ready() -> void:
	layer = 10
	_build_ui_hierarchy()
	_build_formulas_modal()
	apply_theme(is_dark_theme)
	_connect_events()


func _build_ui_hierarchy() -> void:
	# Fullscreen Root Container: Strictly ignore clicks so 3D camera / pins receive input!
	root_control = Control.new()
	root_control.name = "RootHUD"
	root_control.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root_control)

	_build_desktop_layout()
	_build_mobile_layout()


# -----------------------------------------------------------------------------
# DESKTOP LAYOUT (Landscape: aspect >= 1.1)
# -----------------------------------------------------------------------------

func _build_desktop_layout() -> void:
	desktop_container = VBoxContainer.new()
	desktop_container.name = "DesktopContainer"
	desktop_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	desktop_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	desktop_container.add_theme_constant_override("separation", 8)
	root_control.add_child(desktop_container)

	# 1. TOP TELEMETRY BAR (Height: 54px)
	top_bar = PanelContainer.new()
	top_bar.name = "TopTelemetryBar"
	top_bar.custom_minimum_size = Vector2(0, 54)
	top_bar.mouse_filter = Control.MOUSE_FILTER_STOP
	desktop_container.add_child(top_bar)

	var top_margin := MarginContainer.new()
	top_margin.add_theme_constant_override("margin_left", 18)
	top_margin.add_theme_constant_override("margin_right", 18)
	top_margin.add_theme_constant_override("margin_top", 6)
	top_margin.add_theme_constant_override("margin_bottom", 6)
	top_bar.add_child(top_margin)

	var top_hbox := HBoxContainer.new()
	top_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	top_hbox.add_theme_constant_override("separation", 14)
	top_margin.add_child(top_hbox)

	# Left: Brand / Title
	var brand_box := VBoxContainer.new()
	brand_box.alignment = BoxContainer.ALIGNMENT_CENTER
	brand_box.add_theme_constant_override("separation", 1)

	lbl_title = Label.new()
	lbl_title.text = "PANTOGRAPH LAB // GOLDEN RULE"
	lbl_title.add_theme_font_size_override("font_size", 13)
	lbl_title.add_theme_color_override("font_color", ThemeManager.DARK_ACCENT_CYAN)
	brand_box.add_child(lbl_title)

	lbl_sub = Label.new()
	lbl_sub.text = "400 Hz SYMPLECTIC EULER · MISSION TELEMETRY"
	lbl_sub.add_theme_font_size_override("font_size", 9)
	lbl_sub.add_theme_color_override("font_color", ThemeManager.DARK_TEXT_MUTED)
	brand_box.add_child(lbl_sub)
	top_hbox.add_child(brand_box)

	var top_spacer1 := Control.new()
	top_spacer1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_spacer1.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_hbox.add_child(top_spacer1)

	# Center: Segmented Rig Selection Control
	var rig_seg_box := HBoxContainer.new()
	rig_seg_box.add_theme_constant_override("separation", 6)

	var rigs_config := [
		{"id": "ALL", "label": "ALL RIGS"},
		{"id": "A", "label": "RIG A (n=3)"},
		{"id": "B", "label": "RIG B (n=5)"},
		{"id": "C", "label": "RIG C (1:2:3)"}
	]
	for cfg in rigs_config:
		var btn := Button.new()
		btn.text = cfg["label"]
		btn.custom_minimum_size = Vector2(92, 34)
		btn.add_theme_font_size_override("font_size", 11)
		var r_id: String = cfg["id"]
		btn.pressed.connect(func(): _on_rig_button_pressed(r_id))
		rig_seg_box.add_child(btn)
		rig_buttons[r_id] = btn
	top_hbox.add_child(rig_seg_box)

	var top_spacer2 := Control.new()
	top_spacer2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_spacer2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_hbox.add_child(top_spacer2)

	# Right: Action Pills
	btn_slow_mo = Button.new()
	btn_slow_mo.text = "0.2x SLOW-MO"
	btn_slow_mo.custom_minimum_size = Vector2(110, 34)
	btn_slow_mo.add_theme_font_size_override("font_size", 11)
	btn_slow_mo.pressed.connect(_on_slow_mo_pressed)
	top_hbox.add_child(btn_slow_mo)

	btn_theme = Button.new()
	btn_theme.text = "THEME: DARK" if is_dark_theme else "THEME: LIGHT"
	btn_theme.custom_minimum_size = Vector2(110, 34)
	btn_theme.add_theme_font_size_override("font_size", 11)
	btn_theme.pressed.connect(_on_theme_pressed)
	top_hbox.add_child(btn_theme)

	btn_formulas = Button.new()
	btn_formulas.text = "FORMULAS"
	btn_formulas.custom_minimum_size = Vector2(90, 34)
	btn_formulas.add_theme_font_size_override("font_size", 11)
	btn_formulas.pressed.connect(func():
		open_formulas_modal()
		formulas_requested.emit()
	)
	top_hbox.add_child(btn_formulas)

	btn_reset_view = Button.new()
	btn_reset_view.text = "RESET"
	btn_reset_view.custom_minimum_size = Vector2(75, 34)
	btn_reset_view.add_theme_font_size_override("font_size", 11)
	btn_reset_view.pressed.connect(func(): reset_view_requested.emit())
	top_hbox.add_child(btn_reset_view)

	# 2. MAIN WORKSPACE SPLIT (Left 60% 3D Viewport, Right 40% Control Deck)
	desktop_split = HBoxContainer.new()
	desktop_split.name = "DesktopSplit"
	desktop_split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	desktop_split.mouse_filter = Control.MOUSE_FILTER_IGNORE
	desktop_split.add_theme_constant_override("separation", 16)
	desktop_container.add_child(desktop_split)

	# Left 60%: Empty viewport spacer that lets all clicks pass through to 3D OrbitCamera!
	desktop_3d_viewport_spacer = Control.new()
	desktop_3d_viewport_spacer.name = "Desktop3DViewportSpacer"
	desktop_3d_viewport_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	desktop_3d_viewport_spacer.size_flags_stretch_ratio = 1.45 # ~60% of width
	desktop_3d_viewport_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	desktop_split.add_child(desktop_3d_viewport_spacer)

	# Right 40%: Vertical Stack (Controls Top + Live Graph Bottom)
	var right_margin := MarginContainer.new()
	right_margin.name = "RightMargin"
	right_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_margin.size_flags_stretch_ratio = 1.00 # ~40% of width
	right_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	right_margin.add_theme_constant_override("margin_right", 16)
	right_margin.add_theme_constant_override("margin_bottom", 12)
	desktop_split.add_child(right_margin)

	desktop_right_stack = VBoxContainer.new()
	desktop_right_stack.name = "DesktopRightStack"
	desktop_right_stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
	desktop_right_stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	desktop_right_stack.add_theme_constant_override("separation", 12)
	right_margin.add_child(desktop_right_stack)

	# Upper Card: Control & Telemetry Matrix
	control_card = PanelContainer.new()
	control_card.name = "ControlMatrixCard"
	control_card.mouse_filter = Control.MOUSE_FILTER_STOP
	desktop_right_stack.add_child(control_card)

	var ctrl_vbox := VBoxContainer.new()
	ctrl_vbox.add_theme_constant_override("separation", 10)
	control_card.add_child(ctrl_vbox)

	_build_control_card_tabs(ctrl_vbox)

	# Lower Card: Realtime Live Graph L(m)
	graph_card = PanelContainer.new()
	graph_card.name = "LiveGraphCard"
	graph_card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	graph_card.custom_minimum_size = Vector2(0, 240)
	graph_card.mouse_filter = Control.MOUSE_FILTER_STOP
	desktop_right_stack.add_child(graph_card)

	var graph_margin := MarginContainer.new()
	graph_margin.add_theme_constant_override("margin_left", 6)
	graph_margin.add_theme_constant_override("margin_right", 6)
	graph_margin.add_theme_constant_override("margin_top", 6)
	graph_margin.add_theme_constant_override("margin_bottom", 6)
	graph_card.add_child(graph_margin)

	live_graph = LiveGraph.new()
	live_graph.name = "LiveGraphPlot"
	live_graph.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	live_graph.size_flags_vertical = Control.SIZE_EXPAND_FILL
	live_graph.mass_scrubbed.connect(func(m_val: float):
		slider_mass.value = m_val
	)
	graph_margin.add_child(live_graph)


var metric_tiles: Array[PanelContainer] = []
var metric_tag_labels: Array[Label] = []
var metric_num_labels: Array[Dictionary] = []


func _create_metric_tile(parent: GridContainer, label_text: String, init_val: String, accent_col: Color = Color.WHITE) -> Label:
	var tile := PanelContainer.new()
	tile.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
	metric_tiles.append(tile)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 3)
	tile.add_child(vbox)

	var lbl_tag := Label.new()
	lbl_tag.text = label_text
	lbl_tag.add_theme_font_size_override("font_size", 11)
	lbl_tag.add_theme_color_override("font_color", ThemeManager.DARK_TEXT_MUTED)
	vbox.add_child(lbl_tag)
	metric_tag_labels.append(lbl_tag)

	var lbl_num := Label.new()
	lbl_num.text = init_val
	lbl_num.add_theme_font_size_override("font_size", 20)
	if accent_col != Color.WHITE:
		lbl_num.add_theme_color_override("font_color", accent_col)
	else:
		lbl_num.add_theme_color_override("font_color", ThemeManager.DARK_TEXT_PRIMARY)
	vbox.add_child(lbl_num)
	metric_num_labels.append({"label": lbl_num, "accent": accent_col})

	parent.add_child(tile)
	return lbl_num


# -----------------------------------------------------------------------------
# MOBILE LAYOUT (Portrait: aspect < 1.1)
# -----------------------------------------------------------------------------

func _build_mobile_layout() -> void:
	mobile_container = VBoxContainer.new()
	mobile_container.name = "MobileContainer"
	mobile_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	mobile_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mobile_container.add_theme_constant_override("separation", 4)
	mobile_container.visible = false
	root_control.add_child(mobile_container)

	# 1. TOP MOBILE BAR (~14% Height)
	mobile_top_bar = PanelContainer.new()
	mobile_top_bar.name = "MobileTopBar"
	mobile_top_bar.custom_minimum_size = Vector2(0, 96)
	mobile_top_bar.mouse_filter = Control.MOUSE_FILTER_STOP
	mobile_container.add_child(mobile_top_bar)

	var mob_top_margin := MarginContainer.new()
	mob_top_margin.add_theme_constant_override("margin_left", 12)
	mob_top_margin.add_theme_constant_override("margin_right", 12)
	mob_top_margin.add_theme_constant_override("margin_top", 8)
	mob_top_margin.add_theme_constant_override("margin_bottom", 6)
	mobile_top_bar.add_child(mob_top_margin)

	var mob_vbox := VBoxContainer.new()
	mob_vbox.add_theme_constant_override("separation", 6)
	mob_top_margin.add_child(mob_vbox)

	# Row 1: Segmented Rigs (Height >= 42px)
	var mob_rig_row := HBoxContainer.new()
	mob_rig_row.add_theme_constant_override("separation", 6)
	for id in ["ALL", "A", "B", "C"]:
		var btn := Button.new()
		btn.text = id
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size = Vector2(0, 42)
		btn.add_theme_font_size_override("font_size", 14)
		btn.pressed.connect(func(): _on_rig_button_pressed(id))
		mob_rig_row.add_child(btn)
	mob_vbox.add_child(mob_rig_row)

	# Row 2: Telemetry summary line + Quick tools
	var mob_telem_row := HBoxContainer.new()
	lbl_mob_telem_row = Label.new()
	lbl_mob_telem_row.text = "H: 7.5cm · L: 22.5cm · R: 3.36N · fs: 0.67N"
	lbl_mob_telem_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_mob_telem_row.add_theme_font_size_override("font_size", 10)
	lbl_mob_telem_row.add_theme_color_override("font_color", ThemeManager.DARK_ACCENT_CYAN)
	mob_telem_row.add_child(lbl_mob_telem_row)

	btn_mob_slow = Button.new()
	btn_mob_slow.text = "SLOW"
	btn_mob_slow.custom_minimum_size = Vector2(46, 28)
	btn_mob_slow.add_theme_font_size_override("font_size", 10)
	btn_mob_slow.pressed.connect(_on_slow_mo_pressed)
	mob_telem_row.add_child(btn_mob_slow)

	btn_mob_th = Button.new()
	btn_mob_th.text = "THEME"
	btn_mob_th.custom_minimum_size = Vector2(50, 28)
	btn_mob_th.add_theme_font_size_override("font_size", 10)
	btn_mob_th.pressed.connect(_on_theme_pressed)
	mob_telem_row.add_child(btn_mob_th)

	btn_mob_form = Button.new()
	btn_mob_form.text = "FORM"
	btn_mob_form.custom_minimum_size = Vector2(46, 28)
	btn_mob_form.add_theme_font_size_override("font_size", 10)
	btn_mob_form.pressed.connect(func():
		open_formulas_modal()
		formulas_requested.emit()
	)
	mob_telem_row.add_child(btn_mob_form)
	mob_vbox.add_child(mob_telem_row)

	# 2. CENTRAL 3D WORKSPACE SPACER (~52% Height)
	mobile_3d_spacer = Control.new()
	mobile_3d_spacer.name = "Mobile3DSpacer"
	mobile_3d_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	mobile_3d_spacer.size_flags_stretch_ratio = 1.6
	mobile_3d_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mobile_container.add_child(mobile_3d_spacer)

	# 3. BOTTOM SHEET (~34% Height)
	mobile_bottom_sheet = PanelContainer.new()
	mobile_bottom_sheet.name = "MobileBottomSheet"
	mobile_bottom_sheet.custom_minimum_size = Vector2(0, 220)
	mobile_bottom_sheet.mouse_filter = Control.MOUSE_FILTER_STOP
	mobile_container.add_child(mobile_bottom_sheet)

	var mob_bot_margin := MarginContainer.new()
	mob_bot_margin.add_theme_constant_override("margin_left", 14)
	mob_bot_margin.add_theme_constant_override("margin_right", 14)
	mob_bot_margin.add_theme_constant_override("margin_top", 8)
	mob_bot_margin.add_theme_constant_override("margin_bottom", 10)
	mobile_bottom_sheet.add_child(mob_bot_margin)

	var mob_bot_vbox := VBoxContainer.new()
	mob_bot_vbox.add_theme_constant_override("separation", 8)
	mob_bot_margin.add_child(mob_bot_vbox)

	# Mobile Tabs Header
	var tab_bar := HBoxContainer.new()
	tab_bar.add_theme_constant_override("separation", 8)

	btn_mob_tab_ctrl = Button.new()
	btn_mob_tab_ctrl.text = "🎛 Controls"
	btn_mob_tab_ctrl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_mob_tab_ctrl.custom_minimum_size = Vector2(0, 36)
	btn_mob_tab_ctrl.pressed.connect(func(): _switch_mobile_tab(0))
	tab_bar.add_child(btn_mob_tab_ctrl)

	btn_mob_tab_graph = Button.new()
	btn_mob_tab_graph.text = "📈 L(m) Profile"
	btn_mob_tab_graph.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_mob_tab_graph.custom_minimum_size = Vector2(0, 36)
	btn_mob_tab_graph.pressed.connect(func(): _switch_mobile_tab(1))
	tab_bar.add_child(btn_mob_tab_graph)
	mob_bot_vbox.add_child(tab_bar)

	# Tab 0: Controls
	mobile_tab_controls = VBoxContainer.new()
	mobile_tab_controls.add_theme_constant_override("separation", 10)
	mob_bot_vbox.add_child(mobile_tab_controls)

	var m_row := HBoxContainer.new()
	var m_tag := Label.new()
	m_tag.text = "MASS (m):"
	m_tag.add_theme_font_size_override("font_size", 12)
	m_row.add_child(m_tag)

	lbl_mob_mass_val = Label.new()
	lbl_mob_mass_val.text = "0.50 kg"
	lbl_mob_mass_val.add_theme_font_size_override("font_size", 16)
	lbl_mob_mass_val.add_theme_color_override("font_color", ThemeManager.DARK_ACCENT_CYAN)
	m_row.add_child(lbl_mob_mass_val)

	var m_sp := Control.new()
	m_sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	m_row.add_child(m_sp)

	var btn_m_dec := Button.new()
	btn_m_dec.text = "−0.05"
	btn_m_dec.custom_minimum_size = Vector2(60, 32)
	btn_m_dec.pressed.connect(func(): _adjust_mass(-0.05))
	m_row.add_child(btn_m_dec)

	var btn_m_inc := Button.new()
	btn_m_inc.text = "+0.05"
	btn_m_inc.custom_minimum_size = Vector2(60, 32)
	btn_m_inc.pressed.connect(func(): _adjust_mass(0.05))
	m_row.add_child(btn_m_inc)
	mobile_tab_controls.add_child(m_row)

	slider_mob_mass = HSlider.new()
	slider_mob_mass.min_value = 0.00
	slider_mob_mass.max_value = 1.20
	slider_mob_mass.step = 0.01
	slider_mob_mass.value = current_mass
	slider_mob_mass.custom_minimum_size = Vector2(0, 38) # Big touch target!
	slider_mob_mass.value_changed.connect(_on_mass_slider_changed)
	mobile_tab_controls.add_child(slider_mob_mass)

	var mob_toggles := HBoxContainer.new()
	mob_toggles.add_theme_constant_override("separation", 8)
	var btn_m_beam := Button.new()
	btn_m_beam.text = "Upper Beam"
	btn_m_beam.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_m_beam.custom_minimum_size = Vector2(0, 36)
	btn_m_beam.pressed.connect(_on_beam_toggle_pressed)
	mob_toggles.add_child(btn_m_beam)

	var btn_m_fric := Button.new()
	btn_m_fric.text = "Friction ON"
	btn_m_fric.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_m_fric.custom_minimum_size = Vector2(0, 36)
	btn_m_fric.pressed.connect(_on_friction_toggle_pressed)
	mob_toggles.add_child(btn_m_fric)
	mobile_tab_controls.add_child(mob_toggles)

	# Tab 1: Graph (Placeholder container to re-parent or toggle)
	mobile_tab_graph = VBoxContainer.new()
	mobile_tab_graph.size_flags_vertical = Control.SIZE_EXPAND_FILL
	mobile_tab_graph.visible = false
	mob_bot_vbox.add_child(mobile_tab_graph)


# -----------------------------------------------------------------------------
# LOGIC & EVENT HANDLERS
# -----------------------------------------------------------------------------

func _connect_events() -> void:
	_update_rig_buttons()


func _on_rig_button_pressed(r_id: String) -> void:
	current_rig_id = r_id
	_update_rig_buttons()
	rig_selection_changed.emit(current_rig_id)
	if live_graph != null:
		var filter_idx: int = 0
		match r_id:
			"A": filter_idx = 1
			"C": filter_idx = 2
			"B": filter_idx = 3
			_: filter_idx = 0
		live_graph.set_active_rig_filter(filter_idx)


func _update_rig_buttons() -> void:
	for id in rig_buttons.keys():
		var btn: Button = rig_buttons[id]
		var is_active: bool = (id == current_rig_id)
		btn.add_theme_stylebox_override("normal", ThemeManager.create_button_style(is_dark_theme, is_active))
		btn.add_theme_stylebox_override("hover", ThemeManager.create_button_style(is_dark_theme, is_active, true))
		btn.add_theme_stylebox_override("pressed", ThemeManager.create_button_style(is_dark_theme, true))
		if is_dark_theme:
			btn.add_theme_color_override("font_color", ThemeManager.DARK_TEXT_PRIMARY)
		else:
			btn.add_theme_color_override("font_color", Color.WHITE if is_active else ThemeManager.LIGHT_TEXT_PRIMARY)


func _adjust_mass(delta_m: float) -> void:
	var next_m: float = clampf(current_mass + delta_m, 0.00, 1.20)
	if slider_mass != null:
		slider_mass.value = next_m
	if slider_mob_mass != null:
		slider_mob_mass.value = next_m


func set_mass(val: float) -> void:
	current_mass = clampf(val, 0.00, 1.20)
	if slider_mass != null and not is_equal_approx(slider_mass.value, current_mass):
		slider_mass.set_value_no_signal(current_mass)
	if slider_mob_mass != null and not is_equal_approx(slider_mob_mass.value, current_mass):
		slider_mob_mass.set_value_no_signal(current_mass)
	var text_fmt: String = "%.2f kg" % current_mass
	if lbl_mass_val != null:
		lbl_mass_val.text = text_fmt
	if lbl_mob_mass_val != null:
		lbl_mob_mass_val.text = text_fmt


func _on_mass_slider_changed(val: float) -> void:
	current_mass = val
	var text_fmt: String = "%.2f kg" % current_mass
	if lbl_mass_val != null:
		lbl_mass_val.text = text_fmt
	if lbl_mob_mass_val != null:
		lbl_mob_mass_val.text = text_fmt
	if live_graph != null:
		live_graph.set_mass(current_mass)
	mass_changed.emit(current_mass)


func _on_beam_toggle_pressed() -> void:
	is_upper_beam = not is_upper_beam
	var text_str: String = "MODE: UPPER BEAM" if is_upper_beam else "MODE: PIN REACTION"
	if btn_beam_toggle != null:
		btn_beam_toggle.text = text_str
	beam_reaction_toggled.emit(is_upper_beam)


func _on_friction_toggle_pressed() -> void:
	is_stiction_on = not is_stiction_on
	var text_str: String = "FRICTION: ON (mu=0.20)" if is_stiction_on else "FRICTION: OFF (IDEAL)"
	if btn_friction_toggle != null:
		btn_friction_toggle.text = text_str
	stiction_toggled.emit(is_stiction_on)
	if live_graph != null:
		live_graph.set_stiction_enabled(is_stiction_on)


func _on_slow_mo_pressed() -> void:
	is_slow_mo = not is_slow_mo
	if btn_slow_mo != null:
		btn_slow_mo.text = "1.0x NORMAL" if is_slow_mo else "0.2x SLOW-MO"
	slow_mo_toggled.emit(is_slow_mo)


func _on_theme_pressed() -> void:
	is_dark_theme = not is_dark_theme
	if btn_theme != null:
		btn_theme.text = "THEME: DARK" if is_dark_theme else "THEME: LIGHT"
	apply_theme(is_dark_theme)
	theme_toggled.emit(is_dark_theme)
	if live_graph != null:
		live_graph.dark_theme = is_dark_theme
		live_graph.queue_redraw()


func _switch_mobile_tab(tab_idx: int) -> void:
	if tab_idx == 0:
		mobile_tab_controls.visible = true
		mobile_tab_graph.visible = false
		btn_mob_tab_ctrl.add_theme_stylebox_override("normal", ThemeManager.create_button_style(is_dark_theme, true))
		btn_mob_tab_graph.add_theme_stylebox_override("normal", ThemeManager.create_button_style(is_dark_theme, false))
	else:
		mobile_tab_controls.visible = false
		mobile_tab_graph.visible = true
		btn_mob_tab_ctrl.add_theme_stylebox_override("normal", ThemeManager.create_button_style(is_dark_theme, false))
		btn_mob_tab_graph.add_theme_stylebox_override("normal", ThemeManager.create_button_style(is_dark_theme, true))


# -----------------------------------------------------------------------------
# RESPONSIVE ADAPTATION & FREE VIEWPORT RECT CALCULATION
# -----------------------------------------------------------------------------

## Returns the exact unobstructed screen Rect2 available for the 3D mechanism
func get_free_viewport_rect() -> Rect2:
	var vp_size: Vector2 = root_control.get_viewport_rect().size
	var aspect: float = vp_size.x / maxf(vp_size.y, 1.0)
	if aspect >= 1.1:
		# Desktop: Left 60% width, under 54px header
		var top_h: float = 54.0 + 8.0
		var free_w: float = vp_size.x * 0.60
		var free_h: float = maxf(vp_size.y - top_h - 12.0, 100.0)
		return Rect2(16.0, top_h, free_w, free_h)
	else:
		# Mobile: Central ~52% height
		var top_h: float = 96.0 + 4.0
		var bot_h: float = 220.0 + 10.0
		var free_w: float = vp_size.x
		var free_h: float = maxf(vp_size.y - top_h - bot_h, 100.0)
		return Rect2(0.0, top_h, free_w, free_h)


func update_responsive_layout(vp_size: Vector2) -> void:
	var aspect: float = vp_size.x / maxf(vp_size.y, 1.0)
	var is_mobile: bool = (aspect < 1.1)

	desktop_container.visible = not is_mobile
	mobile_container.visible = is_mobile

	# Move live graph into active container if on mobile tab 1
	if is_mobile:
		if live_graph.get_parent() != mobile_tab_graph and mobile_tab_graph.visible:
			live_graph.reparent(mobile_tab_graph)
	else:
		if live_graph.get_parent() != graph_card.get_child(0):
			live_graph.reparent(graph_card.get_child(0))


## Updates live telemetry metrics
func update_telemetry(h_cm: float, l_cm: float, r_n: float, fx_n: float, fy_n: float, fric_n: float) -> void:
	if tile_val_h != null: tile_val_h.text = "%.1f cm" % h_cm
	if tile_val_l != null: tile_val_l.text = "%.1f cm" % l_cm
	if tile_val_r != null: tile_val_r.text = "%.2f N" % r_n
	if tile_val_fx != null: tile_val_fx.text = "%.2f N" % fx_n
	if tile_val_fy != null: tile_val_fy.text = "%.2f N" % fy_n
	if tile_val_fric != null: tile_val_fric.text = "%.2f N" % fric_n

	if lbl_mob_telem_row != null:
		lbl_mob_telem_row.text = "H: %.1fcm · L: %.1fcm · R: %.2fN · fric: %.2fN" % [h_cm, l_cm, r_n, fric_n]


# -----------------------------------------------------------------------------
# CONTROL CARD TABS & DETAILED PARAMETERS
# -----------------------------------------------------------------------------

func _build_control_card_tabs(ctrl_vbox: VBoxContainer) -> void:
	# Header of Control Card
	var card_header := HBoxContainer.new()
	card_title = Label.new()
	card_title.text = "MISSION CONTROL & PARAMETERS"
	card_title.add_theme_font_size_override("font_size", 12)
	card_header.add_child(card_title)
	ctrl_vbox.add_child(card_header)

	# 1. Segmented Sub-Tabs Bar
	var tab_bar := HBoxContainer.new()
	tab_bar.add_theme_constant_override("separation", 4)
	ctrl_vbox.add_child(tab_bar)

	param_tab_buttons.clear()
	param_panels.clear()
	all_param_tag_labels.clear()
	all_param_val_labels.clear()
	all_param_preset_buttons.clear()

	var tab_titles := ["MASS (m)", "FRICTION (μ)", "STIFFNESS (k)", "GRAVITY (g)", "TIME / SPEED"]
	for i in range(tab_titles.size()):
		var btn := Button.new()
		btn.text = tab_titles[i]
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size = Vector2(0, 26)
		btn.add_theme_font_size_override("font_size", 10)
		var t_idx: int = i
		btn.pressed.connect(func(): _switch_param_tab(t_idx))
		tab_bar.add_child(btn)
		param_tab_buttons.append(btn)

	# 2. Panels Container
	var panels_box := VBoxContainer.new()
	panels_box.add_theme_constant_override("separation", 6)
	ctrl_vbox.add_child(panels_box)

	# --- TAB 0: MASS (m) ---
	var p_mass := VBoxContainer.new()
	p_mass.add_theme_constant_override("separation", 6)
	panels_box.add_child(p_mass)
	param_panels.append(p_mass)

	var mass_row := HBoxContainer.new()
	mass_row.add_theme_constant_override("separation", 8)

	lbl_m_tag = Label.new()
	lbl_m_tag.text = "SUSPENDED MASS (m):"
	lbl_m_tag.add_theme_font_size_override("font_size", 11)
	mass_row.add_child(lbl_m_tag)
	all_param_tag_labels.append(lbl_m_tag)

	lbl_mass_val = Label.new()
	lbl_mass_val.text = "0.50 kg"
	lbl_mass_val.add_theme_font_size_override("font_size", 14)
	mass_row.add_child(lbl_mass_val)
	all_param_val_labels.append(lbl_mass_val)

	var mass_sp := Control.new()
	mass_sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mass_row.add_child(mass_sp)

	btn_mass_dec = Button.new()
	btn_mass_dec.text = "−0.05"
	btn_mass_dec.custom_minimum_size = Vector2(46, 24)
	btn_mass_dec.add_theme_font_size_override("font_size", 10)
	btn_mass_dec.pressed.connect(func(): _adjust_mass(-0.05))
	mass_row.add_child(btn_mass_dec)
	all_param_preset_buttons.append(btn_mass_dec)

	btn_mass_inc = Button.new()
	btn_mass_inc.text = "+0.05"
	btn_mass_inc.custom_minimum_size = Vector2(46, 24)
	btn_mass_inc.add_theme_font_size_override("font_size", 10)
	btn_mass_inc.pressed.connect(func(): _adjust_mass(0.05))
	mass_row.add_child(btn_mass_inc)
	all_param_preset_buttons.append(btn_mass_inc)
	p_mass.add_child(mass_row)

	slider_mass = HSlider.new()
	slider_mass.min_value = 0.00
	slider_mass.max_value = 1.50
	slider_mass.step = 0.01
	slider_mass.value = current_mass
	slider_mass.value_changed.connect(_on_mass_slider_changed)
	p_mass.add_child(slider_mass)

	var mass_presets_row := HBoxContainer.new()
	mass_presets_row.add_theme_constant_override("separation", 4)
	for m_val in [0.10, 0.25, 0.50, 0.75, 1.00, 1.20]:
		var pbtn := Button.new()
		pbtn.text = "%.2f kg" % m_val
		pbtn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		pbtn.custom_minimum_size = Vector2(0, 24)
		pbtn.add_theme_font_size_override("font_size", 9)
		pbtn.pressed.connect(func(): slider_mass.value = m_val)
		mass_presets_row.add_child(pbtn)
		all_param_preset_buttons.append(pbtn)
	p_mass.add_child(mass_presets_row)

	# --- TAB 1: FRICTION (μ) ---
	var p_fric := VBoxContainer.new()
	p_fric.add_theme_constant_override("separation", 6)
	p_fric.visible = false
	panels_box.add_child(p_fric)
	param_panels.append(p_fric)

	var fric_row := HBoxContainer.new()
	lbl_fric_tag = Label.new()
	lbl_fric_tag.text = "JOINT PIN FRICTION (μ):"
	lbl_fric_tag.add_theme_font_size_override("font_size", 11)
	fric_row.add_child(lbl_fric_tag)
	all_param_tag_labels.append(lbl_fric_tag)

	lbl_fric_val = Label.new()
	lbl_fric_val.text = "0.20"
	lbl_fric_val.add_theme_font_size_override("font_size", 14)
	fric_row.add_child(lbl_fric_val)
	all_param_val_labels.append(lbl_fric_val)
	p_fric.add_child(fric_row)

	slider_friction = HSlider.new()
	slider_friction.min_value = 0.00
	slider_friction.max_value = 0.50
	slider_friction.step = 0.01
	slider_friction.value = current_friction
	slider_friction.value_changed.connect(_on_friction_slider_changed)
	p_fric.add_child(slider_friction)

	var fric_presets := HBoxContainer.new()
	fric_presets.add_theme_constant_override("separation", 4)
	var f_cfgs := [
		{"label": "Zero (0.0)", "val": 0.00},
		{"label": "Steel (0.08)", "val": 0.08},
		{"label": "PTFE (0.15)", "val": 0.15},
		{"label": "PLA (0.35)", "val": 0.35}
	]
	for cfg in f_cfgs:
		var fbtn := Button.new()
		fbtn.text = cfg["label"]
		fbtn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		fbtn.custom_minimum_size = Vector2(0, 24)
		fbtn.add_theme_font_size_override("font_size", 9)
		var f_val: float = cfg["val"]
		fbtn.pressed.connect(func(): slider_friction.value = f_val)
		fric_presets.add_child(fbtn)
		all_param_preset_buttons.append(fbtn)
	p_fric.add_child(fric_presets)

	var fric_toggles := HBoxContainer.new()
	fric_toggles.add_theme_constant_override("separation", 6)

	btn_friction_toggle = Button.new()
	btn_friction_toggle.text = "STATIC FRICTION (fs): ON"
	btn_friction_toggle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_friction_toggle.custom_minimum_size = Vector2(0, 26)
	btn_friction_toggle.add_theme_font_size_override("font_size", 10)
	btn_friction_toggle.pressed.connect(_on_friction_toggle_pressed)
	fric_toggles.add_child(btn_friction_toggle)
	all_param_preset_buttons.append(btn_friction_toggle)

	btn_beam_toggle = Button.new()
	btn_beam_toggle.text = "MODE: UPPER BEAM"
	btn_beam_toggle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_beam_toggle.custom_minimum_size = Vector2(0, 26)
	btn_beam_toggle.add_theme_font_size_override("font_size", 10)
	btn_beam_toggle.pressed.connect(_on_beam_toggle_pressed)
	fric_toggles.add_child(btn_beam_toggle)
	all_param_preset_buttons.append(btn_beam_toggle)
	p_fric.add_child(fric_toggles)

	# --- TAB 2: STIFFNESS & EFFICIENCY (k, η) ---
	var p_stiff := VBoxContainer.new()
	p_stiff.add_theme_constant_override("separation", 6)
	p_stiff.visible = false
	panels_box.add_child(p_stiff)
	param_panels.append(p_stiff)

	var k_row := HBoxContainer.new()
	lbl_k_tag = Label.new()
	lbl_k_tag.text = "SPRING STIFFNESS (k):"
	lbl_k_tag.add_theme_font_size_override("font_size", 11)
	k_row.add_child(lbl_k_tag)
	all_param_tag_labels.append(lbl_k_tag)

	lbl_k_val = Label.new()
	lbl_k_val.text = "981 N/m"
	lbl_k_val.add_theme_font_size_override("font_size", 14)
	k_row.add_child(lbl_k_val)
	all_param_val_labels.append(lbl_k_val)
	p_stiff.add_child(k_row)

	slider_stiffness = HSlider.new()
	slider_stiffness.min_value = 500.0
	slider_stiffness.max_value = 2500.0
	slider_stiffness.step = 10.0
	slider_stiffness.value = current_stiffness
	slider_stiffness.value_changed.connect(_on_stiffness_slider_changed)
	p_stiff.add_child(slider_stiffness)

	var k_presets := HBoxContainer.new()
	k_presets.add_theme_constant_override("separation", 4)
	var k_cfgs := [
		{"label": "Rig A (981)", "val": 981.0},
		{"label": "Rig B (1090)", "val": 1090.0},
		{"label": "Stiff (1500)", "val": 1500.0},
		{"label": "Heavy (2000)", "val": 2000.0}
	]
	for cfg in k_cfgs:
		var kbtn := Button.new()
		kbtn.text = cfg["label"]
		kbtn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		kbtn.custom_minimum_size = Vector2(0, 24)
		kbtn.add_theme_font_size_override("font_size", 9)
		var kval: float = cfg["val"]
		kbtn.pressed.connect(func(): slider_stiffness.value = kval)
		k_presets.add_child(kbtn)
		all_param_preset_buttons.append(kbtn)
	p_stiff.add_child(k_presets)

	var eta_row := HBoxContainer.new()
	lbl_eta_tag = Label.new()
	lbl_eta_tag.text = "EFFICIENCY (η):"
	lbl_eta_tag.add_theme_font_size_override("font_size", 11)
	eta_row.add_child(lbl_eta_tag)
	all_param_tag_labels.append(lbl_eta_tag)

	lbl_eta_val = Label.new()
	lbl_eta_val.text = "94%"
	lbl_eta_val.add_theme_font_size_override("font_size", 14)
	eta_row.add_child(lbl_eta_val)
	all_param_val_labels.append(lbl_eta_val)
	p_stiff.add_child(eta_row)

	slider_efficiency = HSlider.new()
	slider_efficiency.min_value = 70.0
	slider_efficiency.max_value = 100.0
	slider_efficiency.step = 1.0
	slider_efficiency.value = current_efficiency * 100.0
	slider_efficiency.value_changed.connect(_on_efficiency_slider_changed)
	p_stiff.add_child(slider_efficiency)

	# --- TAB 3: GRAVITY (g) ---
	var p_grav := VBoxContainer.new()
	p_grav.add_theme_constant_override("separation", 6)
	p_grav.visible = false
	panels_box.add_child(p_grav)
	param_panels.append(p_grav)

	var g_row := HBoxContainer.new()
	lbl_g_tag = Label.new()
	lbl_g_tag.text = "GRAVITATIONAL FIELD (g):"
	lbl_g_tag.add_theme_font_size_override("font_size", 11)
	g_row.add_child(lbl_g_tag)
	all_param_tag_labels.append(lbl_g_tag)

	lbl_g_val = Label.new()
	lbl_g_val.text = "9.81 m/s² (Earth)"
	lbl_g_val.add_theme_font_size_override("font_size", 14)
	g_row.add_child(lbl_g_val)
	all_param_val_labels.append(lbl_g_val)
	p_grav.add_child(g_row)

	slider_gravity = HSlider.new()
	slider_gravity.min_value = 0.00
	slider_gravity.max_value = 25.00
	slider_gravity.step = 0.05
	slider_gravity.value = current_gravity
	slider_gravity.value_changed.connect(_on_gravity_slider_changed)
	p_grav.add_child(slider_gravity)

	var g_presets := HBoxContainer.new()
	g_presets.add_theme_constant_override("separation", 4)
	var g_cfgs := [
		{"label": "Zero-G (0.0)", "val": 0.00},
		{"label": "Moon (1.62)", "val": 1.62},
		{"label": "Mars (3.71)", "val": 3.71},
		{"label": "Earth (9.81)", "val": 9.81},
		{"label": "Jupiter (24.8)", "val": 24.79}
	]
	for cfg in g_cfgs:
		var gbtn := Button.new()
		gbtn.text = cfg["label"]
		gbtn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		gbtn.custom_minimum_size = Vector2(0, 24)
		gbtn.add_theme_font_size_override("font_size", 9)
		var gval: float = cfg["val"]
		gbtn.pressed.connect(func(): slider_gravity.value = gval)
		g_presets.add_child(gbtn)
		all_param_preset_buttons.append(gbtn)
	p_grav.add_child(g_presets)

	# --- TAB 4: TIME / SPEED & SLOW-MO ---
	var p_time := VBoxContainer.new()
	p_time.add_theme_constant_override("separation", 6)
	p_time.visible = false
	panels_box.add_child(p_time)
	param_panels.append(p_time)

	var speed_row := HBoxContainer.new()
	lbl_speed_tag = Label.new()
	lbl_speed_tag.text = "SIMULATION SPEED:"
	lbl_speed_tag.add_theme_font_size_override("font_size", 11)
	speed_row.add_child(lbl_speed_tag)
	all_param_tag_labels.append(lbl_speed_tag)

	lbl_speed_val = Label.new()
	lbl_speed_val.text = "1.00x NORMAL"
	lbl_speed_val.add_theme_font_size_override("font_size", 14)
	speed_row.add_child(lbl_speed_val)
	all_param_val_labels.append(lbl_speed_val)
	p_time.add_child(speed_row)

	slider_sim_speed = HSlider.new()
	slider_sim_speed.min_value = 0.05
	slider_sim_speed.max_value = 2.00
	slider_sim_speed.step = 0.05
	slider_sim_speed.value = current_sim_speed
	slider_sim_speed.value_changed.connect(_on_sim_speed_slider_changed)
	p_time.add_child(slider_sim_speed)

	var time_presets := HBoxContainer.new()
	time_presets.add_theme_constant_override("separation", 4)

	btn_play_pause = Button.new()
	btn_play_pause.text = "⏸ PAUSE"
	btn_play_pause.custom_minimum_size = Vector2(80, 26)
	btn_play_pause.add_theme_font_size_override("font_size", 10)
	btn_play_pause.pressed.connect(_on_play_pause_pressed)
	time_presets.add_child(btn_play_pause)
	all_param_preset_buttons.append(btn_play_pause)

	var spd_cfgs := [
		{"label": "0.05x Ultra", "val": 0.05},
		{"label": "0.20x Slow", "val": 0.20},
		{"label": "0.50x Half", "val": 0.50},
		{"label": "1.00x Normal", "val": 1.00}
	]
	for cfg in spd_cfgs:
		var sbtn := Button.new()
		sbtn.text = cfg["label"]
		sbtn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		sbtn.custom_minimum_size = Vector2(0, 26)
		sbtn.add_theme_font_size_override("font_size", 9)
		var sval: float = cfg["val"]
		sbtn.pressed.connect(func(): slider_sim_speed.value = sval)
		time_presets.add_child(sbtn)
		all_param_preset_buttons.append(sbtn)
	p_time.add_child(time_presets)

	var action_row := HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 6)

	btn_jolt = Button.new()
	btn_jolt.text = "⚡ JOLT IMPULSE (+0.1 m/s)"
	btn_jolt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_jolt.custom_minimum_size = Vector2(0, 26)
	btn_jolt.add_theme_font_size_override("font_size", 10)
	btn_jolt.pressed.connect(_on_jolt_pressed)
	action_row.add_child(btn_jolt)
	all_param_preset_buttons.append(btn_jolt)

	btn_deselect_pin = Button.new()
	btn_deselect_pin.text = "✕ HIDE 3D VECTORS"
	btn_deselect_pin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_deselect_pin.custom_minimum_size = Vector2(0, 26)
	btn_deselect_pin.add_theme_font_size_override("font_size", 10)
	btn_deselect_pin.pressed.connect(_on_deselect_pin_pressed)
	action_row.add_child(btn_deselect_pin)
	all_param_preset_buttons.append(btn_deselect_pin)
	p_time.add_child(action_row)

	# 3. 3x2 Telemetry Metric Grid (Always pinned below active parameters)
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)

	tile_val_h = _create_metric_tile(grid, "H (TIER EXT)", "7.5 cm")
	tile_val_l = _create_metric_tile(grid, "L (TOTAL EXT)", "22.5 cm")
	tile_val_r = _create_metric_tile(grid, "R (RESULTANT)", "3.36 N", ThemeManager.COLOR_VECTOR_R_DARK)
	tile_val_fx = _create_metric_tile(grid, "Fx (LATERAL)", "2.16 N", ThemeManager.COLOR_VECTOR_FX_DARK)
	tile_val_fy = _create_metric_tile(grid, "Fy (VERTICAL)", "2.57 N", ThemeManager.COLOR_VECTOR_FY_DARK)
	tile_val_fric = _create_metric_tile(grid, "fs / fk (FRICTION)", "0.67 N", ThemeManager.COLOR_VECTOR_FRIC_DARK)
	ctrl_vbox.add_child(grid)


func _switch_param_tab(idx: int) -> void:
	current_param_tab = idx
	for i in range(param_panels.size()):
		param_panels[i].visible = (i == idx)
	_update_param_tab_buttons()


func _update_param_tab_buttons() -> void:
	for i in range(param_tab_buttons.size()):
		var b := param_tab_buttons[i]
		var is_act := (i == current_param_tab)
		b.add_theme_stylebox_override("normal", ThemeManager.create_button_style(is_dark_theme, is_act, false, 4))
		b.add_theme_stylebox_override("hover", ThemeManager.create_button_style(is_dark_theme, is_act, true, 4))
		b.add_theme_stylebox_override("pressed", ThemeManager.create_button_style(is_dark_theme, true, false, 4))
		var tc: Color
		if is_dark_theme:
			tc = ThemeManager.DARK_ACCENT_CYAN if is_act else ThemeManager.DARK_TEXT_PRIMARY
		else:
			tc = Color.WHITE if is_act else ThemeManager.LIGHT_TEXT_PRIMARY
		b.add_theme_color_override("font_color", tc)
		b.add_theme_color_override("font_hover_color", tc)
		b.add_theme_color_override("font_pressed_color", tc)
		b.add_theme_color_override("font_focus_color", tc)


func _on_stiffness_slider_changed(val: float) -> void:
	current_stiffness = val
	if lbl_k_val:
		lbl_k_val.text = "%d N/m" % int(val)
	stiffness_changed.emit(val)


func _on_efficiency_slider_changed(val: float) -> void:
	current_efficiency = val / 100.0
	if lbl_eta_val:
		lbl_eta_val.text = "%d%%" % int(val)
	efficiency_changed.emit(val)


func _on_friction_slider_changed(val: float) -> void:
	current_friction = val
	if lbl_fric_val:
		lbl_fric_val.text = "0.00 (Zero)" if is_equal_approx(val, 0.0) else "%.2f" % val
	if btn_friction_toggle != null:
		btn_friction_toggle.text = "STATIC FRICTION: ON" if is_stiction_on else "STATIC FRICTION: OFF"
	friction_changed.emit(val)


func _on_gravity_slider_changed(val: float) -> void:
	current_gravity = val
	var desc := ""
	if is_equal_approx(val, 0.0): desc = " (Zero-G)"
	elif absf(val - 1.62) < 0.2: desc = " (Moon)"
	elif absf(val - 3.71) < 0.2: desc = " (Mars)"
	elif absf(val - 9.81) < 0.2: desc = " (Earth)"
	elif absf(val - 24.79) < 0.5: desc = " (Jupiter)"
	if lbl_g_val:
		lbl_g_val.text = "%.2f m/s²%s" % [val, desc]
	gravity_changed.emit(val)


func _on_sim_speed_slider_changed(val: float) -> void:
	current_sim_speed = val
	if lbl_speed_val:
		var mode := " [PAUSED]" if is_sim_paused else ""
		lbl_speed_val.text = "%.2fx%s" % [val, mode]
	sim_speed_changed.emit(val)


func _on_play_pause_pressed() -> void:
	is_sim_paused = not is_sim_paused
	if btn_play_pause:
		btn_play_pause.text = "▶ RESUME" if is_sim_paused else "⏸ PAUSE"
	if lbl_speed_val:
		var mode := " [PAUSED]" if is_sim_paused else ""
		lbl_speed_val.text = "%.2fx%s" % [current_sim_speed, mode]
	sim_pause_toggled.emit(is_sim_paused)


func _on_jolt_pressed() -> void:
	jolt_requested.emit()


func _on_deselect_pin_pressed() -> void:
	deselect_pin_requested.emit()


## Applies theme tokens to all cards and buttons
func apply_theme(is_dark: bool) -> void:
	is_dark_theme = is_dark

	# 1. Cards with SpaceX Top Accent Line (corner_radius = 4)
	var card_sb := ThemeManager.create_card_style(is_dark, 4, 14, true)
	if top_bar != null: top_bar.add_theme_stylebox_override("panel", ThemeManager.create_card_style(is_dark, 0, 8, false))
	if control_card != null: control_card.add_theme_stylebox_override("panel", card_sb)
	if graph_card != null: graph_card.add_theme_stylebox_override("panel", card_sb)
	if mobile_top_bar != null: mobile_top_bar.add_theme_stylebox_override("panel", ThemeManager.create_card_style(is_dark, 0, 8, false))
	if mobile_bottom_sheet != null: mobile_bottom_sheet.add_theme_stylebox_override("panel", ThemeManager.create_card_style(is_dark, 4, 12, true))
	if formulas_modal != null: formulas_modal.add_theme_stylebox_override("panel", ThemeManager.create_card_style(is_dark, 4, 18, true))

	# 2. Main Brand Labels & Card Headers
	var brand_c := ThemeManager.DARK_ACCENT_CYAN if is_dark else ThemeManager.LIGHT_ACCENT_COBALT
	var primary_c := ThemeManager.DARK_TEXT_PRIMARY if is_dark else ThemeManager.LIGHT_TEXT_PRIMARY
	var muted_c := ThemeManager.DARK_TEXT_MUTED if is_dark else ThemeManager.LIGHT_TEXT_MUTED

	if lbl_title != null: lbl_title.add_theme_color_override("font_color", brand_c)
	if lbl_sub != null: lbl_sub.add_theme_color_override("font_color", muted_c)
	if card_title != null: card_title.add_theme_color_override("font_color", primary_c)
	if lbl_mob_telem_row != null: lbl_mob_telem_row.add_theme_color_override("font_color", brand_c)

	# 3. Parameter Tag Labels and Value Labels
	for lbl in all_param_tag_labels:
		if lbl != null:
			lbl.add_theme_color_override("font_color", muted_c)
	for lbl in all_param_val_labels:
		if lbl != null:
			lbl.add_theme_color_override("font_color", brand_c)

	# 4. Action Buttons
	if btn_theme != null:
		btn_theme.text = "THEME: DARK" if is_dark else "THEME: LIGHT"

	var normal_btn_sb := ThemeManager.create_button_style(is_dark, false, false, 4)
	var hover_btn_sb := ThemeManager.create_button_style(is_dark, false, true, 4)
	var active_btn_sb := ThemeManager.create_button_style(is_dark, true, false, 4)

	var all_buttons := [
		btn_slow_mo, btn_theme, btn_formulas, btn_reset_view,
		btn_mass_dec, btn_mass_inc, btn_beam_toggle, btn_friction_toggle,
		btn_play_pause, btn_jolt, btn_deselect_pin,
		btn_mob_slow, btn_mob_th, btn_mob_form
	]
	all_buttons.append_array(all_param_preset_buttons)

	for btn in all_buttons:
		if btn != null:
			btn.add_theme_stylebox_override("normal", normal_btn_sb)
			btn.add_theme_stylebox_override("hover", hover_btn_sb)
			btn.add_theme_stylebox_override("pressed", active_btn_sb)
			btn.add_theme_stylebox_override("focus", normal_btn_sb)
			btn.add_theme_color_override("font_color", primary_c)
			btn.add_theme_color_override("font_hover_color", primary_c)
			btn.add_theme_color_override("font_pressed_color", Color.WHITE if not is_dark else ThemeManager.DARK_ACCENT_CYAN)
			btn.add_theme_color_override("font_focus_color", primary_c)

	_update_param_tab_buttons()

	# 5. Sliders
	for sl in [slider_mass, slider_stiffness, slider_efficiency, slider_friction, slider_gravity, slider_sim_speed]:
		if sl != null:
			ThemeManager.apply_slider_style(sl, is_dark, 20)
	if slider_mob_mass != null:
		ThemeManager.apply_slider_style(slider_mob_mass, is_dark, 30)

	# 6. Metric Grid Tiles Style & Colors
	var tile_sb := ThemeManager.create_metric_tile_style(is_dark, 4)
	for t in metric_tiles:
		if t != null:
			t.add_theme_stylebox_override("panel", tile_sb)

	for lbl in metric_tag_labels:
		if lbl != null:
			lbl.add_theme_font_size_override("font_size", 11)
			lbl.add_theme_color_override("font_color", muted_c)

	for item in metric_num_labels:
		var lbl: Label = item["label"]
		var acc: Color = item["accent"]
		if lbl != null:
			lbl.add_theme_font_size_override("font_size", 20)
			if acc != Color.WHITE:
				if not is_dark:
					if acc == ThemeManager.COLOR_VECTOR_R_DARK: acc = ThemeManager.COLOR_VECTOR_R_LIGHT
					elif acc == ThemeManager.COLOR_VECTOR_FX_DARK: acc = ThemeManager.COLOR_VECTOR_FX_LIGHT
					elif acc == ThemeManager.COLOR_VECTOR_FY_DARK: acc = ThemeManager.COLOR_VECTOR_FY_LIGHT
					elif acc == ThemeManager.COLOR_VECTOR_FRIC_DARK: acc = ThemeManager.COLOR_VECTOR_FRIC_LIGHT
				lbl.add_theme_color_override("font_color", acc)
			else:
				lbl.add_theme_color_override("font_color", primary_c)

	_update_rig_buttons()
	_update_formulas_text()


# -----------------------------------------------------------------------------
# FORMULAS & THEORETICAL DERIVATION MODAL
# -----------------------------------------------------------------------------

func _build_formulas_modal() -> void:
	formulas_layer = CanvasLayer.new()
	formulas_layer.name = "FormulasLayer"
	formulas_layer.layer = 100
	formulas_layer.visible = false
	add_child(formulas_layer)

	# Fullscreen backdrop scrim
	formulas_backdrop = ColorRect.new()
	formulas_backdrop.name = "BackdropScrim"
	formulas_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	formulas_backdrop.color = Color(0.0, 0.0, 0.0, 0.65)
	formulas_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	formulas_backdrop.gui_input.connect(func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.pressed:
			close_formulas_modal()
	)
	formulas_layer.add_child(formulas_backdrop)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	formulas_layer.add_child(center)

	formulas_modal = PanelContainer.new()
	formulas_modal.name = "FormulasModalCard"
	formulas_modal.custom_minimum_size = Vector2(820, 580)
	formulas_modal.mouse_filter = Control.MOUSE_FILTER_STOP
	center.add_child(formulas_modal)

	var modal_margin := MarginContainer.new()
	modal_margin.add_theme_constant_override("margin_left", 22)
	modal_margin.add_theme_constant_override("margin_right", 22)
	modal_margin.add_theme_constant_override("margin_top", 16)
	modal_margin.add_theme_constant_override("margin_bottom", 18)
	formulas_modal.add_child(modal_margin)

	var modal_vbox := VBoxContainer.new()
	modal_vbox.add_theme_constant_override("separation", 10)
	modal_margin.add_child(modal_vbox)

	# Header Bar
	var header := HBoxContainer.new()
	header.alignment = BoxContainer.ALIGNMENT_CENTER

	var head_vbox := VBoxContainer.new()
	head_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head_vbox.add_theme_constant_override("separation", 2)

	var title_lbl := Label.new()
	title_lbl.name = "ModalTitle"
	title_lbl.text = "PANTOGRAPH LAB // MATHEMATICAL & PHYSICAL FORMULATION"
	title_lbl.add_theme_font_size_override("font_size", 13)
	title_lbl.add_theme_color_override("font_color", ThemeManager.DARK_ACCENT_CYAN)
	head_vbox.add_child(title_lbl)

	var sub_lbl := Label.new()
	sub_lbl.name = "ModalSub"
	sub_lbl.text = "Golden Rule of Mechanics · Newtonian Pin Statics · Coulomb Friction · Symplectic Solver"
	sub_lbl.add_theme_font_size_override("font_size", 9)
	sub_lbl.add_theme_color_override("font_color", ThemeManager.DARK_TEXT_MUTED)
	head_vbox.add_child(sub_lbl)
	header.add_child(head_vbox)

	var btn_close := Button.new()
	btn_close.name = "ModalCloseBtn"
	btn_close.text = "[ X CLOSE ]"
	btn_close.custom_minimum_size = Vector2(90, 32)
	btn_close.add_theme_font_size_override("font_size", 11)
	btn_close.pressed.connect(close_formulas_modal)
	header.add_child(btn_close)
	modal_vbox.add_child(header)

	var sep := HSeparator.new()
	modal_vbox.add_child(sep)

	# Scrollable Content
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	modal_vbox.add_child(scroll)

	var rtl := RichTextLabel.new()
	rtl.name = "FormulasRTL"
	rtl.bbcode_enabled = true
	rtl.fit_content = true
	rtl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rtl.mouse_filter = Control.MOUSE_FILTER_PASS
	scroll.add_child(rtl)

	_update_formulas_text()


func _update_formulas_text() -> void:
	if formulas_modal == null:
		return
	var rtl: RichTextLabel = formulas_modal.find_child("FormulasRTL", true, false) as RichTextLabel
	if rtl == null:
		return

	var is_dark := is_dark_theme
	var c_head := "#00D2FF" if is_dark else "#0284C7"
	var c_subhead := "#38BDF8" if is_dark else "#1E40AF"
	var c_text := "#F0F6FC" if is_dark else "#0F172A"
	var c_math := "#E2E8F0" if is_dark else "#0F172A"
	var c_box_bg := "#111722" if is_dark else "#F1F5F9"
	var c_muted := "#8B949E" if is_dark else "#475569"

	rtl.add_theme_color_override("default_color", Color(c_text))

	var title_lbl: Label = formulas_modal.find_child("ModalTitle", true, false) as Label
	if title_lbl != null:
		title_lbl.add_theme_color_override("font_color", Color(c_head))
	var sub_lbl: Label = formulas_modal.find_child("ModalSub", true, false) as Label
	if sub_lbl != null:
		sub_lbl.add_theme_color_override("font_color", Color(c_muted))
	var btn_close: Button = formulas_modal.find_child("ModalCloseBtn", true, false) as Button
	if btn_close != null:
		btn_close.add_theme_stylebox_override("normal", ThemeManager.create_button_style(is_dark, false, false, 4))
		btn_close.add_theme_stylebox_override("hover", ThemeManager.create_button_style(is_dark, false, true, 4))
		btn_close.add_theme_stylebox_override("pressed", ThemeManager.create_button_style(is_dark, true, false, 4))
		btn_close.add_theme_color_override("font_color", Color(c_text))

	var f := ""
	f += "[color=" + c_head + "][font_size=15][b]1. GOLDEN RULE OF MECHANICS (Золотое правило механики)[/b][/font_size][/color]\n"
	f += "[color=" + c_text + "]A scissor pantograph operates on the fundamental kinematic transmission ratio λ between input stage extension [b]H[/b] and overall suspended displacement [b]L[/b]:[/color]\n\n"
	
	f += "[indent][bgcolor=" + c_box_bg + "][color=" + c_math + "][font_size=13]"
	f += "    ┌──────────────────────────────────────────────────────────────┐\n"
	f += "    │   L(m) = n · H(m)        ⟹        λ ≡ δL / δH = n        (1.1)   │\n"
	f += "    │   δW_out = η · δW_in     ⟹        T = (λ · P_eff) / η    (1.2)   │\n"
	f += "    └──────────────────────────────────────────────────────────────┘"
	f += "[/font_size][/color][/bgcolor][/indent]\n\n"

	f += "[color=" + c_text + "]• [color=#2B88D8][b]Rig A (uniform n = 3):[/b][/color]   L = 3 · H   (λ = 3.000×, Blue Linkage)\n"
	f += "• [color=#F59E0B][b]Rig B (uniform n = 5):[/b][/color]   L = 5 · H   (λ = 5.000×, Orange Linkage)\n"
	f += "• [color=#10B981][b]Rig C (scaled 1:2:3):[/b][/color]  L = (1 + 2 + 3) · H₀ = 6 · H₀   (λ = 6.000×, Green Linkage)[/color]\n\n"
	f += "[color=" + c_muted + "]\"What is gained in displacement is strictly lost in required tension force.\" (Galileo Galilei)[/color]\n\n"

	f += "[color=" + c_head + "][font_size=15][b]2. LINKAGE FORCE STATICS & PIN REACTIONS (Баланс сил в стержнях)[/b][/font_size][/color]\n"
	f += "[color=" + c_text + "]At any scissor rhombus joint pin inclined at angle θ relative to the horizontal, supporting load P_k:[/color]\n\n"

	f += "[indent][bgcolor=" + c_box_bg + "][color=" + c_math + "][font_size=13]"
	f += "    ┌──────────────────────────────────────────────────────────────┐\n"
	f += "    │   Fy = P_k / 2                                        (2.1)   │\n"
	f += "    │   Fx = P_k / (2 · tan θ)                              (2.2)   │\n"
	f += "    │   R  = √(Fx² + Fy²) = P_k / (2 · sin θ)               (2.3)   │\n"
	f += "    │   R_upper = -R_lower       [Newton's 3rd Law]         (2.4)   │\n"
	f += "    └──────────────────────────────────────────────────────────────┘"
	f += "[/font_size][/color][/bgcolor][/indent]\n\n"

	f += "[color=" + c_muted + "]Note: At shallow scissor angles (θ → 0), lateral thrust Fx surges asymptotically, multiplying pin compressive stress.[/color]\n\n"

	f += "[color=" + c_head + "][font_size=15][b]3. COULOMB DRY FRICTION & STICK-SLIP HYSTERESIS (Сухое трение Кулона)[/b][/font_size][/color]\n"
	f += "[color=" + c_text + "]Joint pin dry friction introduces non-linear stiction and dissipative damping in the linkage:[/color]\n\n"

	f += "[indent][bgcolor=" + c_box_bg + "][color=" + c_math + "][font_size=13]"
	f += "    ┌──────────────────────────────────────────────────────────────┐\n"
	f += "    │   f_k = μ_k · R · (-sign(v_H))    [Kinetic Damping]   (3.1)   │\n"
	f += "    │   |f_s| ≤ μ_s · R                 [Static Stiction]   (3.2)   │\n"
	f += "    │   |P_eff - (k · H / λ)| ≤ f_s · λ [Stick Deadband]    (3.3)   │\n"
	f += "    └──────────────────────────────────────────────────────────────┘"
	f += "[/font_size][/color][/bgcolor][/indent]\n\n"

	f += "[color=" + c_muted + "]This static stiction holds the mechanism inside an equilibrium deadband, creating discrete stick-slip steps on the L(m) curve.[/color]\n\n"

	f += "[color=" + c_head + "][font_size=15][b]4. STIFFNESS REGRESSION & REFLECTED INERTIA (Регрессия и инерция n²M)[/b][/font_size][/color]\n"
	f += "[color=" + c_text + "]The suspended mass M produces an equivalent reflected inertia amplified quadratically by the kinematic ratio:[/color]\n\n"

	f += "[indent][bgcolor=" + c_box_bg + "][color=" + c_math + "][font_size=13]"
	f += "    ┌──────────────────────────────────────────────────────────────┐\n"
	f += "    │   M_eff = n² · M                                      (4.1)   │\n"
	f += "    │   d²H/dt² + 2ζω · (dH/dt) + ω² · (H - H_target) = 0   (4.2)   │\n"
	f += "    │   ω = √(k_eff / M_eff) = √((k / n²) / M)              (4.3)   │\n"
	f += "    │   k = (λ · g) / tan(α)    [Slope Extraction]          (4.4)   │\n"
	f += "    └──────────────────────────────────────────────────────────────┘"
	f += "[/font_size][/color][/bgcolor][/indent]\n"

	rtl.text = f


func open_formulas_modal() -> void:
	if formulas_layer != null:
		formulas_layer.visible = true
		if formulas_modal != null:
			formulas_modal.add_theme_stylebox_override("panel", ThemeManager.create_card_style(is_dark_theme, 4, 18, true))
		_update_formulas_text()
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.openFormulasModal && window.openFormulasModal(" + ("true" if is_dark_theme else "false") + ");")


func close_formulas_modal() -> void:
	if formulas_layer != null:
		formulas_layer.visible = false
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.closeFormulasModal && window.closeFormulasModal();")
