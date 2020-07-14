extends Node

var current_level setget set_level

func _init():
	var _error
	_error = PlayerInput.connect("switch_control", self, "switch_player_host") #Tells the level that the player has changed host
	#_error = PlayerInput.connect("finish_level", self, "finish_level") #Tells the level when the player has been turned off

#Switches the player control into a new character
func switch_player_host(new_host):
	PlayerInput.control = new_host

#Finish the level
func finish_level():
	#Just erase everything for now
	current_level.queue_free()
	PlayerInput.queue_free()
	self.queue_free()

func set_level(lvl):
	current_level = lvl

func add_object_to_level(o):
	current_level.add_object(o)

func remove_object_from_level(o):
	current_level.remove_object(o)
