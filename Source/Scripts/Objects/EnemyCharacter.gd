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
var navigation_source
export(State) var current_state = State.PATROL

var player_in_cone = false
var player_in_view = false
var player_exists = false
var direction = Vector2(1, 0)
var awareness = 0
export var rotation_speed = 1

var speed = 0
var min_distance = 2

#var patrol_path
var patrol_index = 0 setget set_patrol_index

var original_path
var path_points
var path_index = 0

func _init().(false, 500, 100):
	pass

func _ready():
	if player != null:
		player_exists = true
	else:
		player_exists = false
	#patrol_path = patrol.polygon
	patrol_index = 0
	#patrol.visible = false
	#pre bake the patrol path into the path points
	original_path = PoolVector2Array()
	var path = patrol_path.get_parent().curve.get_baked_points()
	var step = 1.0/path.size() * 5
	for i in range(path.size() * 5):
		original_path.append(patrol_path.get_global_position())
		patrol_path.unit_offset += step 
	path_points = original_path

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
					timer.start()
					current_state = State.SEARCH
			State.SEARCH:
				search_state(delta)
				if awareness >= 0.8:
					current_state = State.CHASE
					look_at(player.transform.get_origin())
#				current_state = State.RETURN
			State.RETURN:
				return_state(delta)
		#if there is a path the character need	s to go on
		#if path_points != null and path_points.size()>0 and path_index < path_points.size():
		#	move_on_path(path_points, path_index, delta)

func patrol_state(delta):
	var distance = global_position.distance_to(path_points[path_index])
	#if we are close to next point, move to the next one
	if distance < min_distance:
		path_index = wrapi(path_index+1,0,path_points.size())
	move_on_path(path_points,path_index,delta)
#	speed = clamp(speed + acceleration,0,max_speed)
#	var prepos = patrol_path.get_global_position()
#	patrol_path.set_offset(patrol_path.get_offset() + (speed * delta))
#	var pos = patrol_path.get_global_position()
	#move_direction = (pos.angle_to_point(prepos) / PI)*180

func chase_state(delta):
	var new_path = navigation_source.get_simple_path(global_position,player.global_position,true)
	path_points = new_path
	path_index = 0
	if path_points.size() != 0:
		var distance = global_position.distance_to(path_points[path_index])
		if distance < min_distance:
			if path_index == path_points.size() - 1:
				return
			else:
				path_index += 1
		move_on_path(path_points,path_index,delta)

func search_state(delta):
	rotation += delta * rotation_speed
	
func return_state(delta):
	if path_points.size() != 0:
		var distance = global_position.distance_to(path_points[path_index])
		if distance < min_distance:
			if path_index == path_points.size() - 1:
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
#	if move_vector.length() < min_distance:
#		return true
#	else:
		#calculate new speed with accelration, maxed at max speed
	
	speed = clamp(speed + acceleration,0,max_speed)
	move_and_slide(move_vector.normalized() * speed)
	#turn to where we are going
	#TODO - smooth rotation
	var direction = (path[index] + move_vector)
	self.rotation += get_angle_to(direction) * 0.1
#	look_at(direction)
	return false
		#repeated function to remove the addition of PI/2 in the rotation

func move(input, delta):
	if input != Vector2.ZERO: #If there is movement, do the moving calculations
		velocity = velocity.move_toward(input * max_speed, acceleration * delta)
	else: #Otherwise, slow down cause friction
		velocity = velocity.move_toward(Vector2.ZERO, Helper.FRICTION * delta)
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
func get_nav(nav_source):
	navigation_source = nav_source


func _on_WaitTimer_timeout():
	current_state = State.RETURN
	find_shortest_distance_patrol()
	
func find_shortest_distance_patrol():
	var shortest_distance = 9223372036854775807 #max int
	var shortest_path = null
	var shortest_goal = -1
	for j in range(original_path.size()):
		var point = original_path[j]
		var path = navigation_source.get_simple_path(global_position,point,false)
		var total_distance = 0
		for i in range(path.size()-1):
			total_distance += path[i].distance_to(path[i+1])
		if shortest_distance > total_distance:
			shortest_distance = total_distance
			shortest_path = path
			shortest_goal = j
	path_points = shortest_path
	patrol_index = shortest_goal
