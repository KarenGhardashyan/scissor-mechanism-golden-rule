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

# State
var is_dark_theme: bool = true
var is_slow_mo: bool = false
var is_upper_beam: bool = true
var is_stiction_on: bool = true
var current_rig_id: String = "ALL"
var current_mass: float = 0.50

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

# Desktop Controls
var lbl_mass_val: Label
var slider_mass: HSlider
var btn_mass_dec: Button
var btn_mass_inc: Button
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
var slider_mob_mass: HSlider
var lbl_mob_mass_val: Label
var lbl_mob_telem_row: Label


func _ready() -> void:
	layer = 10
	_build_ui_hierarchy()
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

	var lbl_title := Label.new()
	lbl_title.text = "PANTOGRAPH LAB // GOLDEN RULE"
	lbl_title.add_theme_font_size_override("font_size", 13)
	lbl_title.add_theme_color_override("font_color", ThemeManager.DARK_ACCENT_CYAN)
	brand_box.add_child(lbl_title)

	var lbl_sub := Label.new()
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
	btn_slow_mo.text = "⏱ 0.2× Slow-Mo"
	btn_slow_mo.custom_minimum_size = Vector2(110, 34)
	btn_slow_mo.add_theme_font_size_override("font_size", 11)
	btn_slow_mo.pressed.connect(_on_slow_mo_pressed)
	top_hbox.add_child(btn_slow_mo)

	btn_theme = Button.new()
	btn_theme.text = "🌗 Dark / Light"
	btn_theme.custom_minimum_size = Vector2(105, 34)
	btn_theme.add_theme_font_size_override("font_size", 11)
	btn_theme.pressed.connect(_on_theme_pressed)
	top_hbox.add_child(btn_theme)

	btn_formulas = Button.new()
	btn_formulas.text = "ℹ Formulas"
	btn_formulas.custom_minimum_size = Vector2(90, 34)
	btn_formulas.add_theme_font_size_override("font_size", 11)
	btn_formulas.pressed.connect(func(): formulas_requested.emit())
	top_hbox.add_child(btn_formulas)

	btn_reset_view = Button.new()
	btn_reset_view.text = "↺ Reset"
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

	# Header of Control Card
	var card_header := HBoxContainer.new()
	var card_title := Label.new()
	card_title.text = "CONTROL & TELEMETRY MATRIX"
	card_title.add_theme_font_size_override("font_size", 12)
	card_header.add_child(card_title)
	ctrl_vbox.add_child(card_header)

	# Mass Control Row
	var mass_row := HBoxContainer.new()
	mass_row.add_theme_constant_override("separation", 8)

	var lbl_m_tag := Label.new()
	lbl_m_tag.text = "SUSPENDED MASS (m):"
	lbl_m_tag.add_theme_font_size_override("font_size", 11)
	lbl_m_tag.add_theme_color_override("font_color", ThemeManager.DARK_TEXT_MUTED)
	mass_row.add_child(lbl_m_tag)

	lbl_mass_val = Label.new()
	lbl_mass_val.text = "0.50 kg"
	lbl_mass_val.add_theme_font_size_override("font_size", 15)
	lbl_mass_val.add_theme_color_override("font_color", ThemeManager.DARK_ACCENT_CYAN)
	mass_row.add_child(lbl_mass_val)

	var mass_spacer := Control.new()
	mass_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mass_row.add_child(mass_spacer)

	btn_mass_dec = Button.new()
	btn_mass_dec.text = "−0.05"
	btn_mass_dec.custom_minimum_size = Vector2(50, 28)
	btn_mass_dec.add_theme_font_size_override("font_size", 10)
	btn_mass_dec.pressed.connect(func(): _adjust_mass(-0.05))
	mass_row.add_child(btn_mass_dec)

	btn_mass_inc = Button.new()
	btn_mass_inc.text = "+0.05"
	btn_mass_inc.custom_minimum_size = Vector2(50, 28)
	btn_mass_inc.add_theme_font_size_override("font_size", 10)
	btn_mass_inc.pressed.connect(func(): _adjust_mass(0.05))
	mass_row.add_child(btn_mass_inc)
	ctrl_vbox.add_child(mass_row)

	# Mass Slider
	slider_mass = HSlider.new()
	slider_mass.min_value = 0.00
	slider_mass.max_value = 1.20
	slider_mass.step = 0.01
	slider_mass.value = current_mass
	slider_mass.value_changed.connect(_on_mass_slider_changed)
	ctrl_vbox.add_child(slider_mass)

	# Toggles Row (Beam Mode & Friction)
	var toggles_row := HBoxContainer.new()
	toggles_row.add_theme_constant_override("separation", 8)

	btn_beam_toggle = Button.new()
	btn_beam_toggle.text = "Upper Beam (Reaction ↗)"
	btn_beam_toggle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_beam_toggle.custom_minimum_size = Vector2(0, 30)
	btn_beam_toggle.add_theme_font_size_override("font_size", 10)
	btn_beam_toggle.pressed.connect(_on_beam_toggle_pressed)
	toggles_row.add_child(btn_beam_toggle)

	btn_friction_toggle = Button.new()
	btn_friction_toggle.text = "Dry Friction: ON (μ=0.20)"
	btn_friction_toggle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_friction_toggle.custom_minimum_size = Vector2(0, 30)
	btn_friction_toggle.add_theme_font_size_override("font_size", 10)
	btn_friction_toggle.pressed.connect(_on_friction_toggle_pressed)
	toggles_row.add_child(btn_friction_toggle)
	ctrl_vbox.add_child(toggles_row)

	# 3x2 Telemetry Metric Grid
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


