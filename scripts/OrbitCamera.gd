class_name OrbitCamera
extends Camera3D

## Smooth Orbit & Pan Camera Controller for Godot 4 3D Viewports
## Mobile Multi-Touch & Desktop Mouse Navigation with Responsive Auto-Framing

signal screen_tapped(screen_pos: Vector2)
signal double_tapped(screen_pos: Vector2)

@export var target_point: Vector3 = Vector3(-0.20, 1.60, 0.0)
@export var default_distance: float = 8.25
@export var min_distance: float = 2.0
@export var max_distance: float = 14.0
@export var orbit_speed: float = 0.005
@export var zoom_speed: float = 0.4
@export var pan_speed: float = 0.004
@export var smooth_speed: float = 14.0

var current_distance: float = 8.25
var target_distance: float = 8.25

var yaw: float = 0.0
var pitch: float = deg_to_rad(-5.0)
var target_yaw: float = 0.0
var target_pitch: float = deg_to_rad(-5.0)

var current_target: Vector3 = Vector3(-0.20, 1.60, 0.0)
var default_target: Vector3 = Vector3(-0.20, 1.60, 0.0)

var is_orbiting: bool = false
var is_panning: bool = false
var is_mobile_mode: bool = false
var is_following_rig: bool = false
var follow_target_node: Node3D = null

# Mobile Multi-Touch State & Safe Touch Isolation
var touch_points: Dictionary = {}
var touch_start_pos: Vector2 = Vector2.ZERO
var touch_start_time: int = 0
var prev_pinch_dist: float = 0.0
var prev_touch_mid: Vector2 = Vector2.ZERO
var touch_dragged: bool = false
var touch_blocked_top_y: float = 0.0
var touch_blocked_bottom_y: float = 0.0
var is_touch_input_disabled: bool = false
var last_tap_time: int = 0
var last_tap_pos: Vector2 = Vector2.ZERO


func _ready() -> void:
	fov = 54.0
	current_distance = default_distance
	target_distance = default_distance
	pitch = deg_to_rad(-5.0)
	target_pitch = deg_to_rad(-5.0)
	current_target = target_point
	default_target = target_point
	_update_transform_immediate()


func _unhandled_input(event: InputEvent) -> void:
	# 1. Mobile Screen Touch Events
	if event is InputEventScreenTouch:
		var st := event as InputEventScreenTouch
		if st.pressed:
			if is_touch_input_disabled:
				return
			if touch_blocked_top_y > 0.0 and st.position.y <= touch_blocked_top_y:
				return
			if touch_blocked_bottom_y > 0.0 and st.position.y >= touch_blocked_bottom_y:
				return
			touch_points[st.index] = st.position
			if touch_points.size() == 1:
				touch_start_pos = st.position
				touch_start_time = Time.get_ticks_msec()
				touch_dragged = false
			elif touch_points.size() == 2:
				var keys = touch_points.keys()
				var k0: int = mini(int(keys[0]), int(keys[1]))
				var k1: int = maxi(int(keys[0]), int(keys[1]))
				var p0: Vector2 = touch_points[k0]
				var p1: Vector2 = touch_points[k1]
				prev_pinch_dist = p0.distance_to(p1)
				prev_touch_mid = (p0 + p1) * 0.5
				touch_dragged = true
		else:
			if touch_points.has(st.index):
				if st.index == 0 and touch_points.size() == 1 and not touch_dragged:
					var now := Time.get_ticks_msec()
					var duration: int = now - touch_start_time
					var dist: float = st.position.distance_to(touch_start_pos)
					if duration < 350 and dist < 18.0:
						if (now - last_tap_time) < 320 and st.position.distance_to(last_tap_pos) < 32.0:
							double_tapped.emit(st.position)
							last_tap_time = 0
						else:
							last_tap_time = now
							last_tap_pos = st.position
							screen_tapped.emit(st.position)
				touch_points.erase(st.index)
				if touch_points.size() == 1:
					var remaining_key = touch_points.keys()[0]
					touch_start_pos = touch_points[remaining_key]
					touch_start_time = Time.get_ticks_msec()
					prev_pinch_dist = 0.0
					prev_touch_mid = Vector2.ZERO
				elif touch_points.is_empty():
					touch_dragged = false
					prev_pinch_dist = 0.0
					prev_touch_mid = Vector2.ZERO

	# 2. Mobile Screen Drag Events
	elif event is InputEventScreenDrag:
		var sd := event as InputEventScreenDrag
		if not touch_points.has(sd.index):
			return
		touch_points[sd.index] = sd.position
		if sd.relative.length_squared() > 4.0:
			touch_dragged = true

		if touch_points.size() == 1:
			# Single-finger smooth orbit (yaw & pitch)
			var sens: float = orbit_speed * 0.95
			target_yaw -= sd.relative.x * sens
			target_pitch = clampf(target_pitch - sd.relative.y * sens, deg_to_rad(-40.0), deg_to_rad(60.0))
		elif touch_points.size() >= 2:
			var keys = touch_points.keys()
			var k0: int = mini(int(keys[0]), int(keys[1]))
			var k1: int = maxi(int(keys[0]), int(keys[1]))
			var p0: Vector2 = touch_points[k0]
			var p1: Vector2 = touch_points[k1]
			var curr_dist: float = p0.distance_to(p1)
			var curr_mid: Vector2 = (p0 + p1) * 0.5

			# 2.1. Pinch-to-Zoom (smooth distance delta between 2 fingers)
			if prev_pinch_dist > 5.0 and curr_dist > 5.0:
				var pinch_delta: float = curr_dist - prev_pinch_dist
				target_distance = clampf(target_distance - pinch_delta * 0.010, min_distance, max_distance)

			# 2.2. Two-Finger Smooth Orbit (changing perspective with two fingers)
			if prev_touch_mid != Vector2.ZERO:
				var mid_delta: Vector2 = curr_mid - prev_touch_mid
				var sens2: float = orbit_speed * 0.85
				target_yaw -= mid_delta.x * sens2
				target_pitch = clampf(target_pitch - mid_delta.y * sens2, deg_to_rad(-40.0), deg_to_rad(60.0))

			prev_pinch_dist = curr_dist
			prev_touch_mid = curr_mid

	# 3. Desktop Mouse Button Events
	elif event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_RIGHT or mb.button_index == MOUSE_BUTTON_LEFT:
			is_orbiting = mb.pressed
		elif mb.button_index == MOUSE_BUTTON_MIDDLE:
			is_panning = mb.pressed
		elif mb.button_index == MOUSE_BUTTON_WHEEL_UP and mb.pressed:
			target_distance = clampf(target_distance - zoom_speed, min_distance, max_distance)
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN and mb.pressed:
			target_distance = clampf(target_distance + zoom_speed, min_distance, max_distance)

	# 4. Desktop Mouse Motion Events
	elif event is InputEventMouseMotion:
		var mm := event as InputEventMouseMotion
		if is_orbiting:
			target_yaw -= mm.relative.x * orbit_speed
			target_pitch = clampf(target_pitch - mm.relative.y * orbit_speed, deg_to_rad(-40.0), deg_to_rad(60.0))
		elif is_panning:
			var right_vec := global_transform.basis.x
			var up_vec := global_transform.basis.y
			current_target -= right_vec * (mm.relative.x * pan_speed)
			current_target += up_vec * (mm.relative.y * pan_speed)
			current_target.x = clampf(current_target.x, -3.2, 3.2)
			current_target.y = clampf(current_target.y, 0.6, 3.4)
			current_target.z = 0.0


