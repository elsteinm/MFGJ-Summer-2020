extends KinematicBody2D

onready var sprite = $Sprite
onready var control_effect = $ControlEffect
onready var light_area_collision = $LightArea/CollisionShape2D
onready var light = $Light2D
onready var control_cast = $ControlCast

var marker
var freeze = false
var is_moveable = false
var strech_location = Vector2.ZERO setget set_strech_location
export var is_active = true setget set_active
export var is_controlled : bool setget set_control
export var radius_of_control = 256
var control_target = null setget set_control_target
var in_range = false
var control_state = false
var returning = false
var is_protected = false

signal switch_control(new_host) #Signals switching to this object

func _init(control = false, moveable = false):
	is_moveable = moveable
	is_active = true
	is_controlled = control

func _ready():
	$ControlEffect.set_material($ControlEffect.get_material().duplicate())
	if is_controlled == true:
		$ControlEffect.visible = true

	else:
		$ControlEffect.visible = false

	
	if is_active == false:
		sprite.modulate = Color.black #Turns the character dark
		set_process(false) #Turns off process so the object stops
		light.enabled = false
		light_area_collision.disabled = true
		Main.remove_object_from_level()

func _enter_tree():
	var _error = self.connect("switch_control", Main, "switch_player_host")
	Main.add_object_to_level()

func _physics_process(_delta):
	if is_controlled == true and is_active == true and control_state == false:
		if $takeOverTween.is_active() == false:
			if marker != null:
				if global_position.distance_to(marker.global_position) < radius_of_control:
					marker.modulate = Color(1,1,1)
					in_range = true
				else:
					marker.modulate = Color(1,0,0)
					in_range = false	
			if in_range == true:
				var target = to_local(marker.global_position)
				target = target.clamped(radius_of_control)
				control_cast.cast_to = target
				var collider = control_cast.get_collider()
				if collider != null:
					if collider.is_active == true and collider.is_controlled == false and collider.is_protected == false:
						set_control_target(collider)
				else:
					set_control_target(null)
			else:
				set_control_target(null)
	if control_state == true:
		set_strech_location(control_target.global_position)


func make_target(make):
	if make == true:
		sprite.modulate = Color(0.113725, 0.027451, 0.329412)
	else:
		sprite.modulate = Color(1,1,1)

func set_control_target(value):
	if control_target != null and control_target != value:
		control_target.make_target(false)
		control_target = null
	if value != null:
		value.make_target(true)
		control_target = value
	

func _input(event):
	if is_controlled == true and is_active == true:
		if control_target != null and event.is_action_pressed("p_action"):
			start_take_over(control_target)
#			_on_takeOverTween_tween_completed()

func start_take_over(target):
#	$ControlEffect.scale.x = 0.5
	$ControlLine.visible = true
	returning = false
	$takeOverTween.interpolate_method(self,'set_strech_location',global_position,target.global_position,0.5)
	$takeOverTween.start()
	control_target.freeze = true
	PlayerInput.returning = true
#	$ControlEffect.material.set_shader_param('need_strech',true)
#	set_process(false)
#Sets the is_active variable
func set_active(value):
	is_active = value
	if is_active == false:
		sprite.modulate = Color.black #Turns the character dark
		set_process(false) #Turns off process so the object stops
		light.enabled = false
		light_area_collision.disabled = true
		Main.remove_object_from_level()
		$ControlEffect.visible = false
		$ControlLine.visible = false
		control_state = false


#Sets the is_controlled variable
func set_control(value):
	is_controlled = value
	if is_controlled == true:
		$ControlEffect.visible = true
		set_strech_location(Vector2.ZERO)
		$ControlLine.visible = false
		control_state = false
		freeze = false
		set_process(true)
	else:
		$ControlEffect.visible = false

func _exit_tree():
	queue_free()

func set_strech_location(value):
	if control_target != null and control_target.freeze == true:
		PlayerInput.move_camera(value)
	value = to_local(value)
	$ControlLine.extend_to = value
#	$ControlEffect.material.set_shader_param('target_strech',value)
	strech_location = value
#	$Camera2D.position = (value)

func reverse_control_line():
	$ControlLine.visible = true
	$takeOverTween.interpolate_method(self,'set_strech_location',to_global($ControlLine.extend_to),global_position,0.5)
	$takeOverTween.start()
	control_target.freeze = true
	returning = true
	PlayerInput.returning = true

func _on_takeOverTween_tween_completed(_object = null, _key = null):
	if returning == false:
		emit_signal('switch_control',control_target)
		control_state = true
		PlayerInput.returning = false
	else:
		PlayerInput.remove_first_after_return()

#	$Camera2D.position = Vector2(0,0)
func set_marker(marker_loc):
	self.marker = marker_loc

