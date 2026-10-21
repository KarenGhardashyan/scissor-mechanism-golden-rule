class_name ThemeManager
extends RefCounted

## ThemeManager: SpaceX Crew Dragon / Astro UXDS Unified Design System for Godot 4.5
## Handles color tokens, dynamic StyleBoxFlat generation, responsive scales, and typography.

# -----------------------------------------------------------------------------
# 1. COLOR TOKENS (Astro UXDS & SpaceX Dragon 2 Telemetry Specs)
# -----------------------------------------------------------------------------

# Dark Theme: "SpaceX Crew Dragon Telemetry" (Default)
const DARK_BG_VIEWPORT := Color("#080B10")       # Deep Obsidian Space Graphite
const DARK_GRID_SUB := Color(1.0, 1.0, 1.0, 0.035) # 5 cm grid lines
const DARK_GRID_AXIS := Color(0.0, 0.824, 1.0, 0.12) # SpaceX Cyan axis
const DARK_CARD_BG := Color(0.067, 0.090, 0.133, 0.88) # #111722 with alpha 0.88
const DARK_CARD_BORDER := Color(1.0, 1.0, 1.0, 0.10) # 1px subtle border
const DARK_TEXT_PRIMARY := Color("#F0F6FC")      # Bright white-slate
const DARK_TEXT_MUTED := Color("#8B949E")        # Secondary slate for labels
const DARK_ACCENT_CYAN := Color("#00D2FF")       # SpaceX Cyan
const DARK_ACCENT_BLUE := Color("#2B88D8")       # Electric Blue
const DARK_BTN_BG := Color(0.10, 0.14, 0.20, 0.70)
const DARK_BTN_ACTIVE_BG := Color(0.0, 0.824, 1.0, 0.18)

# Light Theme: "SpaceX Clean Lab / Brilliant.org"
const LIGHT_BG_VIEWPORT := Color("#CBD5E1")      # Calm engineering slate-300 tone
const LIGHT_GRID_SUB := Color(0.059, 0.090, 0.165, 0.06) # 1mm paper grid
const LIGHT_GRID_AXIS := Color(0.008, 0.518, 0.780, 0.22) # Cobalt blue axis
const LIGHT_CARD_BG := Color(1.0, 1.0, 1.0, 0.94) # Clean white paper
const LIGHT_CARD_BORDER := Color("#94A3B8")     # Crisp slate-400 border
const LIGHT_TEXT_PRIMARY := Color("#0F172A")     # Slate-900 high contrast
const LIGHT_TEXT_MUTED := Color("#475569")       # Slate-600 secondary readable tag
const LIGHT_ACCENT_COBALT := Color("#0284C7")    # Deep Sky/Cobalt Blue
const LIGHT_BTN_BG := Color(0.93, 0.95, 0.98, 0.90)
const LIGHT_BTN_ACTIVE_BG := Color(0.008, 0.518, 0.780, 0.14)
const LIGHT_RIG_LINK_COLOR := Color("#1E3A8A")   # Cobalt dark contrast arm
const LIGHT_RIG_PIN_COLOR := Color("#0F172A")    # Dark contrast pivot pin

# Vector CAD Hierarchy Palette (Identical semantic meaning across themes)
const COLOR_VECTOR_R_DARK := Color("#10B981")    # Emerald Green
const COLOR_VECTOR_R_LIGHT := Color("#059669")
const COLOR_VECTOR_FX_DARK := Color("#F43F5E")   # Coral Red
const COLOR_VECTOR_FX_LIGHT := Color("#E11D48")
const COLOR_VECTOR_FY_DARK := Color("#38BDF8")   # Sky Blue
const COLOR_VECTOR_FY_LIGHT := Color("#0284C7")
const COLOR_VECTOR_FRIC_DARK := Color("#C084FC") # Purple / Violet (fs / fk)
const COLOR_VECTOR_FRIC_LIGHT := Color("#9333EA")


# -----------------------------------------------------------------------------
# 2. DYNAMIC STYLEBOX BUILDERS
# -----------------------------------------------------------------------------

## Generates a HUD card StyleBoxFlat (Astro UXDS Surface Token)
static func create_card_style(is_dark: bool, radius: int = 4, pad: int = 14, accent_top: bool = false) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	if is_dark:
		sb.bg_color = DARK_CARD_BG
		sb.border_color = DARK_ACCENT_CYAN if accent_top else DARK_CARD_BORDER
		sb.shadow_color = Color(0.0, 0.0, 0.0, 0.40)
		sb.shadow_size = 6
	else:
		sb.bg_color = LIGHT_CARD_BG
		sb.border_color = LIGHT_ACCENT_COBALT if accent_top else LIGHT_CARD_BORDER
		sb.shadow_color = Color(0.059, 0.090, 0.165, 0.08)
		sb.shadow_size = 8

	sb.border_width_left = 1
	sb.border_width_top = 2 if accent_top else 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1

	sb.corner_radius_top_left = radius
	sb.corner_radius_top_right = radius
	sb.corner_radius_bottom_left = radius
	sb.corner_radius_bottom_right = radius

	sb.content_margin_left = pad
	sb.content_margin_top = pad
	sb.content_margin_right = pad
	sb.content_margin_bottom = pad
	return sb