func _process(delta: float) -> void:
	if is_following_rig and follow_target_node != null and is_instance_valid(follow_target_node):
		var target_y: float = follow_target_node.global_position.y - 1.2
		if follow_target_node.has_method("get_base_resting_H"):
			var cur_l: float = follow_target_node.get("current_L")
			var v_scale: float = follow_target_node.get("visual_scale")
			target_y = follow_target_node.global_position.y - (cur_l * v_scale * 0.5)
		current_target = Vector3(follow_target_node.global_position.x, target_y, 0.0)

	var blend: float = 1.0 - exp(-smooth_speed * delta)
	yaw = lerp_angle(yaw, target_yaw, blend)
	pitch = lerpf(pitch, target_pitch, blend)
	current_distance = lerpf(current_distance, target_distance, blend)
	target_point = target_point.lerp(current_target, blend)

	var rot_quat := Quaternion(Vector3.UP, yaw) * Quaternion(Vector3.RIGHT, pitch)
	var offset := rot_quat * Vector3(0.0, 0.0, current_distance)

	global_position = target_point + offset
	look_at(target_point, Vector3.UP)


func set_follow_rig(enabled: bool, rig: Node3D = null) -> void:
	is_following_rig = enabled
	follow_target_node = rig
	if not enabled:
		current_target = default_target


func _update_transform_immediate() -> void:
	yaw = target_yaw
	pitch = target_pitch
	current_distance = target_distance
	target_point = current_target

	var rot_quat := Quaternion(Vector3.UP, yaw) * Quaternion(Vector3.RIGHT, pitch)
	var offset := rot_quat * Vector3(0.0, 0.0, current_distance)

	global_position = target_point + offset
	look_at(target_point, Vector3.UP)


func reset_camera() -> void:
	target_yaw = 0.0
	target_pitch = deg_to_rad(-5.0)
	if is_mobile_mode:
		target_distance = 3.60
		current_target = Vector3(-1.65, 1.85, 0.0)
	else:
		target_distance = default_distance
		current_target = default_target


func zoom_in(amount: float = 0.6) -> void:
	target_distance = clampf(target_distance - amount, min_distance, max_distance)


func zoom_out(amount: float = 0.6) -> void:
	target_distance = clampf(target_distance + amount, min_distance, max_distance)


