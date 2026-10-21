class_name LiveGraph
extends Control

## Apple "Light Liquid Glass" Live Realtime 2D Plot for L(m)
## High-Contrast Laboratory Oscilloscope Visualizer:
## - Rig A: L_A(m) = 3 · H(m)  (λ = 3.0×, Electric Tech-Blue)
## - Rig C: L_C(m) = 6 · H0(m) (λ = 6.0×, Emerald Green 1:2:3 Variable Scissor)
## - Rig B: L_B(m) = 5 · H(m)  (λ = 5.0×, Ultra Orange)
## Features dual-theme rendering (Dark Obsidian Lab / Light Studio), glowing strokes,
## interactive rig filtering with Linear Regression & Coulomb Stiction Deadband envelope,
## fluid lerp-smoothed mass scrubbing, zero-allocation WebGL draw buffers, and VisionOS HUD pills.

signal mass_scrubbed(new_mass: float)
signal rig_filter_changed(rig_index: int)

# Physical parameters (synchronized with Pantograph rigs)
@export var current_mass: float = 0.5
@export var spring_k: float = 1000.0
@export var efficiency_eta: float = 1.0
@export var link_mass: float = 0.05
@export var physical_link_length: float = 0.06 # 6.0 cm
@export var physical_resting_H: float = 0.075  # 7.5 cm
@export var gravity: float = 9.81
@export var friction_mu: float = 0.20
@export var stiction_enabled: bool = true

# Active Rig Isolation Filter: 0 = All Rigs, 1 = Rig A (3×), 2 = Rig C (6×), 3 = Rig B (5×)
@export var active_rig_filter: int = 0

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
var margin_top: float = 68.0
var margin_bottom: float = 34.0

# Interactive mouse drag & smooth lerp scrub state
var is_dragging: bool = false
var display_mass: float = 0.5

# Design Colors (Apple VisionOS Palette)
const COLOR_RIG_A := Color(0.0, 0.47, 0.95)       # Apple Electric Tech-Blue (#0077F0)
const COLOR_RIG_C := Color(0.19, 0.84, 0.38)      # Apple Emerald Green (#30D661)
const COLOR_RIG_B := Color(1.0, 0.44, 0.06)       # Apple Ultra Orange (#FF7010)
const COLOR_REGRESSION := Color(1.0, 0.84, 0.30)  # Amber Gold for Linear Regression (#FFD64D)
const COLOR_OBSIDIAN := Color(0.08, 0.09, 0.12, 0.96)

# Cached Zero-Allocation StyleBoxes for WebGL / WASM GC Prevention
var _style_card: StyleBoxFlat
var _style_badge: StyleBoxFlat
var _style_tooltip: StyleBoxFlat

# Interactive Bounding Rects for HUD Badges
var _rect_badge_all := Rect2()
var _rect_badge_a := Rect2()
var _rect_badge_c := Rect2()
var _rect_badge_b := Rect2()

# Pre-allocated Reusable Vector Arrays for WebGL Performance
const NUM_SAMPLES: int = 60
var _pts_a: PackedVector2Array = PackedVector2Array()
var _pts_c: PackedVector2Array = PackedVector2Array()
var _pts_b: PackedVector2Array = PackedVector2Array()
var _pts_reg: PackedVector2Array = PackedVector2Array()
var _pts_band_top: PackedVector2Array = PackedVector2Array()
var _pts_band_bot: PackedVector2Array = PackedVector2Array()
var _poly_a: PackedVector2Array = PackedVector2Array()
var _poly_c: PackedVector2Array = PackedVector2Array()
var _poly_b: PackedVector2Array = PackedVector2Array()
var _poly_band: PackedVector2Array = PackedVector2Array()
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
	_pts_reg.resize(NUM_SAMPLES + 1)
	_pts_band_top.resize(NUM_SAMPLES + 1)
	_pts_band_bot.resize(NUM_SAMPLES + 1)
	_poly_a.resize(NUM_SAMPLES + 3)
	_poly_c.resize(NUM_SAMPLES + 3)
	_poly_b.resize(NUM_SAMPLES + 3)
	_poly_band.resize((NUM_SAMPLES + 1) * 2)
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


