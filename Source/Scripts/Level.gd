extends Node2D

func _init():
	var _error
	_error = PlayerInput.connect("switch_control", self, "switch_player_host") #Tells the level that the player has changed host
	_error = PlayerInput.connect("finish_level", self, "finish") #Tells the level when the player has been turned off

func _ready():
	#Test code just to make 2 characters
	var PlayerCharacter = load("res://Source/Scenes/Objects/PlayerCharacter.tscn")
	var p1 = PlayerCharacter.instance()
	var p2 = PlayerCharacter.instance()
	p2.is_controlled = false
	p1.connect("switch_control", self, "switch_player_host")
	p2.connect("switch_control", self, "switch_player_host")
	
	self.add_child(p1)
	self.add_child(p2)
	PlayerInput.control = p1 #Set the players control on P1

#Switches the player control into a new character
func switch_player_host(new_host):
	PlayerInput.control = new_host

func _process(delta):
	guard_test_function()

#Finish the level
func finish():
	#Just erase everything for now
	PlayerInput.queue_free()
	self.queue_free()

func guard_test_function():
	if Input.is_action_just_pressed("p_action"):
		var path = $Navigation2D.get_simple_path($EnemyCharacter.get_global_position(),get_global_mouse_position(), false)
		path.remove(0)
		print(path)
		$EnemyCharacter.path_points = path

