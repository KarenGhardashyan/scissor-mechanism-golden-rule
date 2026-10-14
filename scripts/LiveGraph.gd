class_name LiveGraph
extends Control

## Apple "Light Liquid Glass" Live Realtime 2D Plot for L(m)
## High-Contrast Laboratory Oscilloscope Visualizer:
## - Rig A: L_A(m) = 3 · H(m)  (λ = 3.0×, Electric Tech-Blue)
## - Rig C: L_C(m) = 6 · H0(m) (λ = 6.0×, Emerald Green 1:2:3 Variable Scissor)
## - Rig B: L_B(m) = 5 · H(m)  (λ = 5.0×, Ultra Orange)
## Features dual-theme rendering (Dark Obsidian Lab / Light Studio), glowing strokes,
## fluid lerp-smoothed mass scrubbing, zero-allocation WebGL draw buffers, and VisionOS HUD pills.

signal mass_scrubbed(new_mass: float)

# Physical parameters (synchronized with Pantograph rigs)
@export var current_mass: float = 0.5
@export var spring_k: float = 1000.0
@export var efficiency_eta: float = 1.0
@export var link_mass: float = 0.05
@export var physical_link_length: float = 0.06 # 6.0 cm
@export var physical_resting_H: float = 0.075  # 7.5 cm
@export var gravity: float = 9.81

# Plot ranges
@export var mass_min: float = 0.0
@export var mass_max: float = 1.5
@export var l_min: float = 0.0  # cm
@export var l_max: float = 75.0 # cm

# UI Theme Mode (Dark Obsidian Canvas is default for maximum contrast)
@export var dark_theme: bool = true

# Margins inside the canvas card
var margin_left: float = 54.0
var margin_right: float = 24.0
var margin_top: float = 38.0
var margin_bottom: float = 32.0

# Interactive mouse drag & smooth lerp scrub state
var is_dragging: bool = false
var display_mass: float = 0.5

# Design Colors (Apple VisionOS Palette)
const COLOR_RIG_A := Color(0.0, 0.47, 0.95)       # Apple Electric Tech-Blue (#0077F0)
const COLOR_RIG_C := Color(0.19, 0.84, 0.38)      # Apple Emerald Green (#30D661)
const COLOR_RIG_B := Color(1.0, 0.44, 0.06)       # Apple Ultra Orange (#FF7010)
const COLOR_OBSIDIAN := Color(0.08, 0.09, 0.12, 0.96)

# Cached Zero-Allocation StyleBoxes for WebGL / WASM GC Prevention
var _style_card: StyleBoxFlat
var _style_badge: StyleBoxFlat
var _style_tooltip: StyleBoxFlat

# Pre-allocated Reusable Vector Arrays for WebGL Performance
const NUM_SAMPLES: int = 60
var _pts_a: PackedVector2Array = PackedVector2Array()
var _pts_c: PackedVector2Array = PackedVector2Array()
var _pts_b: PackedVector2Array = PackedVector2Array()
var _poly_a: PackedVector2Array = PackedVector2Array()
var _poly_c: PackedVector2Array = PackedVector2Array()
var _poly_b: PackedVector2Array = PackedVector2Array()
var _marker_tri: PackedVector2Array = PackedVector2Array()


