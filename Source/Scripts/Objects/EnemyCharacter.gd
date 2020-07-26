extends "res://Source/Scripts/Objects/Character.gd"

#enum to describe the current state of the guard
enum State {
	SENTRY,
	PATROL,
	PASSING,
	CHASE,
	SEARCH,
	RETURN,
	HUNT
}

onready var timer = $WaitTimer #timer for search state
onready var patrol_path = get_parent() #base patrol path defined in the editor
onready var player = PlayerInput.player_character 
onready var raycast = $LightCast #raycast used to search whether the player is in light
onready var line = load("res://Source/Scenes/Objects/ControlLine.tscn")
onready var rotation_tween = $RotationTween
onready var protection_effect = $ProtectionEffect
var navigation_source #source to get the navigation information from
export(State) var origin_state
var current_state
var original_rotation
var state_stack = []
var pass_target = null
export(NodePath) var protector1_path #setget set_protector1
export(NodePath) var protector2_path #setget set_protector2
export(NodePath) var protector3_path #setget set_protector3

var protector1
var protector2
var protector3
var protectors = Array()

var lines = {}
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
var frame_number = 0
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
	if patrol_path is PathFollow2D:
		var path = patrol_path.get_parent().curve.get_baked_points()
		var step = 1.0/path.size() * 3
		for _i in range(path.size() * 3):
			original_path.append(patrol_path.get_global_position())
			patrol_path.unit_offset += step 
	else:
		original_path.append(global_position)
	original_rotation = global_rotation
	#for every point on the curve, we make 5 points on our original path variable 
	#to make a smooth path
	#the step is based on unit_offset, which ranges from 0-1
	#the step is the full range of the path devided by the amount of points we want
	path_points = original_path
	current_state = origin_state
	if modulate != Color(1,1,1):
		light.color = modulate
	
	yield(Main, "level_loaded")
	if protector1_path.is_empty() != true:
		protector1 = get_node(protector1_path)
		add_line(protector1,0.0)
		protectors.append(protector1)
	if protector2_path.is_empty() != true:
		protector2 = get_node(protector2_path)
		add_line(protector2,0.5)
		protectors.append(protector2)
	if protector3_path.is_empty() != true:
		protector3 = get_node(protector3_path)
		add_line(protector3,1.0)
		protectors.append(protector3)
	if protectors.empty() != true:
		is_protected = true