func set_friction_mu(val: float) -> void:
	var clamped_val: float = clampf(val, 0.0, 0.60)
	if not is_equal_approx(friction_mu, clamped_val):
		friction_mu = clamped_val
		queue_redraw()


func set_stiction_enabled(val: bool) -> void:
	if stiction_enabled != val:
		stiction_enabled = val
		queue_redraw()


func set_active_rig_filter(val: int) -> void:
	var clamped_val: int = clampi(val, 0, 3)
	if active_rig_filter != clamped_val:
		active_rig_filter = clamped_val
		rig_filter_changed.emit(active_rig_filter)
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


## Stepped experimental response simulating dry static friction holding at discrete lab loads
func compute_stepped_L_cm(m: float, n: int, is_rig_c: bool = false) -> float:
	var l_ideal: float = compute_L_c_cm(m) if is_rig_c else compute_L_cm(m, n)
	if not stiction_enabled or friction_mu < 0.005:
		return l_ideal
	# Step quantum based on friction coefficient (e.g. ~0.09 kg at mu=0.20)
	var m_quantum: float = clampf((friction_mu / 0.20) * 0.09, 0.035, 0.22)
	var m_step: float = floorf(m / m_quantum) * m_quantum
	return compute_L_c_cm(m_step) if is_rig_c else compute_L_cm(m_step, n)


## Linear regression line evaluated at mass m
func compute_regression_L_cm(m: float, n: int, is_rig_c: bool = false) -> float:
	var l_0: float = compute_L_c_cm(0.0) if is_rig_c else compute_L_cm(0.0, n)
	var l_ref: float = compute_L_c_cm(0.75) if is_rig_c else compute_L_cm(0.75, n)
	var slope: float = (l_ref - l_0) / 0.75
	return l_0 + slope * m


## Stiction deadband width in cm for visual uncertainty envelope
func compute_stiction_deadband_cm(n: int, is_rig_c: bool = false) -> float:
	if not stiction_enabled or friction_mu < 0.005:
		return 0.0
	var eff_n: float = 6.0 if is_rig_c else float(n)
	return (friction_mu / 0.20) * 0.0045 * eff_n * 100.0


# UI Scale Factor for Mobile Responsive Rendering
var ui_scale: float = 1.0


