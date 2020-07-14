extends Node

var LevelFinishedScreen = preload("res://Source/Scenes/Interface/LevelFinishedScreen.tscn")
var LevelPackedScene

var level_number setget set_level_number
var current_level

func _ready():
	var _error
	_error = PlayerInput.connect("switch_control", self, "switch_player_host") #Tells the level that the player has changed host
	_error = PlayerInput.connect("finish_level", self, "finish_level") #Tells the level when the player has been turned off
	self.level_number = 1

#Load the level
func load_level():
	current_level = LevelPackedScene.instance()
	get_tree().root.add_child(current_level)

#Erase and remove the current level
func erase_level():
	get_tree().root.remove_child(current_level)
	current_level.queue_free()

#Switches the player control into a new character
func switch_player_host(new_host):
	PlayerInput.control = new_host

#Finish the level
func finish_level():
	var finished_screen = LevelFinishedScreen.instance()
	var _error
	_error = finished_screen.connect("retry", self, "reload_level")
	_error = finished_screen.connect("next", self, "load_next_level")
	_error = finished_screen.connect("menu", self, "close")
	current_level.add_child(finished_screen)
	finished_screen.set_result(current_level.object_number, current_level.objects_dimmed)

func reload_level():
	erase_level()
	load_level()

func load_next_level():
	erase_level()
	self.level_number += 1
	load_level()

func close():
	#Just erase everything for now
	current_level.queue_free()
	PlayerInput.queue_free()
	self.queue_free()

func set_level_number(num):
	if num <= Constants.LEVELS: #If level X exists
		level_number = num
	else:
		level_number = 1
	LevelPackedScene = load("res://Source/Scenes/Levels/Level" + str(level_number) + ".tscn") #Get level scene

#Add object to the current level objectives
func add_object_to_level(o):
	current_level.add_object(o)

#Remove object from the current level objectives
func remove_object_from_level(o):
	current_level.remove_object(o)