func _ready() -> void:
	custom_minimum_size = Vector2(720, 160)
	mouse_filter = Control.MOUSE_FILTER_STOP
	display_mass = current_mass

	# Pre-allocate StyleBoxes once to eliminate per-frame GC allocations
	_style_card = StyleBoxFlat.new()
	_style_card.border_width_left = 1
	_style_card.border_width_top = 1
	_style_card.border_width_right = 1
	_style_card.border_width_bottom = 1
	_style_card.corner_radius_top_left = 14
	_style_card.corner_radius_top_right = 14
	_style_card.corner_radius_bottom_left = 14
	_style_card.corner_radius_bottom_right = 14
	_style_card.shadow_size = 8
	_style_card.shadow_offset = Vector2(0, 3)

	_style_badge = StyleBoxFlat.new()
	_style_badge.border_width_left = 1
	_style_badge.border_width_top = 1
	_style_badge.border_width_right = 1
	_style_badge.border_width_bottom = 1
	_style_badge.corner_radius_top_left = 5
	_style_badge.corner_radius_top_right = 5
	_style_badge.corner_radius_bottom_left = 5
	_style_badge.corner_radius_bottom_right = 5

	_style_tooltip = StyleBoxFlat.new()
	_style_tooltip.bg_color = COLOR_OBSIDIAN
	_style_tooltip.border_width_left = 1
	_style_tooltip.border_width_top = 1
	_style_tooltip.border_width_right = 1
	_style_tooltip.border_width_bottom = 1
	_style_tooltip.corner_radius_top_left = 5
	_style_tooltip.corner_radius_top_right = 5
	_style_tooltip.corner_radius_bottom_left = 5
	_style_tooltip.corner_radius_bottom_right = 5
	_style_tooltip.shadow_color = Color(0.0, 0.0, 0.0, 0.30)
	_style_tooltip.shadow_size = 5
	_style_tooltip.shadow_offset = Vector2(0, 2)

	_pts_a.resize(NUM_SAMPLES + 1)
	_pts_c.resize(NUM_SAMPLES + 1)
	_pts_b.resize(NUM_SAMPLES + 1)
	_poly_a.resize(NUM_SAMPLES + 3)
	_poly_c.resize(NUM_SAMPLES + 3)
	_poly_b.resize(NUM_SAMPLES + 3)
	_marker_tri.resize(3)


func _process(delta: float) -> void:
	if not is_equal_approx(display_mass, current_mass):
		var blend: float = 1.0 - exp(-24.0 * delta)
		display_mass = lerpf(display_mass, current_mass, blend)
		if absf(display_mass - current_mass) < 0.0005:
			display_mass = current_mass
		queue_redraw()


func toggle_theme() -> void:
	dark_theme = not dark_theme
	queue_redraw()


func set_mass(val: float) -> void:
	var clamped_val: float = clampf(val, mass_min, mass_max)
	if not is_equal_approx(current_mass, clamped_val):
		current_mass = clamped_val
		queue_redraw()


func set_stiffness(val: float) -> void:
	if not is_equal_approx(spring_k, val):
		spring_k = maxf(val, 100.0)
		queue_redraw()


func set_efficiency(val: float) -> void:
	if not is_equal_approx(efficiency_eta, val):
		efficiency_eta = clampf(val, 0.50, 1.00)
		queue_redraw()


func set_gravity(val: float) -> void:
	if not is_equal_approx(gravity, val):
		gravity = clampf(val, 0.0, 25.0)
		queue_redraw()


func set_link_mass(val: float) -> void:
	if not is_equal_approx(link_mass, val):
		link_mass = maxf(val, 0.0)
		queue_redraw()


## Theoretical extension for uniform pantographs: L = n * H
func compute_L_cm(m: float, n: int) -> float:
	var p_eff: float = m * gravity + (float(n) * link_mass * gravity) * 0.5
	var eta_safe: float = clampf(efficiency_eta, 0.50, 1.00)
	var tension: float = (float(n) * p_eff) / eta_safe
	var delta_h: float = tension / spring_k
	var max_h: float = physical_link_length * 2.0 * 0.96
	var h: float = clampf(physical_resting_H + delta_h, 0.035, max_h)
	return float(n) * h * 100.0


## Theoretical extension for Rig C (1:2:3 variable-pitch pantograph): L = 6 * H0
func compute_L_c_cm(m: float) -> float:
	var base_l: float = physical_link_length * 0.75
	var base_h_rest: float = physical_resting_H * 0.75
	var p_eff: float = m * gravity + (3.0 * link_mass * gravity)
	var eta_safe: float = clampf(efficiency_eta, 0.50, 1.00)
	var tension: float = (6.0 * p_eff) / eta_safe
	var delta_h: float = tension / spring_k
	var max_h: float = base_l * 2.0 * 0.96
	var h: float = clampf(base_h_rest + delta_h, 0.030, max_h)
	return 6.0 * h * 100.0


# UI Scale Factor for Mobile Responsive Rendering
var ui_scale: float = 1.0


