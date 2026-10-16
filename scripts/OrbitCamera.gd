class_name OrbitCamera
extends Camera3D

## Smooth Orbit & Pan Camera Controller for Godot 4 3D Viewports
## Mobile Multi-Touch & Desktop Mouse Navigation with Responsive Auto-Framing

signal screen_tapped(screen_pos: Vector2)

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

# Mobile Multi-Touch State
var touch_points: Dictionary = {}
var touch_start_pos: Vector2 = Vector2.ZERO
var touch_start_time: int = 0
var initial_pinch_dist: float = 0.0
var initial_target_distance: float = 6.85
var touch_dragged: bool = false


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
			touch_points[st.index] = st.position
			if touch_points.size() == 1:
				touch_start_pos = st.position
				touch_start_time = Time.get_ticks_msec()
				touch_dragged = false
			elif touch_points.size() == 2:
				var keys = touch_points.keys()
				initial_pinch_dist = touch_points[keys[0]].distance_to(touch_points[keys[1]])
				initial_target_distance = target_distance
		else:
			if st.index == 0 and touch_points.size() == 1 and not touch_dragged:
				var duration: int = Time.get_ticks_msec() - touch_start_time
				var dist: float = st.position.distance_to(touch_start_pos)
				if duration < 350 and dist < 14.0:
					screen_tapped.emit(st.position)
			touch_points.erase(st.index)
			if touch_points.is_empty():
				touch_dragged = false

	# 2. Mobile Screen Drag Events
	elif event is InputEventScreenDrag:
		var sd := event as InputEventScreenDrag
		touch_points[sd.index] = sd.position
		if sd.relative.length_squared() > 4.0:
			touch_dragged = true

		if touch_points.size() == 1:
			# Single-finger smooth orbit
			var sens: float = orbit_speed * 0.95
			target_yaw -= sd.relative.x * sens
			target_pitch = clampf(target_pitch - sd.relative.y * sens, deg_to_rad(-40.0), deg_to_rad(60.0))
		elif touch_points.size() >= 2:
			# Two-finger pinch-to-zoom
			var keys = touch_points.keys()
			var current_pinch: float = touch_points[keys[0]].distance_to(touch_points[keys[1]])
			if initial_pinch_dist > 8.0 and current_pinch > 8.0:
				var zoom_ratio: float = initial_pinch_dist / current_pinch
				target_distance = clampf(initial_target_distance * zoom_ratio, min_distance, max_distance)

			# Two-finger pan
			var pan_delta: Vector2 = sd.relative * 0.5
			var right_vec := global_transform.basis.x
			var up_vec := global_transform.basis.y
			current_target -= right_vec * (pan_delta.x * pan_speed * 1.5)
			current_target += up_vec * (pan_delta.y * pan_speed * 1.5)

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
	target_distance = default_distance
	current_target = default_target


## Smoothly focus on a specific mechanism or reset to all rigs
func focus_rig(rig_id: String) -> void:
	match rig_id.to_upper():
		"A":
			current_target = Vector3(-1.65, 2.05, 0.0)
			target_distance = 4.2 if is_mobile_mode else 3.6
			target_yaw = deg_to_rad(4.0)
			target_pitch = deg_to_rad(-4.0)
		"C":
			current_target = Vector3(0.0, 1.95, 0.0)
			target_distance = 4.2 if is_mobile_mode else 3.6
			target_yaw = 0.0
			target_pitch = deg_to_rad(-4.0)
		"B":
			current_target = Vector3(1.65, 1.85, 0.0)
			target_distance = 4.4 if is_mobile_mode else 3.8
			target_yaw = deg_to_rad(-4.0)
			target_pitch = deg_to_rad(-4.0)
		_: # "ALL"
			current_target = default_target
			target_distance = default_distance
			target_yaw = 0.0
			target_pitch = deg_to_rad(-5.0)


func set_mobile_mode(is_mobile: bool) -> void:
	is_mobile_mode = is_mobile
	if is_mobile:
		keep_aspect = Camera3D.KEEP_WIDTH
		fov = 52.0
		default_distance = 8.50
		target_distance = 8.50
		default_target = Vector3(-0.20, 1.85, 0.0)
		target_point = default_target
		current_target = default_target
	else:
		keep_aspect = Camera3D.KEEP_HEIGHT
		fov = 54.0
		default_distance = 8.25
		target_distance = 8.25
		default_target = Vector3(-0.20, 1.60, 0.0)
		target_point = default_target
		current_target = default_target


## Auto-framing clamp for desktop/tablet viewports to prevent side cards from occluding Rig C or Rig B
func update_aspect_ratio_framing(vp_size: Vector2) -> void:
	if is_mobile_mode:
		return
	var aspect: float = vp_size.x / maxf(vp_size.y, 1.0)
	if aspect < 1.18:
		# Very narrow aspect ratio
		default_distance = 9.0
		default_target = Vector3(-0.20, 1.45, 0.0)
	elif aspect < 1.45:
		# 4:3 or square laptop/tablet display
		default_distance = 8.7
		default_target = Vector3(-0.20, 1.60, 0.0)
	elif aspect < 1.70:
		# 16:10 standard laptop display (e.g. 1440x900, 1680x1050, 1920x1200)
		default_distance = 8.4
		default_target = Vector3(-0.20, 1.60, 0.0)
	else:
		# 16:9 standard and Ultrawide displays
		default_distance = 8.25
		default_target = Vector3(-0.20, 1.60, 0.0)

	# If currently close to default, gently adjust target distance to new framing
	if absf(current_distance - target_distance) < 0.2:
		target_distance = default_distance
