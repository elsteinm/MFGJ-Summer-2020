extends "res://Source/Scripts/Objects/Character.gd"

#enum to describe the current state of the guard
enum State {
	PATROL,
	CHASE,
	SEARCH,
	RETURN,
	HUNT
}

onready var timer = $WaitTimer #timer for search state
onready var patrol_path = get_parent() #base patrol path defined in the editor
onready var player = PlayerInput.player_character 
onready var raycast = $LightCast #raycast used to search whether the player is in light

var navigation_source #source to get the navigation information from
export(State) var current_state = State.PATROL

var last_player_location = Vector2.ZERO

var player_in_cone = false
var player_in_view = false
var player_exists = false
var direction = Vector2(1, 0)
var awareness = 0 # level of awareness the guard has of the player
export var rotation_speed = 1 #rotation speed in search state

var speed = 0 #current speed
var min_distance = 2 #from under this distance the guard moves on to next navigation point

var patrol_index = 0 setget set_patrol_index #used to save the location we are returning to in return state

var original_path #original path for patrol, calculated based on the patrol path
var path_points #current navigation path
var path_index = 0 #current navigation index, based on path_points

func _init().(false, 500, 100):
	pass

#in the setup, we do several steps:
#	1. check whether we got the player
#	2. calculate the patrol path, and save into original_path and path_points
func _ready():
	if player != null:
		player_exists = true
	else:
		player_exists = false
	#pre bake the patrol path into path_points
	original_path = PoolVector2Array()
	#get actual patrol path
	var path = patrol_path.get_parent().curve.get_baked_points()
	#for every point on the curve, we make 5 points on our original path variable 
	#to make a smooth path
	#the step is based on unit_offset, which ranges from 0-1
	#the step is the full range of the path devided by the amount of points we want
	var step = 1.0/path.size() * 5
	for _i in range(path.size() * 5):
		original_path.append(patrol_path.get_global_position())
		patrol_path.unit_offset += step 
	path_points = original_path

#in the process function we handle player detection. has 2 parts:
#	1. check if the player is directly in view(based on a raycast)
#	2. call detect player which handles the rest of the detection
func _process(_delta):
	if player_in_cone == true:
		var space = get_world_2d().direct_space_state
		var result = space.intersect_ray(global_position, player.transform.get_origin(), [self], raycast.collision_mask)
		if result["collider"] == player:
			player_in_view = true
		else:
			player_in_view = false
	var current_position = transform.get_origin()
	detect_player(direction, current_position)

#in this function we handle the actual movement of the guard, depending on his state
func _physics_process(delta):
	#if the character isn't controlled by player and is active	
	if is_active == true and is_controlled == false and freeze == false:
		match current_state:
			State.PATROL:
				patrol_state(delta)
				#if the awareness is over 1, we need to start chasing
				if awareness >= 1:
					last_player_location = player.get_global_position()
					current_state = State.CHASE
					look_at(player.transform.get_origin())
					#raycast.set_cast_to(direction)
			State.CHASE:
				chase_state(delta)
				#if the player manages to run away, we switch to searching for the player
				if awareness <= 0.5:
					timer.start()
					current_state = State.SEARCH
				elif awareness >= 0.9:
					last_player_location = player.get_global_position()
			State.SEARCH:
				search_state(delta)
				#if the player came back we go back to chasing him
				#switching to return state is based on timer
				if awareness >= 0.8:
					last_player_location = player.get_global_position()
					current_state = State.CHASE
					look_at(player.transform.get_origin())
			State.RETURN:
				return_state(delta)
				if awareness >= 0.9:
					last_player_location = player.get_global_position()
					current_state = State.CHASE
					look_at(player.transform.get_origin())
			State.HUNT:
				hunt_state(delta)
				if awareness >= 0.9:
					last_player_location = player.get_global_position()
					current_state = State.CHASE
					look_at(player.transform.get_origin())
#this funcion handles the behavior of the guard in the patrol state
#we check if the next point is to close, and then move to it if not
func patrol_state(delta):
	var distance = global_position.distance_to(path_points[path_index])
	#if we are close to next point, move to the next one
	if distance < min_distance:
		path_index = wrapi(path_index+1,0,path_points.size())
	move_on_path(path_points,path_index,delta)

#this function gets the path to the player, and then goes towards him
func chase_state(delta):
	var new_path = navigation_source.get_simple_path(global_position, last_player_location, true)
	path_points = new_path
	path_index = 0
	if path_points.size() != 0:
		var distance = global_position.distance_to(path_points[path_index])
		if distance < min_distance:
			if path_index == path_points.size() - 1:
				#if we are at the player, no need to move
				return
			else:
				#move to the next point on the path, we are near the current one
				path_index += 1
		move_on_path(path_points,path_index,delta)