func set_ui_scale(s: float) -> void:
	ui_scale = clampf(s, 1.0, 4.5)
	margin_left = 54.0 * ui_scale
	margin_right = 24.0 * ui_scale
	margin_top = 42.0 * ui_scale
	margin_bottom = 36.0 * ui_scale
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				var local_x: float = mb.position.x
				if local_x >= margin_left - 24.0 * ui_scale and local_x <= size.x - margin_right + 24.0 * ui_scale:
					is_dragging = true
					_scrub_mass_at_x(local_x)
			else:
				is_dragging = false
	elif event is InputEventMouseMotion:
		var mm := event as InputEventMouseMotion
		if is_dragging:
			_scrub_mass_at_x(mm.position.x)
	elif event is InputEventScreenTouch:
		var st := event as InputEventScreenTouch
		if st.pressed:
			var local_x: float = st.position.x
			if local_x >= margin_left - 24.0 * ui_scale and local_x <= size.x - margin_right + 24.0 * ui_scale:
				is_dragging = true
				_scrub_mass_at_x(local_x)
		else:
			is_dragging = false
	elif event is InputEventScreenDrag:
		var sd := event as InputEventScreenDrag
		if is_dragging:
			_scrub_mass_at_x(sd.position.x)


func _scrub_mass_at_x(x: float) -> void:
	var plot_w: float = maxf(size.x - margin_left - margin_right, 10.0)
	var ratio: float = clampf((x - margin_left) / plot_w, 0.0, 1.0)
	var new_m: float = snappedf(mass_min + ratio * (mass_max - mass_min), 0.01)
	current_mass = new_m
	queue_redraw()
	mass_scrubbed.emit(new_m)


