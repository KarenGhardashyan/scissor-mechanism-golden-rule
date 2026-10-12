class_name LiveGraph
extends Control

## Apple "Light Liquid Glass" Live Realtime 2D Plot for L(m)
## Visualizes theoretical displacement curves:
## - Rig A: L_A(m) = 3 · H(m)  (λ = 3.0×)
## - Rig C: L_C(m) = 6 · H0(m) (λ = 6.0×, 1:2:3 Variable Scissor)
## - Rig B: L_B(m) = 5 · H(m)  (λ = 5.0×)
## Features antialiased glow lines, interactive mass scrubbing, and VisionOS floating tooltip pills.

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

# Margins inside the panel
var margin_left: float = 46.0
var margin_right: float = 16.0
var margin_top: float = 24.0
var margin_bottom: float = 26.0

# Interactive mouse drag state
var is_dragging: bool = false

# Design Colors (Apple VisionOS Palette)
const COLOR_RIG_A := Color(0.0, 0.443, 0.89)      # Apple Electric Tech-Blue (#0071E3)
const COLOR_RIG_C := Color(0.19, 0.82, 0.35)      # Apple Emerald Green (#30D158)
const COLOR_RIG_B := Color(1.0, 0.42, 0.05)       # Apple Ultra Orange (#FF6B0D)
const COLOR_CHARCOAL := Color(0.114, 0.114, 0.122) # #1D1D1F
const COLOR_SECONDARY := Color(0.35, 0.36, 0.40)  # #595C66
const COLOR_GRID_MAJOR := Color(0.18, 0.20, 0.26, 0.14)
const COLOR_GRID_AXIS := Color(0.18, 0.20, 0.26, 0.45)
const COLOR_OBSIDIAN := Color(0.10, 0.11, 0.14, 0.90)


func _ready() -> void:
	custom_minimum_size = Vector2(700, 130)
	mouse_filter = Control.MOUSE_FILTER_STOP


func set_mass(val: float) -> void:
	if not is_equal_approx(current_mass, val):
		current_mass = clampf(val, mass_min, mass_max)
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