#search simply turns in a circle and looks for the player
func search_state(delta):
	var last_known_position_distance = global_position.distance_to(last_player_location)
	if last_known_position_distance < min_distance:
		rotation += delta * rotation_speed
	else:
		var new_path = navigation_source.get_simple_path(global_position, last_player_location, true)
		path_points = new_path
		path_index = 0
		if path_points.size() != 0:
			var distance = global_position.distance_to(path_points[path_index])
			if distance < min_distance:
				if path_index == path_points.size() - 1:
					#if we are at the player, no need to move
					return
				else:
					#move to the next point on the path, we are near the current one
					path_index += 1
			move_on_path(path_points,path_index,delta)
#the guard moves towards the closest point on the original patrol path
#once he reaches it he switches back to the original patrol state and
#continues from the current point on the patrol path
#the path towards the original path is calculated before hand	
func return_state(delta):
	if path_points.size() != 0:
		var distance = global_position.distance_to(path_points[path_index])
		if distance < min_distance:
			if path_index == path_points.size() - 1:
				#if we reached the point on the patrol point, we move back to there
				path_points = original_path
				path_index = patrol_index
				current_state = State.PATROL
				return
			else:
				path_index += 1
		move_on_path(path_points,path_index,delta)
	else:
		path_points = original_path
		path_index = patrol_index
		current_state = State.PATROL
		
func hunt_state(delta):
	pass
#this function is responsible for the level of awareness the guard has of the player
func detect_player(facing, pos):
	if player_exists == true:
		var player_pos = player.transform.get_origin()
		var player_dir = pos.direction_to(player_pos).normalized()
		var facing_norm = facing.normalized()
		direction = player_dir
		#the player is in the view of the guard and in the angle the guard is looking
		if player_dir.dot(facing_norm) > 0.5 and player_in_view == true:
			if awareness < 1:
				#raise level of awareness
				awareness += player.detectability
		else:
			if awareness > 0:
				#lower level of awareness, player isn't in view
				awareness -= 0.1

func move_on_path(path, index, _delta):
	#move vector is target of movement
	var move_vector = path[index] - global_position
	#calculate new speed with accelration, maxed at max speed
	speed = clamp(speed + acceleration,0,max_speed)
	var _v = move_and_slide(move_vector.normalized() * speed)
	#turn to where we are going, smoothed out
	direction = (path[index] + move_vector)
	self.rotation += get_angle_to(direction) * 0.1
	#not sure why this return false
	return false

#function for movement when player is in control
func move(input, delta):
	if input != Vector2.ZERO: #If there is movement, do the moving calculations
		velocity = velocity.move_toward(input * max_speed, acceleration * delta)
	else: #Otherwise, slow down cause friction
		velocity = velocity.move_toward(Vector2.ZERO, Helper.FRICTION * delta)
	velocity = move_and_slide(velocity) #Move
	self.rotation += (get_local_mouse_position().angle()) *TURN_SPEED #Direction rotation

#not really needed function, loops the patrol index
func set_patrol_index(value):
	if value < patrol_path.size():
		patrol_index = value
	else:
		patrol_index = 0
#the player is in the cone of light
func _on_LightArea_body_entered(_body):
	player_in_cone = true
#player left cone
func _on_LightArea_body_exited(_body):
	player_in_cone = false
	player_in_view = false
#called by signal from the level, gives the navigation source
func get_nav(nav_source):
	navigation_source = nav_source

#end of search state, calls the calculation of the return route
func _on_WaitTimer_timeout():
	current_state = State.RETURN
	find_shortest_distance_patrol()

#this function calculates the shortest path to the patrol path
#loops over all points in the patrol path and finds the path to it
#finds the minimal length path
#run time is high, O(n^2), probably possible to lower
func find_shortest_distance_patrol():
	var shortest_distance = 9223372036854775807 #max int
	var shortest_path = null
	var shortest_goal = -1
	#loops over all original patrol path 
	for j in range(original_path.size()):
		var point = original_path[j]
		var path = navigation_source.get_simple_path(global_position,point,false)
		var total_distance = 0
		#sums the distance of the path to the point
		for i in range(path.size()-1):
			total_distance += path[i].distance_to(path[i+1])
		#if this is the shortest path found until now, switch the marking
		if shortest_distance > total_distance:
			shortest_distance = total_distance
			shortest_path = path
			shortest_goal = j
	#save the shortest path
	path_points = shortest_path
	patrol_index = shortest_goal