func set_ui_scale(s: float) -> void:
	ui_scale = clampf(s, 1.0, 4.5)
	margin_left = 54.0 * ui_scale
	margin_right = 24.0 * ui_scale
	margin_top = 68.0 * ui_scale
	margin_bottom = 36.0 * ui_scale
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				# Interactive HUD Badge Clicks:
				if _rect_badge_all.has_point(mb.position):
					set_active_rig_filter(0)
					return
				elif _rect_badge_a.has_point(mb.position):
					set_active_rig_filter(0 if active_rig_filter == 1 else 1)
					return
				elif _rect_badge_c.has_point(mb.position):
					set_active_rig_filter(0 if active_rig_filter == 2 else 2)
					return
				elif _rect_badge_b.has_point(mb.position):
					set_active_rig_filter(0 if active_rig_filter == 3 else 3)
					return

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
			if _rect_badge_all.has_point(st.position):
				set_active_rig_filter(0)
				return
			elif _rect_badge_a.has_point(st.position):
				set_active_rig_filter(0 if active_rig_filter == 1 else 1)
				return
			elif _rect_badge_c.has_point(st.position):
				set_active_rig_filter(0 if active_rig_filter == 2 else 2)
				return
			elif _rect_badge_b.has_point(st.position):
				set_active_rig_filter(0 if active_rig_filter == 3 else 3)
				return

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
	var card_rect := Rect2(margin_left - 46.0 * ui_scale, margin_top - 58.0 * ui_scale, plot_w + 64.0 * ui_scale, plot_h + 84.0 * ui_scale)
	_style_card.bg_color = col_card_bg
	_style_card.border_color = col_card_border
	_style_card.shadow_color = Color(0.0, 0.0, 0.0, 0.18) if dark_theme else Color(0.0, 0.0, 0.0, 0.06)
	draw_style_box(_style_card, card_rect)

	var sz_title: int = int(11 * ui_scale)
	var sz_hud: int = int(10 * ui_scale)
	var sz_ticks: int = int(9 * ui_scale)

	# --- 2. HEADER TITLE & INTERACTIVE HUD PILLS ---
	var title_text: String
	if active_rig_filter == 1:
		title_text = "RIG A: REGRESSION (λ = 3.0x)"
	elif active_rig_filter == 2:
		title_text = "RIG C: REGRESSION (λ = 6.0x)"
	elif active_rig_filter == 3:
		title_text = "RIG B: REGRESSION (λ = 5.0x)"
	else:
		if stiction_enabled and friction_mu > 0.005:
			title_text = "PROFILE L(m) [μ=%.2f]" % friction_mu
		else:
			title_text = "PROFILE L(m) [IDEAL]"

	draw_string(font, Vector2(margin_left - 36.0 * ui_scale, margin_top - 36.0 * ui_scale), title_text, HORIZONTAL_ALIGNMENT_LEFT, -1, sz_title, col_text_title)

	# Values evaluated at lerp-smoothed display_mass
	var cur_la: float = compute_stepped_L_cm(display_mass, 3)
	var cur_lc: float = compute_stepped_L_cm(display_mass, 6, true)
	var cur_lb: float = compute_stepped_L_cm(display_mass, 5)

	# Telemetry Readout Badges in Header - aligned rightwards, strictly above top grid line
	var badge_right_edge: float = margin_left + plot_w + 10.0 * ui_scale
	var pill_h: float = 20.0 * ui_scale
	var pill_y: float = margin_top - pill_h - 24.0 * ui_scale

	# Badge B (Orange)
	var txt_b: String = "Rig B: %.1f cm" % cur_lb if (active_rig_filter == 0 or active_rig_filter == 3) else "Rig B"
	var pill_b_w: float = font.get_string_size(txt_b, HORIZONTAL_ALIGNMENT_LEFT, -1, sz_hud).x + 14.0 * ui_scale
	var pill_b_x: float = badge_right_edge - pill_b_w
	_rect_badge_b = Rect2(pill_b_x, pill_y, pill_b_w, pill_h)
	_draw_hud_badge(_rect_badge_b.position, _rect_badge_b.size, txt_b, COLOR_RIG_B, font, sz_hud, dark_theme, active_rig_filter == 3, active_rig_filter != 0 and active_rig_filter != 3)

	# Badge C (Green)
	var txt_c: String = "Rig C: %.1f cm" % cur_lc if (active_rig_filter == 0 or active_rig_filter == 2) else "Rig C"
	var pill_c_w: float = font.get_string_size(txt_c, HORIZONTAL_ALIGNMENT_LEFT, -1, sz_hud).x + 14.0 * ui_scale
	var pill_c_x: float = pill_b_x - pill_c_w - 4.0 * ui_scale
	_rect_badge_c = Rect2(pill_c_x, pill_y, pill_c_w, pill_h)
	_draw_hud_badge(_rect_badge_c.position, _rect_badge_c.size, txt_c, COLOR_RIG_C, font, sz_hud, dark_theme, active_rig_filter == 2, active_rig_filter != 0 and active_rig_filter != 2)

	# Badge A (Blue)
	var txt_a: String = "Rig A: %.1f cm" % cur_la if (active_rig_filter == 0 or active_rig_filter == 1) else "Rig A"
	var pill_a_w: float = font.get_string_size(txt_a, HORIZONTAL_ALIGNMENT_LEFT, -1, sz_hud).x + 14.0 * ui_scale
	var pill_a_x: float = pill_c_x - pill_a_w - 4.0 * ui_scale
	_rect_badge_a = Rect2(pill_a_x, pill_y, pill_a_w, pill_h)
	_draw_hud_badge(_rect_badge_a.position, _rect_badge_a.size, txt_a, COLOR_RIG_A, font, sz_hud, dark_theme, active_rig_filter == 1, active_rig_filter != 0 and active_rig_filter != 1)

	# Badge All Rigs
	var txt_all: String = "All"
	var pill_all_w: float = font.get_string_size(txt_all, HORIZONTAL_ALIGNMENT_LEFT, -1, sz_hud).x + 12.0 * ui_scale
	var pill_all_x: float = pill_a_x - pill_all_w - 4.0 * ui_scale
	_rect_badge_all = Rect2(pill_all_x, pill_y, pill_all_w, pill_h)
	_draw_hud_badge(_rect_badge_all.position, _rect_badge_all.size, txt_all, Color(0.82, 0.85, 0.92), font, sz_hud, dark_theme, active_rig_filter == 0, false)

	# Badge Mass
	var txt_m := "m=%.2f kg" % display_mass
	var pill_m_w: float = font.get_string_size(txt_m, HORIZONTAL_ALIGNMENT_LEFT, -1, sz_hud).x + 14.0 * ui_scale
	var pill_m_x: float = pill_all_x - pill_m_w - 4.0 * ui_scale
	_draw_hud_badge(Vector2(pill_m_x, pill_y), Vector2(pill_m_w, pill_h), txt_m, Color(0.70, 0.72, 0.78), font, sz_hud, dark_theme, false, false)

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

	draw_string(font, Vector2(origin.x - 38.0 * ui_scale, margin_top - 8.0 * ui_scale), "L (cm)", HORIZONTAL_ALIGNMENT_LEFT, -1, sz_ticks, col_text_title)

	# X-axis Grid Lines
	var x_ticks := [0.0, 0.3, 0.6, 0.9, 1.2, 1.5]
	for m_tick in x_ticks:
		var frac_x: float = (m_tick - mass_min) / (mass_max - mass_min)
		var x_pos: float = origin.x + frac_x * plot_w

		draw_line(Vector2(x_pos, origin.y), Vector2(x_pos, margin_top), col_grid, 1.0 * ui_scale)

		var tick_str := "%.1f kg" % m_tick
		var str_w: float = font.get_string_size(tick_str, HORIZONTAL_ALIGNMENT_LEFT, -1, sz_ticks).x
		draw_string(font, Vector2(x_pos - str_w * 0.5, origin.y + 16.0 * ui_scale), tick_str, HORIZONTAL_ALIGNMENT_LEFT, -1, sz_ticks, col_text_sec)

	var x_title := "Suspended Mass m (kg)  ·  [Click Rig badge above to isolate & show Regression | Drag to scrub]"
	var x_title_w: float = font.get_string_size(x_title, HORIZONTAL_ALIGNMENT_LEFT, -1, sz_ticks).x
	draw_string(font, Vector2(origin.x + (plot_w - x_title_w) * 0.5, origin.y + 30.0 * ui_scale), x_title, HORIZONTAL_ALIGNMENT_LEFT, -1, sz_ticks, col_text_sec)

	# Main Axes Lines
	draw_line(Vector2(origin.x, origin.y), Vector2(origin.x + plot_w, origin.y), col_grid_axis, 1.5 * ui_scale)
	draw_line(Vector2(origin.x, origin.y), Vector2(origin.x, margin_top), col_grid_axis, 1.5 * ui_scale)

	# --- 4. CURVES & REGRESSION RENDERING ---
	var cur_m_frac: float = clampf((display_mass - mass_min) / (mass_max - mass_min), 0.0, 1.0)
	var cursor_x: float = origin.x + cur_m_frac * plot_w

	if active_rig_filter == 0:
		# --- MODE A: ALL RIGS COMBINED VIEW ---
		for i in range(NUM_SAMPLES + 1):
			var t: float = float(i) / float(NUM_SAMPLES)
			var m_samp: float = lerp(mass_min, mass_max, t)
			var x_p: float = origin.x + t * plot_w

			# Rig A (n=3)
			var la_val: float = compute_stepped_L_cm(m_samp, 3)
			var la_frac: float = clampf((la_val - l_min) / (l_max - l_min), 0.0, 1.0)
			_pts_a[i] = Vector2(x_p, origin.y - la_frac * plot_h)
			_poly_a[i] = _pts_a[i]

			# Rig C (1:2:3, lambda=6)
			var lc_val: float = compute_stepped_L_cm(m_samp, 6, true)
			var lc_frac: float = clampf((lc_val - l_min) / (l_max - l_min), 0.0, 1.0)
			_pts_c[i] = Vector2(x_p, origin.y - lc_frac * plot_h)
			_poly_c[i] = _pts_c[i]

			# Rig B (n=5)
			var lb_val: float = compute_stepped_L_cm(m_samp, 5)
			var lb_frac: float = clampf((lb_val - l_min) / (l_max - l_min), 0.0, 1.0)
			_pts_b[i] = Vector2(x_p, origin.y - lb_frac * plot_h)
			_poly_b[i] = _pts_b[i]

		# Close polygon bottoms
		_poly_a[NUM_SAMPLES + 1] = Vector2(origin.x + plot_w, origin.y)
		_poly_a[NUM_SAMPLES + 2] = Vector2(origin.x, origin.y)
		_poly_c[NUM_SAMPLES + 1] = Vector2(origin.x + plot_w, origin.y)
		_poly_c[NUM_SAMPLES + 2] = Vector2(origin.x, origin.y)
		_poly_b[NUM_SAMPLES + 1] = Vector2(origin.x + plot_w, origin.y)
		_poly_b[NUM_SAMPLES + 2] = Vector2(origin.x, origin.y)

		# Translucent Area Fill
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

		# Cursor Scan Line
		draw_line(Vector2(cursor_x, origin.y), Vector2(cursor_x, margin_top), col_cursor_line, 1.4 * ui_scale)
		_draw_cursor_marker(cursor_x, col_cursor_line)

		var dot_a_pos := Vector2(cursor_x, origin.y - ((cur_la - l_min) / (l_max - l_min)) * plot_h)
		var dot_c_pos := Vector2(cursor_x, origin.y - ((cur_lc - l_min) / (l_max - l_min)) * plot_h)
		var dot_b_pos := Vector2(cursor_x, origin.y - ((cur_lb - l_min) / (l_max - l_min)) * plot_h)

		_draw_horizontal_projection(origin.x, cursor_x, dot_a_pos.y, COLOR_RIG_A)
		_draw_horizontal_projection(origin.x, cursor_x, dot_c_pos.y, COLOR_RIG_C)
		_draw_horizontal_projection(origin.x, cursor_x, dot_b_pos.y, COLOR_RIG_B)

		_draw_dot(dot_a_pos, COLOR_RIG_A)
		_draw_dot(dot_c_pos, COLOR_RIG_C)
		_draw_dot(dot_b_pos, COLOR_RIG_B)

		# Floating Tooltips
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

		if absf(pill_pos_c.y - pill_pos_b.y) < pill_tip_h + 3.0 * ui_scale:
			pill_pos_b.y = pill_pos_c.y - pill_tip_h - 4.0 * ui_scale
		if absf(pill_pos_a.y - pill_pos_c.y) < pill_tip_h + 3.0 * ui_scale:
			pill_pos_a.y = pill_pos_c.y + pill_tip_h + 4.0 * ui_scale

		_draw_tooltip_pill(pill_pos_a, Vector2(max_w, pill_tip_h), tip_a_text, COLOR_RIG_A, font, font_sz)
		_draw_tooltip_pill(pill_pos_c, Vector2(max_w, pill_tip_h), tip_c_text, COLOR_RIG_C, font, font_sz)
		_draw_tooltip_pill(pill_pos_b, Vector2(max_w, pill_tip_h), tip_b_text, COLOR_RIG_B, font, font_sz)

	else:
		# --- MODE B: FOCUSED RIG WITH EXPERIMENTAL STEPS & LINEAR REGRESSION ---
		var cur_n: int = 3
		var is_c: bool = false
		var rig_color: Color = COLOR_RIG_A
		var rig_tag: String = "Rig A (λ = 3.0×)"

		if active_rig_filter == 2:
			cur_n = 6
			is_c = true
			rig_color = COLOR_RIG_C
			rig_tag = "Rig C (λ = 6.0×)"
		elif active_rig_filter == 3:
			cur_n = 5
			is_c = false
			rig_color = COLOR_RIG_B
			rig_tag = "Rig B (λ = 5.0×)"

		var deadband_cm: float = compute_stiction_deadband_cm(cur_n, is_c)

		for i in range(NUM_SAMPLES + 1):
			var t: float = float(i) / float(NUM_SAMPLES)
			var m_samp: float = lerp(mass_min, mass_max, t)
			var x_p: float = origin.x + t * plot_w

			# 1. Stepped Real Curve (shows Coulomb static friction hold)
			var l_step: float = compute_stepped_L_cm(m_samp, cur_n, is_c)
			var l_step_frac: float = clampf((l_step - l_min) / (l_max - l_min), 0.0, 1.0)
			_pts_a[i] = Vector2(x_p, origin.y - l_step_frac * plot_h)
			_poly_a[i] = _pts_a[i]

			# 2. Linear Regression Line
			var l_reg: float = compute_regression_L_cm(m_samp, cur_n, is_c)
			var l_reg_frac: float = clampf((l_reg - l_min) / (l_max - l_min), 0.0, 1.0)
			_pts_reg[i] = Vector2(x_p, origin.y - l_reg_frac * plot_h)

			# 3. Stiction Deadband Envelope (± Delta L_stiction)
			var l_top_frac: float = clampf((l_reg + deadband_cm - l_min) / (l_max - l_min), 0.0, 1.0)
			var l_bot_frac: float = clampf((l_reg - deadband_cm - l_min) / (l_max - l_min), 0.0, 1.0)
			_pts_band_top[i] = Vector2(x_p, origin.y - l_top_frac * plot_h)
			_pts_band_bot[i] = Vector2(x_p, origin.y - l_bot_frac * plot_h)

		# 1. Draw Stiction Deadband Envelope Area (if friction active)
		if stiction_enabled and deadband_cm > 0.01:
			for i in range(NUM_SAMPLES + 1):
				_poly_band[i] = _pts_band_top[i]
				_poly_band[(NUM_SAMPLES + 1) * 2 - 1 - i] = _pts_band_bot[i]
			draw_colored_polygon(_poly_band, Color(rig_color.r, rig_color.g, rig_color.b, 0.12 if dark_theme else 0.08))

		# 2. Translucent Area Fill Under Stepped Curve
		_poly_a[NUM_SAMPLES + 1] = Vector2(origin.x + plot_w, origin.y)
		_poly_a[NUM_SAMPLES + 2] = Vector2(origin.x, origin.y)
		draw_colored_polygon(_poly_a, Color(rig_color.r, rig_color.g, rig_color.b, 0.08 if dark_theme else 0.05))

		# 3. Draw Dashed Linear Regression Line
		for i in range(NUM_SAMPLES):
			draw_dashed_line(_pts_reg[i], _pts_reg[i + 1], COLOR_REGRESSION, 2.4 * ui_scale, 6.0 * ui_scale)

		# 4. Draw Stepped Experimental Curve Stroke
		draw_polyline(_pts_a, Color(rig_color.r, rig_color.g, rig_color.b, 0.35), 7.0 * ui_scale, true)
		draw_polyline(_pts_a, rig_color, 3.4 * ui_scale, true)

		# 5. Draw Experimental Step Dots along the curve
		if stiction_enabled and friction_mu > 0.005:
			var m_quantum: float = clampf((friction_mu / 0.20) * 0.09, 0.035, 0.22)
			var cur_m_step: float = 0.0
			while cur_m_step <= mass_max:
				var t_step: float = (cur_m_step - mass_min) / (mass_max - mass_min)
				var pt_x: float = origin.x + t_step * plot_w
				var l_val_pt: float = compute_stepped_L_cm(cur_m_step, cur_n, is_c)
				var pt_y: float = origin.y - clampf((l_val_pt - l_min) / (l_max - l_min), 0.0, 1.0) * plot_h
				var dot_center := Vector2(pt_x, pt_y)
				draw_circle(dot_center, 3.6 * ui_scale, rig_color)
				draw_circle(dot_center, 1.8 * ui_scale, Color(1.0, 1.0, 1.0, 0.90))
				cur_m_step += m_quantum

		# Cursor Scan Line
		draw_line(Vector2(cursor_x, origin.y), Vector2(cursor_x, margin_top), col_cursor_line, 1.4 * ui_scale)
		_draw_cursor_marker(cursor_x, col_cursor_line)

		var cur_l_val: float = compute_stepped_L_cm(display_mass, cur_n, is_c)
		var cur_reg_val: float = compute_regression_L_cm(display_mass, cur_n, is_c)
		var dot_pos := Vector2(cursor_x, origin.y - ((cur_l_val - l_min) / (l_max - l_min)) * plot_h)
		var dot_reg_pos := Vector2(cursor_x, origin.y - ((cur_reg_val - l_min) / (l_max - l_min)) * plot_h)

		_draw_horizontal_projection(origin.x, cursor_x, dot_pos.y, rig_color)
		_draw_dot(dot_pos, rig_color)

		# Regression marker point
		draw_circle(dot_reg_pos, 4.0 * ui_scale, COLOR_REGRESSION)
		draw_circle(dot_reg_pos, 1.8 * ui_scale, Color(0.1, 0.1, 0.1))

		# Informative Regression Badge on Chart
		var l_0: float = compute_regression_L_cm(0.0, cur_n, is_c)
		var slope_val: float = (compute_regression_L_cm(1.0, cur_n, is_c) - l_0)
		var formula_str: String
		if stiction_enabled and friction_mu > 0.005:
			formula_str = "Регрессия: L = %.1f + %.1f·m [cm]  ·  Погрешность покоя fs: ±%.1f cm" % [l_0, slope_val, deadband_cm]
		else:
			formula_str = "Чистая теория (Pure Glide): L = %.1f + %.1f·m [cm] (R² = 1.00)" % [l_0, slope_val]

		var font_sz: int = int(10 * ui_scale)
		var reg_box_w: float = font.get_string_size(formula_str, HORIZONTAL_ALIGNMENT_LEFT, -1, font_sz).x + 24.0 * ui_scale
		var reg_box_pos := Vector2(origin.x + 12.0 * ui_scale, margin_top + 12.0 * ui_scale)
		_draw_hud_badge(reg_box_pos, Vector2(reg_box_w, 22.0 * ui_scale), formula_str, COLOR_REGRESSION, font, font_sz, dark_theme, true, false)

		# Focused Cursor Tooltip
		var tip_text := "%s: L = %.1f cm  [Регрессия: %.1f cm]" % [rig_tag, cur_l_val, cur_reg_val]
		var tip_w: float = font.get_string_size(tip_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_sz).x + 24.0 * ui_scale
		var pill_tip_h: float = 20.0 * ui_scale
		var is_right_side: bool = cursor_x > (origin.x + plot_w - tip_w - 20.0 * ui_scale)
		var offset_x: float = -(tip_w + 14.0 * ui_scale) if is_right_side else 14.0 * ui_scale
		var pill_pos := Vector2(cursor_x + offset_x, dot_pos.y - pill_tip_h * 0.5)
		_draw_tooltip_pill(pill_pos, Vector2(tip_w, pill_tip_h), tip_text, rig_color, font, font_sz)