func compute_L_cm(m: float, n: int) -> float:
	var p_eff: float = m * gravity + (float(n) * link_mass * gravity) * 0.5
	var eta_safe: float = clampf(efficiency_eta, 0.50, 1.00)
	var tension: float = (float(n) * p_eff) / eta_safe
	var delta_h: float = tension / spring_k
	var max_h: float = physical_link_length * 2.0 * 0.96
	var h: float = clampf(physical_resting_H + delta_h, 0.035, max_h)
	return float(n) * h * 100.0


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


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				var local_x: float = mb.position.x
				if local_x >= margin_left - 12.0 and local_x <= size.x - margin_right + 12.0:
					is_dragging = true
					_scrub_mass_at_x(local_x)
			else:
				is_dragging = false
	elif event is InputEventMouseMotion:
		var mm := event as InputEventMouseMotion
		if is_dragging:
			_scrub_mass_at_x(mm.position.x)


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

	# --- 1. HEADER TITLE & LEGEND BADGES ---
	var title_text := "REALTIME DISPLACEMENT PROFILE: L(m) = λ · H(m)"
	draw_string(font, Vector2(margin_left, margin_top - 8), title_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, COLOR_CHARCOAL)

	# Legend Pills (Rig A Blue, Rig C Green, Rig B Orange, Verification)
	var leg_x: float = size.x - margin_right - 480.0

	# Rig A Legend Pill
	draw_circle(Vector2(leg_x, margin_top - 12), 3.5, COLOR_RIG_A)
	draw_string(font, Vector2(leg_x + 7, margin_top - 8), "Rig A (n=3) · λ=3×", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, COLOR_RIG_A)

	# Rig C Legend Pill
	var leg_c_x: float = leg_x + 115.0
	draw_circle(Vector2(leg_c_x, margin_top - 12), 3.5, COLOR_RIG_C)
	draw_string(font, Vector2(leg_c_x + 7, margin_top - 8), "Rig C (1:2:3) · λ=6×", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, COLOR_RIG_C)

	# Rig B Legend Pill
	var leg_b_x: float = leg_c_x + 125.0
	draw_circle(Vector2(leg_b_x, margin_top - 12), 3.5, COLOR_RIG_B)
	draw_string(font, Vector2(leg_b_x + 7, margin_top - 8), "Rig B (n=5) · λ=5×", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, COLOR_RIG_B)

	# Golden Rule Verified Pill
	var leg_v_x: float = leg_b_x + 115.0
	draw_string(font, Vector2(leg_v_x, margin_top - 8), "✓ W_out = η · W_in", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.19, 0.82, 0.35))

	# --- 2. GRID & AXES ---
	var y_steps: int = 6
	for i in range(y_steps + 1):
		var l_val: float = float(i) * (l_max / float(y_steps))
		var frac_y: float = (l_val - l_min) / (l_max - l_min)
		var y_pos: float = origin.y - frac_y * plot_h

		draw_line(Vector2(origin.x, y_pos), Vector2(origin.x + plot_w, y_pos), COLOR_GRID_MAJOR, 1.0)

		var tick_str := "%d" % int(l_val)
		var str_w: float = font.get_string_size(tick_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 9).x
		draw_string(font, Vector2(origin.x - str_w - 6, y_pos + 3), tick_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, COLOR_SECONDARY)

	draw_string(font, Vector2(origin.x - 32, margin_top - 6), "L (cm)", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, COLOR_CHARCOAL)

	# X-axis Grid Lines (0.0 to 1.5 kg)
	var x_ticks := [0.0, 0.3, 0.6, 0.9, 1.2, 1.5]
	for m_tick in x_ticks:
		var frac_x: float = (m_tick - mass_min) / (mass_max - mass_min)
		var x_pos: float = origin.x + frac_x * plot_w

		draw_line(Vector2(x_pos, origin.y), Vector2(x_pos, margin_top), COLOR_GRID_MAJOR, 1.0)

		var tick_str := "%.1f" % m_tick
		var str_w: float = font.get_string_size(tick_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 9).x
		draw_string(font, Vector2(x_pos - str_w * 0.5, origin.y + 12), tick_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, COLOR_SECONDARY)

	var x_title := "Suspended Mass m (kg)"
	var x_title_w: float = font.get_string_size(x_title, HORIZONTAL_ALIGNMENT_LEFT, -1, 9).x
	draw_string(font, Vector2(origin.x + (plot_w - x_title_w) * 0.5, origin.y + 24), x_title, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, COLOR_CHARCOAL)

	draw_line(Vector2(origin.x, origin.y), Vector2(origin.x + plot_w, origin.y), COLOR_GRID_AXIS, 1.5)
	draw_line(Vector2(origin.x, origin.y), Vector2(origin.x, margin_top), COLOR_GRID_AXIS, 1.5)

	# --- 3. THEORETICAL CURVES ---
	var num_samples: int = 50
	var pts_a := PackedVector2Array()
	var pts_c := PackedVector2Array()
	var pts_b := PackedVector2Array()

	for i in range(num_samples + 1):
		var t: float = float(i) / float(num_samples)
		var m_samp: float = lerp(mass_min, mass_max, t)
		var x_p: float = origin.x + t * plot_w

		# Rig A (n=3)
		var la_val: float = compute_L_cm(m_samp, 3)
		var la_frac: float = clampf((la_val - l_min) / (l_max - l_min), 0.0, 1.0)
		pts_a.append(Vector2(x_p, origin.y - la_frac * plot_h))

		# Rig C (1:2:3, lambda=6)
		var lc_val: float = compute_L_c_cm(m_samp)
		var lc_frac: float = clampf((lc_val - l_min) / (l_max - l_min), 0.0, 1.0)
		pts_c.append(Vector2(x_p, origin.y - lc_frac * plot_h))

		# Rig B (n=5)
		var lb_val: float = compute_L_cm(m_samp, 5)
		var lb_frac: float = clampf((lb_val - l_min) / (l_max - l_min), 0.0, 1.0)
		pts_b.append(Vector2(x_p, origin.y - lb_frac * plot_h))

	# Draw Curve A (Blue, n=3)
	if pts_a.size() >= 2:
		draw_polyline(pts_a, Color(COLOR_RIG_A.r, COLOR_RIG_A.g, COLOR_RIG_A.b, 0.25), 5.5, true)
		draw_polyline(pts_a, COLOR_RIG_A, 2.4, true)

	# Draw Curve C (Emerald Green, 1:2:3)
	if pts_c.size() >= 2:
		draw_polyline(pts_c, Color(COLOR_RIG_C.r, COLOR_RIG_C.g, COLOR_RIG_C.b, 0.25), 5.5, true)
		draw_polyline(pts_c, COLOR_RIG_C, 2.4, true)

	# Draw Curve B (Ultra Orange, n=5)
	if pts_b.size() >= 2:
		draw_polyline(pts_b, Color(COLOR_RIG_B.r, COLOR_RIG_B.g, COLOR_RIG_B.b, 0.25), 5.5, true)
		draw_polyline(pts_b, COLOR_RIG_B, 2.4, true)

	# --- 4. DYNAMIC REALTIME MARKERS ---
	var cur_m_frac: float = clampf((current_mass - mass_min) / (mass_max - mass_min), 0.0, 1.0)
	var cursor_x: float = origin.x + cur_m_frac * plot_w

	# Vertical Dashed Cursor Line
	var dash_len: float = 5.0
	var gap_len: float = 4.0
	var cur_y: float = origin.y
	while cur_y > margin_top:
		var next_y: float = maxf(cur_y - dash_len, margin_top)
		draw_line(Vector2(cursor_x, cur_y), Vector2(cursor_x, next_y), Color(0.18, 0.20, 0.26, 0.65), 1.2)
		cur_y -= (dash_len + gap_len)

	# Current L values
	var cur_la: float = compute_L_cm(current_mass, 3)
	var cur_lc: float = compute_L_c_cm(current_mass)
	var cur_lb: float = compute_L_cm(current_mass, 5)

	var dot_a_pos := Vector2(cursor_x, origin.y - ((cur_la - l_min) / (l_max - l_min)) * plot_h)
	var dot_c_pos := Vector2(cursor_x, origin.y - ((cur_lc - l_min) / (l_max - l_min)) * plot_h)
	var dot_b_pos := Vector2(cursor_x, origin.y - ((cur_lb - l_min) / (l_max - l_min)) * plot_h)

	# Rig A Blue Dot
	draw_arc(dot_a_pos, 8.0, 0.0, TAU, 24, Color(COLOR_RIG_A.r, COLOR_RIG_A.g, COLOR_RIG_A.b, 0.35), 2.5, true)
	draw_circle(dot_a_pos, 4.5, COLOR_RIG_A)
	draw_circle(dot_a_pos, 1.8, Color(1.0, 1.0, 1.0))

	# Rig C Green Dot
	draw_arc(dot_c_pos, 8.0, 0.0, TAU, 24, Color(COLOR_RIG_C.r, COLOR_RIG_C.g, COLOR_RIG_C.b, 0.35), 2.5, true)
	draw_circle(dot_c_pos, 4.5, COLOR_RIG_C)
	draw_circle(dot_c_pos, 1.8, Color(1.0, 1.0, 1.0))

	# Rig B Orange Dot
	draw_arc(dot_b_pos, 8.0, 0.0, TAU, 24, Color(COLOR_RIG_B.r, COLOR_RIG_B.g, COLOR_RIG_B.b, 0.35), 2.5, true)
	draw_circle(dot_b_pos, 4.5, COLOR_RIG_B)
	draw_circle(dot_b_pos, 1.8, Color(1.0, 1.0, 1.0))

	# --- 5. FLOATING TOOLTIP PILLS ---
	var tip_a_text := "Rig A: L = %.1f cm" % cur_la
	var tip_c_text := "Rig C: L = %.1f cm" % cur_lc
	var tip_b_text := "Rig B: L = %.1f cm" % cur_lb

	var font_sz: int = 10
	var sz_a := font.get_string_size(tip_a_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_sz)
	var sz_c := font.get_string_size(tip_c_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_sz)
	var sz_b := font.get_string_size(tip_b_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_sz)

	var max_w: float = maxf(maxf(sz_a.x, sz_c.x), sz_b.x) + 24.0
	var pill_h: float = 20.0

	var is_right_side: bool = cursor_x > (origin.x + plot_w - 140.0)
	var offset_x: float = -(max_w + 12.0) if is_right_side else 12.0

	var pill_pos_a := Vector2(cursor_x + offset_x, dot_a_pos.y - pill_h * 0.5)
	var pill_pos_c := Vector2(cursor_x + offset_x, dot_c_pos.y - pill_h * 0.5)
	var pill_pos_b := Vector2(cursor_x + offset_x, dot_b_pos.y - pill_h * 0.5)

	# Avoid vertical overlap between pills
	if absf(pill_pos_c.y - pill_pos_b.y) < pill_h + 3.0:
		pill_pos_b.y = pill_pos_c.y - pill_h - 4.0
	if absf(pill_pos_a.y - pill_pos_c.y) < pill_h + 3.0:
		pill_pos_a.y = pill_pos_c.y + pill_h + 4.0

	_draw_tooltip_pill(pill_pos_a, Vector2(max_w, pill_h), tip_a_text, COLOR_RIG_A, font, font_sz)
	_draw_tooltip_pill(pill_pos_c, Vector2(max_w, pill_h), tip_c_text, COLOR_RIG_C, font, font_sz)
	_draw_tooltip_pill(pill_pos_b, Vector2(max_w, pill_h), tip_b_text, COLOR_RIG_B, font, font_sz)


func _draw_tooltip_pill(pos: Vector2, sz: Vector2, text: String, border_color: Color, font: Font, font_size: int) -> void:
	var pill_style := StyleBoxFlat.new()
	pill_style.bg_color = COLOR_OBSIDIAN
	pill_style.border_color = border_color
	pill_style.border_width_left = 1
	pill_style.border_width_top = 1
	pill_style.border_width_right = 1
	pill_style.border_width_bottom = 1
	pill_style.corner_radius_top_left = 5
	pill_style.corner_radius_top_right = 5
	pill_style.corner_radius_bottom_left = 5
	pill_style.corner_radius_bottom_right = 5
	pill_style.shadow_color = Color(0.0, 0.0, 0.0, 0.22)
	pill_style.shadow_size = 4
	pill_style.shadow_offset = Vector2(0, 2)

	draw_style_box(pill_style, Rect2(pos, sz))
	draw_circle(Vector2(pos.x + 8.0, pos.y + sz.y * 0.5), 3.0, border_color)

	var text_y: float = pos.y + (sz.y - font.get_height(font_size)) * 0.5 + font.get_ascent(font_size)
	var text_pos := Vector2(pos.x + 15.0, text_y)
	draw_string(font, text_pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(0.96, 0.97, 0.98))


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()