func _create_metric_tile(parent: GridContainer, label_text: String, init_val: String, accent_col: Color = Color.WHITE) -> Label:
	var tile := PanelContainer.new()
	tile.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tile.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	tile.add_child(vbox)

	var lbl_tag := Label.new()
	lbl_tag.text = label_text
	lbl_tag.add_theme_font_size_override("font_size", 8)
	lbl_tag.add_theme_color_override("font_color", ThemeManager.DARK_TEXT_MUTED)
	vbox.add_child(lbl_tag)

	var lbl_num := Label.new()
	lbl_num.text = init_val
	lbl_num.add_theme_font_size_override("font_size", 13)
	if accent_col != Color.WHITE:
		lbl_num.add_theme_color_override("font_color", accent_col)
	else:
		lbl_num.add_theme_color_override("font_color", ThemeManager.DARK_TEXT_PRIMARY)
	vbox.add_child(lbl_num)

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

	var btn_mob_slow := Button.new()
	btn_mob_slow.text = "⏱"
	btn_mob_slow.custom_minimum_size = Vector2(36, 28)
	btn_mob_slow.pressed.connect(_on_slow_mo_pressed)
	mob_telem_row.add_child(btn_mob_slow)

	var btn_mob_th := Button.new()
	btn_mob_th.text = "🌗"
	btn_mob_th.custom_minimum_size = Vector2(36, 28)
	btn_mob_th.pressed.connect(_on_theme_pressed)
	mob_telem_row.add_child(btn_mob_th)
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


func _adjust_mass(delta_m: float) -> void:
	var next_m: float = clampf(current_mass + delta_m, 0.00, 1.20)
	if slider_mass != null:
		slider_mass.value = next_m
	if slider_mob_mass != null:
		slider_mob_mass.value = next_m


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
	var text_str: String = "Upper Beam (Reaction ↗)" if is_upper_beam else "Pin Reaction (ΣF=0 ↙)"
	if btn_beam_toggle != null:
		btn_beam_toggle.text = text_str
	beam_reaction_toggled.emit(is_upper_beam)


func _on_friction_toggle_pressed() -> void:
	is_stiction_on = not is_stiction_on
	var text_str: String = "Dry Friction: ON (μ=0.20)" if is_stiction_on else "Dry Friction: OFF (Ideal)"
	if btn_friction_toggle != null:
		btn_friction_toggle.text = text_str
	stiction_toggled.emit(is_stiction_on)
	if live_graph != null:
		live_graph.set_stiction_enabled(is_stiction_on)


func _on_slow_mo_pressed() -> void:
	is_slow_mo = not is_slow_mo
	if btn_slow_mo != null:
		btn_slow_mo.text = "⏱ 1.0× Normal" if is_slow_mo else "⏱ 0.2× Slow-Mo"
	slow_mo_toggled.emit(is_slow_mo)


func _on_theme_pressed() -> void:
	is_dark_theme = not is_dark_theme
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


## Applies theme tokens to all cards and buttons
func apply_theme(is_dark: bool) -> void:
	is_dark_theme = is_dark

	# 1. Cards
	var card_sb := ThemeManager.create_card_style(is_dark, 10, 14)
	if top_bar != null: top_bar.add_theme_stylebox_override("panel", ThemeManager.create_card_style(is_dark, 0, 8))
	if control_card != null: control_card.add_theme_stylebox_override("panel", card_sb)
	if graph_card != null: graph_card.add_theme_stylebox_override("panel", card_sb)
	if mobile_top_bar != null: mobile_top_bar.add_theme_stylebox_override("panel", ThemeManager.create_card_style(is_dark, 0, 8))
	if mobile_bottom_sheet != null: mobile_bottom_sheet.add_theme_stylebox_override("panel", ThemeManager.create_card_style(is_dark, 12, 12))

	# 2. Buttons
	var normal_btn_sb := ThemeManager.create_button_style(is_dark, false)
	var active_btn_sb := ThemeManager.create_button_style(is_dark, true)
	for btn in [btn_slow_mo, btn_theme, btn_formulas, btn_reset_view, btn_mass_dec, btn_mass_inc, btn_beam_toggle, btn_friction_toggle]:
		if btn != null:
			btn.add_theme_stylebox_override("normal", normal_btn_sb)
			btn.add_theme_stylebox_override("hover", ThemeManager.create_button_style(is_dark, false, true))
			btn.add_theme_stylebox_override("pressed", active_btn_sb)
			var text_c := ThemeManager.DARK_TEXT_PRIMARY if is_dark else ThemeManager.LIGHT_TEXT_PRIMARY
			btn.add_theme_color_override("font_color", text_c)

	# 3. Sliders
	if slider_mass != null: ThemeManager.apply_slider_style(slider_mass, is_dark, 22)
	if slider_mob_mass != null: ThemeManager.apply_slider_style(slider_mob_mass, is_dark, 30)

	_update_rig_buttons()
