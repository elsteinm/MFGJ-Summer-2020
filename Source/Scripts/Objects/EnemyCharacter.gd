extends "res://Source/Scripts/Objects/Character.gd"

enum State {
	PATROL,
	CHASE,
	SEARCH,
	RETURN
}

onready var timer = $WaitTimer
onready var patrol_path = get_parent()
onready var player = PlayerInput.player_character
onready var raycast = $LightCast

export(State) var current_state = State.PATROL

var player_in_cone = false
var player_in_view = false
var player_exists = false
var direction = Vector2(1, 0)
var awareness = 0

var speed = 0
var min_distance = 10

#var patrol_path
var patrol_index = 0 setget set_patrol_index

var path_points
var path_index = 0

func _init().(false, 500, 150):
	pass

func _ready():
	if player != null:
		player_exists = true
	else:
		player_exists = false
	#patrol_path = patrol.polygon
	patrol_index = 0
	#patrol.visible = false

func _process(delta):
	if player_in_cone == true:
		var space = get_world_2d().direct_space_state
		var result = space.intersect_ray(global_position, player.transform.get_origin(), [self], raycast.collision_mask)
		if result["collider"] == player:
			player_in_view = true
		else:
			player_in_view = false
	var current_position = transform.get_origin()
	var facing = raycast.get_cast_to()
	detect_player(direction, current_position)

func _physics_process(delta):
	#if the character isn't controlled by player and is active	
	if is_active == true and is_controlled == false:
		match current_state:
			State.PATROL:
				patrol_state(delta)
				if awareness >= 1:
					current_state = State.CHASE
					look_at(player.transform.get_origin())
					#raycast.set_cast_to(direction)
			State.CHASE:
				chase_state(delta)
				if awareness <= 0.5:
					current_state = State.SEARCH
					rotation = 0
			State.SEARCH:
				search_state(delta)
				current_state = State.RETURN
			State.RETURN:
				return_state(delta)
				current_state = State.PATROL
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

func detect_player(facing, pos):
	if player_exists == true:
		var player_pos = player.transform.get_origin()
		var player_dir = pos.direction_to(player_pos).normalized()
		var facing_norm = facing.normalized()
		direction = player_dir
		if player_dir.dot(facing_norm) > 0.5 and player_in_view == true:
			if awareness < 1:
				awareness += player.detectability
		else:
			if awareness > 0:
				awareness -= 0.1

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

func _on_LightArea_body_entered(body):
	player_in_cone = true

func _on_LightArea_body_exited(body):
	player_in_cone = false
	player_in_view = false