#in the process function we handle player detection. has 2 parts:
#	1. check if the player is directly in view(based on a raycast)
#	2. call detect player which handles the rest of the detection
func _process(_delta):
	if is_protected == true:
		for protector in protectors:
			if protector.is_active == false:
				protection_effect.texture.gradient.remove_point(protectors.find(protector) / 2.0)
				protectors.erase(protector)
				var line = lines[protector]
				lines.erase(protector)
				line.queue_free()
				if protectors.empty() == true:
					is_protected = false
					protection_effect.visible = false
		#frame_number = (frame_number + 1) % 2
		#if frame_number == 0:
		update_lines()
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
			State.SENTRY:
				if awareness >= 1:
					last_player_location = player.get_global_position()
					current_state = State.CHASE
					look_at(player.transform.get_origin())
			State.PATROL:
				patrol_state(delta)
				#if the awareness is over 1, we need to start chasing
				if awareness >= 1:
					last_player_location = player.get_global_position()
					current_state = State.CHASE
					look_at(player.transform.get_origin())
					#raycast.set_cast_to(direction)
			State.PASSING:
				passing_state(delta)
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
func passing_state(delta):
	if path_points.size() != 0:
		var distance = global_position.distance_to(path_points[path_index])
		if distance < min_distance:
			if path_index == path_points.size() - 1:
				#if we reached the point on the patrol point, we move back to there
				current_state = state_stack.pop_front()
				if current_state == State.RETURN:
					find_shortest_distance_patrol()
				else:
					state_stack.push_front(current_state)
					current_state = State.RETURN
					if origin_state == State.SENTRY:
						path_points = navigation_source.get_simple_path(global_position,original_path[0],true)
						path_index = 0
						patrol_index = 0
					else:
						path_points = navigation_source.get_simple_path(global_position,original_path[pass_target],true)
						path_index = 0
						patrol_index = pass_target
				return
			else:
				path_index += 1
		move_on_path(path_points,path_index,delta)
	else:
		path_points = original_path
		path_index = patrol_index
		if current_state == State.SENTRY:
			rotation_tween.interpolate_property(self, "global_rotation", global_rotation, original_rotation, 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
			rotation_tween.start()
		current_state = origin_state
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
				if origin_state == State.SENTRY:
					rotation_tween.interpolate_property(self, "global_rotation", global_rotation, original_rotation, 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
					rotation_tween.start()
				current_state = origin_state
				return
			else:
				path_index += 1
		move_on_path(path_points,path_index,delta)
	else:
		path_points = original_path
		path_index = patrol_index
		if origin_state == State.SENTRY:
			rotation_tween.interpolate_property(self, "global_rotation", global_rotation, original_rotation, 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
			rotation_tween.start()
		current_state = origin_state
		state_stack.pop_front()

func hunt_state(_delta):
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
	if get_slide_count() > 0:
		for i in range(get_slide_count()):
			var coll = get_slide_collision(i)
			if not coll.collider is TileMap and not coll.collider == player and current_state != State.PASSING:
				pass_target = null
				if path_index == 0:
					pass_target = path_index
				else:
					for j in range(path_index,path_points.size()):
						if global_position.distance_to(path_points[j]) > 60:
							pass_target = j
							break;
					if pass_target == null:
						pass_target = 0
				var target_location = global_position
#				var to_turn =  global_position.angle_to(coll.position) * PI/2 * 20
				var to_turn = PI/2 - global_position.angle_to_point(coll.position)
				if to_turn >  PI/2:
					to_turn -= PI
				target_location += move_vector.rotated(to_turn).normalized() * 42
				state_stack.push_front(current_state)
				current_state = State.PASSING
				var new_path = PoolVector2Array()
				new_path.append(target_location)
				new_path.append(target_location + move_vector.normalized() * 42)
#				new_path.append(path_points[path_index])
				path_points = new_path
				path_index = 0
				return false
	#not sure why this return false
	return false

#function for movement when player is in control
func move(input, delta):
	if freeze != true:
		if input != Vector2.ZERO: #If there is movement, do the moving calculations
			velocity = velocity.move_toward(input * max_speed, acceleration * delta)
		else: #Otherwise, slow down cause friction
			velocity = velocity.move_toward(Vector2.ZERO, Helper.FRICTION * delta)
		velocity = move_and_slide(velocity) #Move
		if marker != null and global_position.distance_to(marker.global_position) > 0.5:
			self.rotation += (get_angle_to(marker.global_position)) *TURN_SPEED #Direction rotation

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
	state_stack.push_front(current_state)
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
	path_index = 0
	patrol_index = shortest_goal


#func set_protector1(value):
#	if protector1 != null:
#		remove_child(lines[protector1])
#		lines.erase(protector1)
#	if value != null:
#		protector1 = get_node(value)
#		if protector1 != null:
#			add_line(protector1)
#
#func set_protector2(value):
#	if protector2 != null:
#		remove_child(lines[protector2])
#		lines.erase(protector2)
#	if value != null:
#		protector2 = get_node(value)
#		if protector2 != null:
#			add_line(protector2)
#
#func set_protector3(value):
#	if protector3 != null:
#		remove_child(lines[protector3])
#		lines.erase(protector3)
#	if value != null:
#		protector3 = get_node(value)
#		if protector3 != null:
#			add_line(protector3)

func add_line(target,location):
	if line == null:
		line = load("res://Source/Scenes/Objects/ControlLine.tscn")
	var new_line = line.instance()
	protection_effect.visible = true
	if target.modulate != Color(1,1,1):
		new_line.modulate = target.modulate
		protection_effect.texture.gradient.add_point(location,target.modulate)
	else:
		new_line.modulate = Color(0.941176, 0.101961, 0.113725)
		protection_effect.texture.gradient.add_point(location,Color(0.941176, 0.101961, 0.113725))
	add_child(new_line)
	new_line.visible = false
	lines[target] = new_line
	new_line.extend_to = target.global_position

func update_lines():
	for i in lines:
		if lines[i] != null:
			if lines[i].is_queued_for_deletion() != true:
				lines[i].extend_to = to_local(i.global_position)

#Sets the is_controlled variable, overriden to allow return to patrol route
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
		if original_path != null:
			find_shortest_distance_patrol() 
			state_stack.push_front(current_state)
			current_state = State.RETURN
			$ControlEffect.visible = false

