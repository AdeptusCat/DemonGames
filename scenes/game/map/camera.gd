extends Camera2D



var START_POSITION : Vector2 = Vector2(1050, 0)
var _target_zoom : float = 0.2
const MIN_ZOOM : float = 0.2
const MAX_ZOOM : float = 2.0
const ZOOM_INCREMENT : float = 0.1
const ZOOM_RATE : float = 8.0
const MOVE_RATE : float = 200.0
var _target_position : Vector2 = START_POSITION
var arrived = false

const NORMAL_CAMERA : float = 0.5
const FAST_CAMERA : float = 0.1
var camera_moving_speed = NORMAL_CAMERA

var tw1

var scroll = false
var start_pos
var screen_boundaries = Vector2(1080, 1080)

var scroll_speed : int = 100
var scrolling : bool = false
var scroll_vector : Vector2 = Vector2.ZERO


var unitToFollow 

func _ready():
	Signals.moveCamera.connect(moveTo)
	Signals.resetCamera.connect(reset)
	Signals.followUnit.connect(_on_followUnit)
	Signals.stopFollowingUnit.connect(_on_stopFollowingUnit)
	reset()

func _physics_process(delta):
	zoom = lerp(zoom, _target_zoom * Vector2.ONE, ZOOM_RATE * delta)
	
	if unitToFollow:
		global_position = lerp(global_position, unitToFollow.global_position, 10.0 * delta)
	
	if is_equal_approx(_target_position.x, position.x) and is_equal_approx(_target_position.y, position.y) and not arrived:
		Signals.doneMoving.emit()
		arrived = true
	if scrolling:
		var _position : Vector2 = lerp(position, position + scroll_vector, 10.0 * delta)
		_position = _position.clamp(Vector2.ZERO - screen_boundaries, screen_boundaries + screen_boundaries)
		position = _position
#	if is_equal_approx(zoom.x, _target_zoom):
#		set_physics_process(false)



func _unhandled_input(event):
	if Input.is_action_just_pressed("middle_click"):
		scroll = true
		start_pos = get_viewport().get_mouse_position()
	if Input.is_action_just_released("middle_click"):
		scroll = false
	if scroll:
		if event is InputEventMouseMotion:
			var _position = position - event.relative * 6
			_position = _position.clamp(Vector2.ZERO - screen_boundaries, screen_boundaries + screen_boundaries)
			position = _position
#			get_viewport().warp_mouse(start_pos - event.relative)
#			start_pos = start_pos - event.relative
#	if event is InputEventMouseMotion:
#		if event.button_mask == MOUSE_BUTTON_MASK_MIDDLE:
#
#			var _position = position - event.relative# * zoom
#			_position = _position.clamp(Vector2.ZERO - Vector2(1980, 1080), Vector2(1980, 1080) + Vector2(1980, 1080))
#			position = _position
	
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_out()
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_in()


func _input(event):
	if Input.is_action_pressed("space"):
		if tw1:
			tw1.kill()
			Signals.doneMoving.emit()
#	if Input.is_action_just_pressed("space"):
#		camera_moving_speed = FAST_CAMERA
#	if Input.is_action_just_released("space"):
#		camera_moving_speed = NORMAL_CAMERA
#	if Input.is_action_pressed("ui_left"):
#		var _position = position + Vector2(-MOVE_RATE, 0)
#		_position = _position.clamp(Vector2.ZERO - screen_boundaries, screen_boundaries + screen_boundaries)
#		position = _position
	scroll_vector = Vector2.ZERO
	scrolling = false
	if Input.is_action_pressed("ui_left"):
		scrolling = true
		scroll_vector.x -= scroll_speed
	if Input.is_action_pressed("ui_right"):
		scrolling = true
		scroll_vector.x += scroll_speed
	if Input.is_action_pressed("ui_up"):
		scrolling = true
		scroll_vector.y -= scroll_speed
	if Input.is_action_pressed("ui_down"):
		scrolling = true
		scroll_vector.y += scroll_speed


func zoom_in():
	_target_zoom = max(_target_zoom - ZOOM_INCREMENT, MIN_ZOOM)
	set_physics_process(true)


func zoom_out():
	_target_zoom = min(_target_zoom + ZOOM_INCREMENT, MAX_ZOOM)
	set_physics_process(true)


func moveTo(_position):
	unitToFollow = null
	tw1 = get_tree().create_tween()
	tw1.set_trans(Tween.TRANS_CUBIC)
	tw1.set_ease(Tween.EASE_IN)
	tw1.parallel().tween_property(self, "position", _position, camera_moving_speed)
	tw1.parallel().tween_property(self, "_target_zoom", 0.6, camera_moving_speed)
	tw1.tween_callback(doneMoving)
	tw1.play()
	_target_position = _position
	arrived = false
	set_physics_process(true)


func doneMoving():
	Signals.doneMoving.emit()


func _on_followUnit(unit):
	unitToFollow = unit


func _on_stopFollowingUnit(unit):
	if unitToFollow == unit:
		unitToFollow = null


func reset():
	var tw2 = get_tree().create_tween()
	tw2.set_trans(Tween.TRANS_CUBIC)
	tw2.set_ease(Tween.EASE_IN)
	tw2.parallel().tween_property(self, "position", START_POSITION, 1.0)
	tw2.parallel().tween_property(self, "_target_zoom", 0.2, 1.0)
	tw2.connect("finished", on_reset_finished)
	tw2.play()
	_target_position = START_POSITION
	arrived = false
	_target_zoom = 0.2
	set_physics_process(true)


func on_reset_finished():
	Signals.cameraResetted.emit()


