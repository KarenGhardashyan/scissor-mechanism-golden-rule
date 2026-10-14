class_name OrbitCamera
extends Camera3D

## Smooth Orbit & Pan Camera Controller for Godot 4 3D Viewports
## Centered around the experimental scissor test benches with smooth damping and responsive auto-framing.

@export var target_point: Vector3 = Vector3(0.0, 1.75, 0.0)
@export var default_distance: float = 6.85
@export var min_distance: float = 2.5
@export var max_distance: float = 12.0
@export var orbit_speed: float = 0.005
@export var zoom_speed: float = 0.4
@export var pan_speed: float = 0.004
@export var smooth_speed: float = 14.0

var current_distance: float = 6.85
var target_distance: float = 6.85

var yaw: float = 0.0
var pitch: float = deg_to_rad(-5.0)
var target_yaw: float = 0.0
var target_pitch: float = deg_to_rad(-5.0)

var current_target: Vector3 = Vector3(0.0, 1.75, 0.0)
var default_target: Vector3 = Vector3(0.0, 1.75, 0.0)

var is_orbiting: bool = false
var is_panning: bool = false
var is_mobile_mode: bool = false


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
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_RIGHT or mb.button_index == MOUSE_BUTTON_LEFT:
			is_orbiting = mb.pressed
		elif mb.button_index == MOUSE_BUTTON_MIDDLE:
			is_panning = mb.pressed
		elif mb.button_index == MOUSE_BUTTON_WHEEL_UP and mb.pressed:
			target_distance = clampf(target_distance - zoom_speed, min_distance, max_distance)
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN and mb.pressed:
			target_distance = clampf(target_distance + zoom_speed, min_distance, max_distance)

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
	var blend: float = 1.0 - exp(-smooth_speed * delta)
	yaw = lerp_angle(yaw, target_yaw, blend)
	pitch = lerpf(pitch, target_pitch, blend)
	current_distance = lerpf(current_distance, target_distance, blend)
	target_point = target_point.lerp(current_target, blend)

	var rot_quat := Quaternion(Vector3.UP, yaw) * Quaternion(Vector3.RIGHT, pitch)
	var offset := rot_quat * Vector3(0.0, 0.0, current_distance)

	global_position = target_point + offset
	look_at(target_point, Vector3.UP)


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


func set_mobile_mode(is_mobile: bool) -> void:
	is_mobile_mode = is_mobile
	if is_mobile:
		default_distance = 7.8
		target_distance = 7.8
		default_target = Vector3(0.0, 1.55, 0.0)
		target_point = default_target
		current_target = default_target
	else:
		default_distance = 6.85
		target_distance = 6.85
		default_target = Vector3(0.0, 1.75, 0.0)
		target_point = default_target
		current_target = default_target


## Auto-framing clamp for desktop/tablet viewports to prevent side cards from occluding Rig C or Rig B
func update_aspect_ratio_framing(vp_size: Vector2) -> void:
	if is_mobile_mode:
		return
	var aspect: float = vp_size.x / maxf(vp_size.y, 1.0)
	if aspect < 1.18:
		# Very narrow aspect ratio
		default_distance = 7.8
		default_target = Vector3(0.0, 1.55, 0.0)
	elif aspect < 1.45:
		# 4:3 or square laptop/tablet display
		default_distance = 7.4
		default_target = Vector3(0.0, 1.75, 0.0)
	elif aspect < 1.70:
		# 16:10 standard laptop display (e.g. 1440x900, 1680x1050, 1920x1200)
		default_distance = 7.0
		default_target = Vector3(0.0, 1.75, 0.0)
	else:
		# 16:9 standard and Ultrawide displays
		default_distance = 6.85
		default_target = Vector3(0.0, 1.75, 0.0)

	# If currently close to default, gently adjust target distance to new framing
	if absf(current_distance - target_distance) < 0.2:
		target_distance = default_distance
