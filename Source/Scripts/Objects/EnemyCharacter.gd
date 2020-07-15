extends "res://Source/Scripts/Objects/Character.gd"

onready var timer = $WaitTimer
onready var patrol_path = get_parent()

enum State {
	PATROL,
	CHASE,
	SEARCH,
	RETURN
}

export(State) var current_state = State.PATROL
var speed = 0
var min_distance = 10

#var patrol_path
var patrol_index = 0 setget set_patrol_index

var path_points
var path_index = 0

func _init().(false, 500, 150):
	pass

func _ready():
	#patrol_path = patrol.polygon
	patrol_index = 0
	#patrol.visible = false

func _physics_process(delta):	
	#if the character isn't controlled by player and is active	
	if is_active == true and is_controlled == false:
		match current_state:
			State.PATROL:
				patrol_state(delta)
			State.CHASE:
				chase_state(delta)
			State.SEARCH:
				search_state(delta)
			State.RETURN:
				return_state(delta)
		#if there is a path the character needs to go on
		#if path_points != null and path_points.size()>0 and path_index < path_points.size():
		#	move_on_path(path_points, path_index, delta)

func patrol_state(delta):
	speed = clamp(speed + acceleration,0,max_speed)
	var prepos = patrol_path.get_global_position()
	patrol_path.set_offset(patrol_path.get_offset() + (speed * delta))
	var pos = patrol_path.get_global_position()
	#move_direction = (pos.angle_to_point(prepos) / PI)*180

func chase_state(delta):
	pass

func search_state(delta):
	pass

func return_state(delta):
	pass

func move_on_path(path, index, delta):
	#move vector is target of movement
	var move_vector = path[index] - global_position
	#if we are close to next point, move to the next one
	if move_vector.length() < min_distance:
		return true
	else:
		#calculate new speed with accelration, maxed at max speed
		speed = clamp(speed + acceleration,0,max_speed)
		move_and_slide(move_vector.normalized() * speed)
		#turn to where we are going
		#TODO - smooth rotation
		look_at(path[index]+move_vector)
		return false
		#repeated function to remove the addition of PI/2 in the rotation

func move(input, delta):
	if input != Vector2.ZERO: #If there is movement, do the moving calculations
		velocity = velocity.move_toward(input * max_speed, acceleration * delta)
	else: #Otherwise, slow down cause friction
		velocity = velocity.move_toward(Vector2.ZERO, Constants.FRICTION * delta)
	velocity = move_and_slide(velocity) #Move
	self.rotation += (get_local_mouse_position().angle()) *TURN_SPEED #Direction rotation

func set_patrol_index(value):
	if value < patrol_path.size():
		patrol_index = value
	else:
		patrol_index = 0