func _draw() -> void:
	var font: Font = ThemeDB.fallback_font
	var plot_w: float = size.x - margin_left - margin_right
	var plot_h: float = size.y - margin_top - margin_bottom
	if plot_w <= 20.0 or plot_h <= 20.0:
		return

	var origin := Vector2(margin_left, margin_top + plot_h)

	# --- COLOR PALETTE DEFINITION ---
	var col_card_bg: Color
	var col_card_border: Color
	var col_text_title: Color
	var col_text_sec: Color
	var col_grid: Color
	var col_grid_axis: Color
	var col_cursor_line: Color

	if dark_theme:
		col_card_bg = Color(0.08, 0.09, 0.12, 0.96)
		col_card_border = Color(0.24, 0.27, 0.35, 0.85)
		col_text_title = Color(0.96, 0.97, 0.99)
		col_text_sec = Color(0.62, 0.65, 0.73)
		col_grid = Color(1.0, 1.0, 1.0, 0.08)
		col_grid_axis = Color(1.0, 1.0, 1.0, 0.38)
		col_cursor_line = Color(0.90, 0.92, 0.98, 0.85)
	else:
		col_card_bg = Color(0.98, 0.985, 1.0, 0.94)
		col_card_border = Color(0.82, 0.84, 0.89, 0.95)
		col_text_title = Color(0.114, 0.114, 0.122)
		col_text_sec = Color(0.40, 0.42, 0.48)
		col_grid = Color(0.18, 0.20, 0.26, 0.10)
		col_grid_axis = Color(0.18, 0.20, 0.26, 0.50)
		col_cursor_line = Color(0.18, 0.20, 0.26, 0.75)

	# --- 1. HIGH-CONTRAST INNER PLOT CARD (ZERO-ALLOCATION) ---
	var card_rect := Rect2(margin_left - 46.0 * ui_scale, margin_top - 30.0 * ui_scale, plot_w + 64.0 * ui_scale, plot_h + 56.0 * ui_scale)
	_style_card.bg_color = col_card_bg
	_style_card.border_color = col_card_border
	_style_card.shadow_color = Color(0.0, 0.0, 0.0, 0.18) if dark_theme else Color(0.0, 0.0, 0.0, 0.06)
	draw_style_box(_style_card, card_rect)

	var sz_title: int = int(11 * ui_scale)
	var sz_hud: int = int(10 * ui_scale)
	var sz_ticks: int = int(9 * ui_scale)

	# --- 2. HEADER TITLE & TELEMETRY HUD PILLS ---
	var title_text := "REALTIME DISPLACEMENT PROFILE: L(m) = λ · H(m)"
	draw_string(font, Vector2(margin_left - 36.0 * ui_scale, margin_top - 12.0 * ui_scale), title_text, HORIZONTAL_ALIGNMENT_LEFT, -1, sz_title, col_text_title)

	# Values evaluated at lerp-smoothed display_mass
	var cur_la: float = compute_L_cm(display_mass, 3)
	var cur_lc: float = compute_L_c_cm(display_mass)
	var cur_lb: float = compute_L_cm(display_mass, 5)

	# Telemetry Readout Badges in Header
	var badge_right_edge: float = margin_left + plot_w + 10.0 * ui_scale
	var pill_h: float = 20.0 * ui_scale
	var pill_y: float = margin_top - pill_h - 4.0 * ui_scale

	# Badge B (Orange)
	var txt_b := "Rig B: %.1f cm (5×)" % cur_lb
	var pill_b_w: float = font.get_string_size(txt_b, HORIZONTAL_ALIGNMENT_LEFT, -1, sz_hud).x + 22.0 * ui_scale
	var pill_b_x: float = badge_right_edge - pill_b_w
	_draw_hud_badge(Vector2(pill_b_x, pill_y), Vector2(pill_b_w, pill_h), txt_b, COLOR_RIG_B, font, sz_hud, dark_theme)

	# Badge C (Green)
	var txt_c := "Rig C: %.1f cm (6×)" % cur_lc
	var pill_c_w: float = font.get_string_size(txt_c, HORIZONTAL_ALIGNMENT_LEFT, -1, sz_hud).x + 22.0 * ui_scale
	var pill_c_x: float = pill_b_x - pill_c_w - 6.0 * ui_scale
	_draw_hud_badge(Vector2(pill_c_x, pill_y), Vector2(pill_c_w, pill_h), txt_c, COLOR_RIG_C, font, sz_hud, dark_theme)

	# Badge A (Blue)
	var txt_a := "Rig A: %.1f cm (3×)" % cur_la
	var pill_a_w: float = font.get_string_size(txt_a, HORIZONTAL_ALIGNMENT_LEFT, -1, sz_hud).x + 22.0 * ui_scale
	var pill_a_x: float = pill_c_x - pill_a_w - 6.0 * ui_scale
	_draw_hud_badge(Vector2(pill_a_x, pill_y), Vector2(pill_a_w, pill_h), txt_a, COLOR_RIG_A, font, sz_hud, dark_theme)

	# Badge Mass
	var txt_m := "m = %.2f kg" % display_mass
	var pill_m_w: float = font.get_string_size(txt_m, HORIZONTAL_ALIGNMENT_LEFT, -1, sz_hud).x + 20.0 * ui_scale
	var pill_m_x: float = pill_a_x - pill_m_w - 6.0 * ui_scale
	_draw_hud_badge(Vector2(pill_m_x, pill_y), Vector2(pill_m_w, pill_h), txt_m, Color(0.70, 0.72, 0.78), font, sz_hud, dark_theme)

	# --- 3. GRID & AXES ---
	var y_steps: int = 5
	for i in range(y_steps + 1):
		var l_val: float = float(i) * (l_max / float(y_steps))
		var frac_y: float = (l_val - l_min) / (l_max - l_min)
		var y_pos: float = origin.y - frac_y * plot_h

		draw_line(Vector2(origin.x, y_pos), Vector2(origin.x + plot_w, y_pos), col_grid, 1.0 * ui_scale)

		var tick_str := "%d cm" % int(l_val)
		var str_w: float = font.get_string_size(tick_str, HORIZONTAL_ALIGNMENT_LEFT, -1, sz_ticks).x
		draw_string(font, Vector2(origin.x - str_w - 8.0 * ui_scale, y_pos + 4.0 * ui_scale), tick_str, HORIZONTAL_ALIGNMENT_LEFT, -1, sz_ticks, col_text_sec)

	draw_string(font, Vector2(origin.x - 38.0 * ui_scale, margin_top - 4.0 * ui_scale), "L (cm)", HORIZONTAL_ALIGNMENT_LEFT, -1, sz_ticks, col_text_title)

	# X-axis Grid Lines
	var x_ticks := [0.0, 0.3, 0.6, 0.9, 1.2, 1.5]
	for m_tick in x_ticks:
		var frac_x: float = (m_tick - mass_min) / (mass_max - mass_min)
		var x_pos: float = origin.x + frac_x * plot_w

		draw_line(Vector2(x_pos, origin.y), Vector2(x_pos, margin_top), col_grid, 1.0 * ui_scale)

		var tick_str := "%.1f kg" % m_tick
		var str_w: float = font.get_string_size(tick_str, HORIZONTAL_ALIGNMENT_LEFT, -1, sz_ticks).x
		draw_string(font, Vector2(x_pos - str_w * 0.5, origin.y + 16.0 * ui_scale), tick_str, HORIZONTAL_ALIGNMENT_LEFT, -1, sz_ticks, col_text_sec)

	var x_title := "Suspended Mass m (kg)  ·  [Click & drag horizontally to scrub mass]"
	var x_title_w: float = font.get_string_size(x_title, HORIZONTAL_ALIGNMENT_LEFT, -1, sz_ticks).x
	draw_string(font, Vector2(origin.x + (plot_w - x_title_w) * 0.5, origin.y + 30.0 * ui_scale), x_title, HORIZONTAL_ALIGNMENT_LEFT, -1, sz_ticks, col_text_sec)

	# Main Axes Lines
	draw_line(Vector2(origin.x, origin.y), Vector2(origin.x + plot_w, origin.y), col_grid_axis, 1.5 * ui_scale)
	draw_line(Vector2(origin.x, origin.y), Vector2(origin.x, margin_top), col_grid_axis, 1.5 * ui_scale)

	# --- 4. THEORETICAL CURVES & AREA GRADIENTS ---
	for i in range(NUM_SAMPLES + 1):
		var t: float = float(i) / float(NUM_SAMPLES)
		var m_samp: float = lerp(mass_min, mass_max, t)
		var x_p: float = origin.x + t * plot_w

		# Rig A (n=3)
		var la_val: float = compute_L_cm(m_samp, 3)
		var la_frac: float = clampf((la_val - l_min) / (l_max - l_min), 0.0, 1.0)
		_pts_a[i] = Vector2(x_p, origin.y - la_frac * plot_h)
		_poly_a[i] = _pts_a[i]

		# Rig C (1:2:3, lambda=6)
		var lc_val: float = compute_L_c_cm(m_samp)
		var lc_frac: float = clampf((lc_val - l_min) / (l_max - l_min), 0.0, 1.0)
		_pts_c[i] = Vector2(x_p, origin.y - lc_frac * plot_h)
		_poly_c[i] = _pts_c[i]

		# Rig B (n=5)
		var lb_val: float = compute_L_cm(m_samp, 5)
		var lb_frac: float = clampf((lb_val - l_min) / (l_max - l_min), 0.0, 1.0)
		_pts_b[i] = Vector2(x_p, origin.y - lb_frac * plot_h)
		_poly_b[i] = _pts_b[i]

	# Close polygon bottoms without reallocating
	_poly_a[NUM_SAMPLES + 1] = Vector2(origin.x + plot_w, origin.y)
	_poly_a[NUM_SAMPLES + 2] = Vector2(origin.x, origin.y)

	_poly_c[NUM_SAMPLES + 1] = Vector2(origin.x + plot_w, origin.y)
	_poly_c[NUM_SAMPLES + 2] = Vector2(origin.x, origin.y)

	_poly_b[NUM_SAMPLES + 1] = Vector2(origin.x + plot_w, origin.y)
	_poly_b[NUM_SAMPLES + 2] = Vector2(origin.x, origin.y)

	# Translucent Area Fill Under Curves
	draw_colored_polygon(_poly_a, Color(COLOR_RIG_A.r, COLOR_RIG_A.g, COLOR_RIG_A.b, 0.06 if dark_theme else 0.04))
	draw_colored_polygon(_poly_c, Color(COLOR_RIG_C.r, COLOR_RIG_C.g, COLOR_RIG_C.b, 0.06 if dark_theme else 0.04))
	draw_colored_polygon(_poly_b, Color(COLOR_RIG_B.r, COLOR_RIG_B.g, COLOR_RIG_B.b, 0.06 if dark_theme else 0.04))

	# Curve Strokes (Glow halo + crisp core)
	draw_polyline(_pts_a, Color(COLOR_RIG_A.r, COLOR_RIG_A.g, COLOR_RIG_A.b, 0.30), 6.5 * ui_scale, true)
	draw_polyline(_pts_a, COLOR_RIG_A, 3.2 * ui_scale, true)

	draw_polyline(_pts_c, Color(COLOR_RIG_C.r, COLOR_RIG_C.g, COLOR_RIG_C.b, 0.30), 6.5 * ui_scale, true)
	draw_polyline(_pts_c, COLOR_RIG_C, 3.2 * ui_scale, true)

	draw_polyline(_pts_b, Color(COLOR_RIG_B.r, COLOR_RIG_B.g, COLOR_RIG_B.b, 0.30), 6.5 * ui_scale, true)
	draw_polyline(_pts_b, COLOR_RIG_B, 3.2 * ui_scale, true)

	# --- 5. DYNAMIC REALTIME MARKERS & PROJECTIONS ---
	var cur_m_frac: float = clampf((display_mass - mass_min) / (mass_max - mass_min), 0.0, 1.0)
	var cursor_x: float = origin.x + cur_m_frac * plot_w

	# Vertical Scanning Guide Line
	draw_line(Vector2(cursor_x, origin.y), Vector2(cursor_x, margin_top), col_cursor_line, 1.4 * ui_scale)

	# Cursor top triangle marker
	_marker_tri[0] = Vector2(cursor_x, margin_top - 4.0 * ui_scale)
	_marker_tri[1] = Vector2(cursor_x - 4.5 * ui_scale, margin_top - 10.0 * ui_scale)
	_marker_tri[2] = Vector2(cursor_x + 4.5 * ui_scale, margin_top - 10.0 * ui_scale)
	draw_colored_polygon(_marker_tri, col_cursor_line)

	var dot_a_pos := Vector2(cursor_x, origin.y - ((cur_la - l_min) / (l_max - l_min)) * plot_h)
	var dot_c_pos := Vector2(cursor_x, origin.y - ((cur_lc - l_min) / (l_max - l_min)) * plot_h)
	var dot_b_pos := Vector2(cursor_x, origin.y - ((cur_lb - l_min) / (l_max - l_min)) * plot_h)

	# Horizontal Projection Dashes from Dots to Y-Axis
	_draw_horizontal_projection(origin.x, cursor_x, dot_a_pos.y, COLOR_RIG_A)
	_draw_horizontal_projection(origin.x, cursor_x, dot_c_pos.y, COLOR_RIG_C)
	_draw_horizontal_projection(origin.x, cursor_x, dot_b_pos.y, COLOR_RIG_B)

	# Dots (Glow halo + solid core + white center pin)
	draw_arc(dot_a_pos, 9.0 * ui_scale, 0.0, TAU, 24, Color(COLOR_RIG_A.r, COLOR_RIG_A.g, COLOR_RIG_A.b, 0.40), 2.8 * ui_scale, true)
	draw_circle(dot_a_pos, 5.0 * ui_scale, COLOR_RIG_A)
	draw_circle(dot_a_pos, 2.0 * ui_scale, Color(1.0, 1.0, 1.0))

	draw_arc(dot_c_pos, 9.0 * ui_scale, 0.0, TAU, 24, Color(COLOR_RIG_C.r, COLOR_RIG_C.g, COLOR_RIG_C.b, 0.40), 2.8 * ui_scale, true)
	draw_circle(dot_c_pos, 5.0 * ui_scale, COLOR_RIG_C)
	draw_circle(dot_c_pos, 2.0 * ui_scale, Color(1.0, 1.0, 1.0))

	draw_arc(dot_b_pos, 9.0 * ui_scale, 0.0, TAU, 24, Color(COLOR_RIG_B.r, COLOR_RIG_B.g, COLOR_RIG_B.b, 0.40), 2.8 * ui_scale, true)
	draw_circle(dot_b_pos, 5.0 * ui_scale, COLOR_RIG_B)
	draw_circle(dot_b_pos, 2.0 * ui_scale, Color(1.0, 1.0, 1.0))

	# --- 6. FLOATING CURSOR TOOLTIPS ---
	var tip_a_text := "Rig A: L = %.1f cm" % cur_la
	var tip_c_text := "Rig C: L = %.1f cm" % cur_lc
	var tip_b_text := "Rig B: L = %.1f cm" % cur_lb

	var font_sz: int = int(10 * ui_scale)
	var sz_a := font.get_string_size(tip_a_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_sz)
	var sz_c := font.get_string_size(tip_c_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_sz)
	var sz_b := font.get_string_size(tip_b_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_sz)

	var max_w: float = maxf(maxf(sz_a.x, sz_c.x), sz_b.x) + 24.0 * ui_scale
	var pill_tip_h: float = 20.0 * ui_scale

	var is_right_side: bool = cursor_x > (origin.x + plot_w - 150.0 * ui_scale)
	var offset_x: float = -(max_w + 14.0 * ui_scale) if is_right_side else 14.0 * ui_scale

	var pill_pos_a := Vector2(cursor_x + offset_x, dot_a_pos.y - pill_tip_h * 0.5)
	var pill_pos_c := Vector2(cursor_x + offset_x, dot_c_pos.y - pill_tip_h * 0.5)
	var pill_pos_b := Vector2(cursor_x + offset_x, dot_b_pos.y - pill_tip_h * 0.5)

	# Avoid vertical overlap between tooltips
	if absf(pill_pos_c.y - pill_pos_b.y) < pill_tip_h + 3.0 * ui_scale:
		pill_pos_b.y = pill_pos_c.y - pill_tip_h - 4.0 * ui_scale
	if absf(pill_pos_a.y - pill_pos_c.y) < pill_tip_h + 3.0 * ui_scale:
		pill_pos_a.y = pill_pos_c.y + pill_tip_h + 4.0 * ui_scale

	_draw_tooltip_pill(pill_pos_a, Vector2(max_w, pill_tip_h), tip_a_text, COLOR_RIG_A, font, font_sz)
	_draw_tooltip_pill(pill_pos_c, Vector2(max_w, pill_tip_h), tip_c_text, COLOR_RIG_C, font, font_sz)
	_draw_tooltip_pill(pill_pos_b, Vector2(max_w, pill_tip_h), tip_b_text, COLOR_RIG_B, font, font_sz)