func _draw_cursor_marker(cursor_x: float, col: Color) -> void:
	_marker_tri[0] = Vector2(cursor_x, margin_top - 4.0 * ui_scale)
	_marker_tri[1] = Vector2(cursor_x - 4.5 * ui_scale, margin_top - 10.0 * ui_scale)
	_marker_tri[2] = Vector2(cursor_x + 4.5 * ui_scale, margin_top - 10.0 * ui_scale)
	draw_colored_polygon(_marker_tri, col)


func _draw_dot(pos: Vector2, col: Color) -> void:
	draw_arc(pos, 9.0 * ui_scale, 0.0, TAU, 24, Color(col.r, col.g, col.b, 0.40), 2.8 * ui_scale, true)
	draw_circle(pos, 5.0 * ui_scale, col)
	draw_circle(pos, 2.0 * ui_scale, Color(1.0, 1.0, 1.0))


func _draw_horizontal_projection(start_x: float, end_x: float, y_pos: float, color: Color) -> void:
	var dash_len: float = 4.0
	var gap_len: float = 3.0
	var cur_x: float = start_x
	var col_dash := Color(color.r, color.g, color.b, 0.35)
	while cur_x < end_x:
		var nxt := minf(cur_x + dash_len, end_x)
		draw_line(Vector2(cur_x, y_pos), Vector2(nxt, y_pos), col_dash, 1.0)
		cur_x += (dash_len + gap_len)


