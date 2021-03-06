extends Node

enum DisplayMode {
	WINDOWED,
	FULLSCREEN
}

enum ControlType {
	KEYBOARD_MOUSE
	KEYBOARD
}

var config_file = "user://game_settings.cfg"
var config = ConfigFile.new()

#Display settings
var display_mode setget set_display_mode
var borderless setget set_borderless

#Audio settings
var master_volume setget set_master_volume
var music_volume setget set_music_volume
var sfx_volume setget set_sfx_volume

#Control settings
var control_type setget set_control_type
var controls = {
	Helper.Commands.MOVE: "",
	Helper.Commands.DIM: "",
	Helper.Commands.CHANGE: "",
	Helper.Commands.AIM: "",
	Helper.Commands.PAUSE: ""
}

func _ready():
	controls[Helper.Commands.MOVE] = "WASD"
	controls[Helper.Commands.PAUSE] = "ESC"
	var err = config.load(config_file)
	if err != OK:
		err = config.save(config_file)
		err = config.load(config_file)
	self.display_mode = config.get_value("Display Settings", "display_mode", DisplayMode.WINDOWED)
	self.borderless = config.get_value("Display Settings", "borderless", false)
	self.master_volume = config.get_value("Audio Settings", "master_volume", 100)
	self.music_volume = config.get_value("Audio Settings", "music_volume", 100)
	self.sfx_volume = config.get_value("Audio Settings", "sfx_volume", 100)
	self.control_type = config.get_value("Control Settings", "control_type", ControlType.KEYBOARD_MOUSE)

func set_display_mode(value):
	display_mode = value
	match display_mode:
		DisplayMode.WINDOWED:
			OS.window_fullscreen = false
		DisplayMode.FULLSCREEN:
			OS.window_fullscreen = true
	config.set_value("Display Settings", "display_mode", display_mode)

func set_borderless(value):
	borderless = value
	OS.window_borderless = borderless
	config.set_value("Display Settings", "borderless", borderless)

func set_master_volume(value):
	master_volume = value
	AudioPlayer.set_master_volume(float(master_volume)/float(100))
	config.set_value("Audio Settings", "master_volume", master_volume)

func set_music_volume(value):
	music_volume = value
	AudioPlayer.set_music_volume(float(music_volume)/float(100))
	config.set_value("Audio Settings", "music_volume", music_volume)

func set_sfx_volume(value):
	sfx_volume = value
	AudioPlayer.set_sfx_volume(float(sfx_volume)/float(100))
	config.set_value("Audio Settings", "sfx_volume", sfx_volume)

func set_control_type(value):
	control_type = value
	match control_type:
		ControlType.KEYBOARD_MOUSE:
			controls[Helper.Commands.DIM] = "Right Click"
			controls[Helper.Commands.CHANGE] = "Left Click"
			controls[Helper.Commands.AIM] = "Move Mouse"
		ControlType.KEYBOARD:
			controls[Helper.Commands.DIM] = "Shift"
			controls[Helper.Commands.CHANGE] = "Space"
			controls[Helper.Commands.AIM] = "Arrow Keys"
	config.set_value("Control Settings", "control_type", control_type)
	update_input_map()

func save_settings():
	config.save(config_file)

func update_input_map():
	if control_type == ControlType.KEYBOARD:
		var change_key = InputEventKey.new()
		change_key.scancode = KEY_SPACE
		change_mapping_of_action("p_action", change_key)
		var dim_key = InputEventKey.new()
		dim_key.scancode = KEY_SHIFT
		change_mapping_of_action("p_turn_off", dim_key)
	elif control_type == ControlType.KEYBOARD_MOUSE:
		var change_key = InputEventMouseButton.new()
		change_key.button_index = BUTTON_LEFT
		change_mapping_of_action("p_action", change_key)
		var dim_key = InputEventMouseButton.new()
		dim_key.button_index = BUTTON_RIGHT
		change_mapping_of_action("p_turn_off", dim_key)

func change_mapping_of_action(action,key):
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action,key)