## Generates a telemetry mini-metric pill StyleBoxFlat
static func create_metric_tile_style(is_dark: bool, radius: int = 4) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	if is_dark:
		sb.bg_color = Color(0.04, 0.06, 0.09, 0.88)
		sb.border_color = Color(1.0, 1.0, 1.0, 0.12)
	else:
		sb.bg_color = Color("#F8FAFC") # Crisp bright Slate-50 background
		sb.border_color = Color("#CBD5E1") # Slate-300 clean border

	sb.border_width_left = 1
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1

	sb.corner_radius_top_left = radius
	sb.corner_radius_top_right = radius
	sb.corner_radius_bottom_left = radius
	sb.corner_radius_bottom_right = radius

	sb.content_margin_left = 10
	sb.content_margin_top = 7
	sb.content_margin_right = 10
	sb.content_margin_bottom = 7
	return sb


## Generates an interactive button StyleBoxFlat (Normal, Hover, Active/Toggled)
static func create_button_style(is_dark: bool, is_active: bool, is_hover: bool = false, radius: int = 4) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	if is_dark:
		if is_active:
			sb.bg_color = DARK_BTN_ACTIVE_BG
			sb.border_color = DARK_ACCENT_CYAN
			sb.border_width_left = 1
			sb.border_width_top = 1
			sb.border_width_right = 1
			sb.border_width_bottom = 1
		elif is_hover:
			sb.bg_color = Color(0.14, 0.19, 0.28, 0.90)
			sb.border_color = Color(1.0, 1.0, 1.0, 0.25)
			sb.border_width_left = 1
			sb.border_width_top = 1
			sb.border_width_right = 1
			sb.border_width_bottom = 1
		else:
			sb.bg_color = DARK_BTN_BG
			sb.border_color = Color(1.0, 1.0, 1.0, 0.10)
			sb.border_width_left = 1
			sb.border_width_top = 1
			sb.border_width_right = 1
			sb.border_width_bottom = 1
	else:
		if is_active:
			sb.bg_color = LIGHT_ACCENT_COBALT # Vivid Cobalt fill for active button
			sb.border_color = LIGHT_ACCENT_COBALT
			sb.border_width_left = 1
			sb.border_width_top = 1
			sb.border_width_right = 1
			sb.border_width_bottom = 1
		elif is_hover:
			sb.bg_color = Color(0.88, 0.92, 0.96, 0.95)
			sb.border_color = Color(0.60, 0.70, 0.85, 0.90)
			sb.border_width_left = 1
			sb.border_width_top = 1
			sb.border_width_right = 1
			sb.border_width_bottom = 1
		else:
			sb.bg_color = Color("#F1F5F9") # Crisp Slate-100 paper fill
			sb.border_color = Color("#94A3B8") # Slate-400 crisp border
			sb.border_width_left = 1
			sb.border_width_top = 1
			sb.border_width_right = 1
			sb.border_width_bottom = 1

	sb.corner_radius_top_left = radius
	sb.corner_radius_top_right = radius
	sb.corner_radius_bottom_left = radius
	sb.corner_radius_bottom_right = radius

	sb.content_margin_left = 12
	sb.content_margin_top = 6
	sb.content_margin_right = 12
	sb.content_margin_bottom = 6
	return sb


## Styles a large, touch-friendly slider with proper grabber and track
static func apply_slider_style(slider: HSlider, is_dark: bool, grabber_size: int = 24) -> void:
	var track := StyleBoxFlat.new()
	track.bg_color = Color(0.12, 0.16, 0.22, 0.90) if is_dark else Color(0.82, 0.86, 0.92, 0.90)
	track.corner_radius_top_left = 4
	track.corner_radius_top_right = 4
	track.corner_radius_bottom_left = 4
	track.corner_radius_bottom_right = 4
	track.content_margin_top = 4
	track.content_margin_bottom = 4
	slider.add_theme_stylebox_override("slider", track)

	var active_track := StyleBoxFlat.new()
	active_track.bg_color = DARK_ACCENT_CYAN if is_dark else LIGHT_ACCENT_COBALT
	active_track.corner_radius_top_left = 4
	active_track.corner_radius_bottom_left = 4
	active_track.content_margin_top = 4
	active_track.content_margin_bottom = 4
	slider.add_theme_stylebox_override("grabber_area", active_track)
	slider.add_theme_stylebox_override("grabber_area_highlight", active_track)

	# Generate a circular grabber icon
	var img := Image.create(grabber_size, grabber_size, false, Image.FORMAT_RGBA8)
	var center := Vector2(grabber_size * 0.5, grabber_size * 0.5)
	var radius := (grabber_size * 0.5) - 1.5
	var grabber_col := DARK_ACCENT_CYAN if is_dark else LIGHT_ACCENT_COBALT
	for y in range(grabber_size):
		for x in range(grabber_size):
			var d: float = center.distance_to(Vector2(x + 0.5, y + 0.5))
			if d <= radius:
				img.set_pixel(x, y, Color.WHITE)
			elif d <= radius + 1.0:
				img.set_pixel(x, y, Color(1.0, 1.0, 1.0, clampf(1.0 - (d - radius), 0.0, 1.0)))
			else:
				img.set_pixel(x, y, Color(0, 0, 0, 0))
	var tex := ImageTexture.create_from_image(img)
	slider.add_theme_icon_override("grabber", tex)
	slider.add_theme_icon_override("grabber_highlight", tex)


## Creates a vector HUD badge style for 3D label capsules
static func create_vector_badge_style(is_dark: bool, vector_color: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.04, 0.06, 0.09, 0.88) if is_dark else Color(1.0, 1.0, 1.0, 0.92)
	sb.border_color = vector_color
	sb.border_width_left = 1
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.corner_radius_top_left = 4
	sb.corner_radius_top_right = 4
	sb.corner_radius_bottom_left = 4
	sb.corner_radius_bottom_right = 4
	sb.content_margin_left = 6
	sb.content_margin_top = 2
	sb.content_margin_right = 6
	sb.content_margin_bottom = 2
	return sb