func _draw_hud_badge(pos: Vector2, sz: Vector2, text: String, accent_color: Color, font: Font, font_size: int, is_dark: bool, is_active: bool = false, is_dimmed: bool = false) -> void:
	var bg_col: Color
	if is_active:
		bg_col = Color(accent_color.r, accent_color.g, accent_color.b, 0.32 if is_dark else 0.22)
	elif is_dimmed:
		bg_col = Color(0.10, 0.12, 0.16, 0.75) if is_dark else Color(0.88, 0.90, 0.94, 0.85)
	else:
		bg_col = Color(0.12, 0.14, 0.18, 0.90) if is_dark else Color(0.92, 0.93, 0.96, 0.95)

	_style_badge.bg_color = bg_col
	_style_badge.border_color = Color(accent_color.r, accent_color.g, accent_color.b, 0.55 if is_dimmed else (1.0 if is_active else 0.85))
	draw_style_box(_style_badge, Rect2(pos, sz))
	draw_circle(Vector2(pos.x + 8.0, pos.y + sz.y * 0.5), 3.0, Color(accent_color.r, accent_color.g, accent_color.b, 0.65 if is_dimmed else 1.0))

	var text_y: float = pos.y + (sz.y - font.get_height(font_size)) * 0.5 + font.get_ascent(font_size)
	var text_pos := Vector2(pos.x + 15.0, text_y)
	var text_color: Color
	if is_dimmed:
		text_color = Color(0.82, 0.85, 0.90, 0.92) if is_dark else Color(0.20, 0.24, 0.32, 0.95)
	elif is_active:
		text_color = Color(1.0, 1.0, 1.0) if is_dark else Color(0.05, 0.05, 0.08)
	else:
		text_color = Color(0.96, 0.97, 0.99) if is_dark else Color(0.12, 0.13, 0.16)
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