func _draw_horizontal_projection(start_x: float, end_x: float, y_pos: float, color: Color) -> void:
	var dash_len: float = 4.0
	var gap_len: float = 3.0
	var cur_x: float = start_x
	var col_dash := Color(color.r, color.g, color.b, 0.35)
	while cur_x < end_x:
		var nxt := minf(cur_x + dash_len, end_x)
		draw_line(Vector2(cur_x, y_pos), Vector2(nxt, y_pos), col_dash, 1.0)
		cur_x += (dash_len + gap_len)


func _draw_hud_badge(pos: Vector2, sz: Vector2, text: String, accent_color: Color, font: Font, font_size: int, is_dark: bool) -> void:
	_style_badge.bg_color = Color(0.12, 0.14, 0.18, 0.90) if is_dark else Color(0.92, 0.93, 0.96, 0.95)
	_style_badge.border_color = accent_color
	draw_style_box(_style_badge, Rect2(pos, sz))
	draw_circle(Vector2(pos.x + 8.0, pos.y + sz.y * 0.5), 3.0, accent_color)

	var text_y: float = pos.y + (sz.y - font.get_height(font_size)) * 0.5 + font.get_ascent(font_size)
	var text_pos := Vector2(pos.x + 15.0, text_y)
	var text_color: Color = Color(0.96, 0.97, 0.99) if is_dark else Color(0.12, 0.13, 0.16)
	draw_string(font, text_pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, text_color)


func _draw_tooltip_pill(pos: Vector2, sz: Vector2, text: String, border_color: Color, font: Font, font_size: int) -> void:
	_style_tooltip.border_color = border_color
	draw_style_box(_style_tooltip, Rect2(pos, sz))
	draw_circle(Vector2(pos.x + 8.0, pos.y + sz.y * 0.5), 3.0, border_color)

	var text_y: float = pos.y + (sz.y - font.get_height(font_size)) * 0.5 + font.get_ascent(font_size)
	var text_pos := Vector2(pos.x + 15.0, text_y)
	draw_string(font, text_pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(0.96, 0.97, 0.98))


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()
