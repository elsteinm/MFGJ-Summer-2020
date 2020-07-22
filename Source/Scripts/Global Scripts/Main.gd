extends Node

var LevelPackedScene

var game_paused = false setget set_game_paused
var mouse_control = true

var pause_screen = null

var level_number setget set_level_number
var current_level

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	var _error
	_error = PlayerInput.connect("switch_control", self, "switch_player_host") #Tells the level that the player has changed host
	_error = PlayerInput.connect("finish_level", self, "finish_level") #Tells the level when the player has been turned off
	self.level_number = 2020

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if game_paused == true:
			unpause_game()
		else:
			pause_game()

#Load the level
func load_level(lvl_num):
	self.level_number = lvl_num
	current_level = LevelPackedScene.instance()
	get_tree().root.add_child(current_level)
	current_level.set_tutorial(Helper.level_tutorials[level_number])
	PlayerInput.playing = true
	self.game_paused = false

#Erase and remove the current level
func erase_level():
	get_tree().root.remove_child(current_level)
	PlayerInput.playing = false

#Pauses game
func pause_game():
	pause_screen = Helper.PauseScreen.instance()
	current_level.add_child(pause_screen)
	AudioPlayer.get_node("MusicPlayer").volume_db = -16
	self.game_paused = true

#Unpauses game
func unpause_game():
	current_level.remove_child(pause_screen)
	pause_screen.queue_free()
	AudioPlayer.get_node("MusicPlayer").volume_db = 0
	self.game_paused = false

#Switches the player control into a new character
func switch_player_host(new_host):
	PlayerInput.control = new_host

#Finish the level
func finish_level():
	var finished_screen = Helper.LevelFinishedScreen.instance()
	var _error
	_error = finished_screen.connect("retry", self, "reload_level")
	_error = finished_screen.connect("next", self, "load_next_level")
	_error = finished_screen.connect("menu", self, "load_menu")
	current_level.add_child(finished_screen)
	AudioPlayer.stop_music()
	AudioPlayer.play_effect(Helper.end_level_effect)
	self.game_paused = true
	var level_finished = false
	if current_level.objects_dimmed == current_level.object_number:
		level_finished = true
	finished_screen.set_result(current_level.progress, current_level.time, level_finished)

func game_over():
	var game_over_screen = Helper.GameOverScreen.instance()
	var _error
	_error = game_over_screen.connect("retry", self, "reload_level")
	_error = game_over_screen.connect("menu", self, "load_menu")
	current_level.add_child(game_over_screen)
	AudioPlayer.stop_music()
	AudioPlayer.play_effect(Helper.end_level_effect)
	self.game_paused = true

func reload_level():
	erase_level()
	load_level(level_number)

func load_next_level():
	erase_level()
	self.level_number += 1
	load_level(level_number)

func load_menu():
	erase_level()
	var menu = Helper.MainMenu.instance()
	get_tree().root.add_child(menu)
	get_tree().paused = false

func set_game_paused(value):
	if value == true:
		game_paused = true
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		game_paused = false
		get_tree().paused = false
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func set_level_number(num):
	if num <= Helper.LEVELS: #If level X exists
		level_number = num
	else:
		level_number = 2020
	LevelPackedScene = load("res://Source/Scenes/Levels/Level" + str(level_number) + ".tscn") #Get level scene

#Add object to the current level objectives
func add_object_to_level():
	current_level.add_object()

#Remove object from the current level objectives
func remove_object_from_level():
	current_level.remove_object()

func _exit_tree():
	queue_free()