func get_current_distance() -> float:
	return current_distance



## Smoothly focus on a specific mechanism or reset to all rigs
func focus_rig(rig_id: String) -> void:
	match rig_id.to_upper():
		"A":
			current_target = Vector3(-1.65, 1.85, 0.0) if is_mobile_mode else Vector3(-1.65, 2.05, 0.0)
			target_distance = 3.60 if is_mobile_mode else 3.60
			target_yaw = deg_to_rad(3.0)
			target_pitch = deg_to_rad(-4.0)
		"C":
			current_target = Vector3(0.0, 1.80, 0.0) if is_mobile_mode else Vector3(0.0, 1.95, 0.0)
			target_distance = 3.60 if is_mobile_mode else 3.60
			target_yaw = 0.0
			target_pitch = deg_to_rad(-4.0)
		"B":
			current_target = Vector3(1.65, 1.70, 0.0) if is_mobile_mode else Vector3(1.65, 1.85, 0.0)
			target_distance = 3.80 if is_mobile_mode else 3.80
			target_yaw = deg_to_rad(-3.0)
			target_pitch = deg_to_rad(-4.0)
		_: # "ALL"
			current_target = Vector3(-0.20, 1.65, 0.0) if is_mobile_mode else default_target
			target_distance = 7.80 if is_mobile_mode else default_distance
			target_yaw = 0.0
			target_pitch = deg_to_rad(-5.0)


func set_mobile_mode(is_mobile: bool) -> void:
	is_mobile_mode = is_mobile
	if is_mobile:
		keep_aspect = Camera3D.KEEP_HEIGHT
		fov = 54.0
		default_distance = 7.80
		target_distance = 3.60
		default_target = Vector3(-0.20, 1.65, 0.0)
		target_point = Vector3(-1.65, 1.85, 0.0)
		current_target = Vector3(-1.65, 1.85, 0.0)
		min_distance = 1.8
		max_distance = 12.0
	else:
		keep_aspect = Camera3D.KEEP_HEIGHT
		fov = 54.0
		default_distance = 8.25
		target_distance = 8.25
		default_target = Vector3(-0.20, 1.60, 0.0)
		target_point = default_target
		current_target = default_target
		min_distance = 2.0
		max_distance = 14.0


## Auto-framing clamp for desktop/tablet viewports to center mechanism in free space
func update_aspect_ratio_framing(vp_size: Vector2) -> void:
	if is_mobile_mode:
		return
	var aspect: float = vp_size.x / maxf(vp_size.y, 1.0)
	# On Desktop Landscape, right 40% is occupied by HUD cards.
	# The free 3D viewing area is the left 60%.
	# Center of left 60% is at X = 30% of screen.
	# To center the rigs horizontally in this left 60% window, the camera focus must shift slightly right (+X),
	# or camera target offset left (-0.55m).
	if aspect < 1.18:
		default_distance = 8.8
		default_target = Vector3(-0.55, 1.55, 0.0)
	elif aspect < 1.45:
		default_distance = 8.5
		default_target = Vector3(-0.55, 1.65, 0.0)
	elif aspect < 1.70:
		default_distance = 8.2
		default_target = Vector3(-0.55, 1.65, 0.0)
	else:
		default_distance = 8.0
		default_target = Vector3(-0.55, 1.65, 0.0)

	# If currently close to default, gently adjust target distance to new framing
	if absf(current_distance - target_distance) < 0.2:
		target_distance = default_distance
	if current_target.distance_to(default_target) < 0.5:
		current_target = default_target


## Centers the camera precisely inside the unobstructed screen window
func auto_fit_free_rect(free_rect: Rect2, vp_size: Vector2, rig_pos: Vector3, rig_height: float) -> void:
	if vp_size.x <= 0.0 or vp_size.y <= 0.0:
		return
	# Screen center vs free rect center
	var screen_center := vp_size * 0.5
	var free_center := free_rect.position + (free_rect.size * 0.5)
	var offset_ratio := (free_center - screen_center) / vp_size

	# Target 75% of available free height
	var visible_h_target: float = maxf(rig_height / 0.75, 1.5)
	var rad_fov: float = deg_to_rad(fov)
	var required_dist: float = (visible_h_target * 0.5) / tan(rad_fov * 0.5)

	# Adjust target position in 3D based on offset_ratio
	var h_shift: float = - offset_ratio.x * (visible_h_target * (vp_size.x / vp_size.y))
	var v_shift: float = offset_ratio.y * visible_h_target

	target_distance = clampf(required_dist, min_distance, max_distance)
	target_point = Vector3(rig_pos.x + h_shift, rig_pos.y + v_shift, rig_pos.z)
	current_target = target_point


func set_touch_blocked_regions(top_y: float, bottom_y: float) -> void:
	touch_blocked_top_y = top_y
	touch_blocked_bottom_y = bottom_y


func set_touch_disabled(disabled: bool) -> void:
	is_touch_input_disabled = disabled
