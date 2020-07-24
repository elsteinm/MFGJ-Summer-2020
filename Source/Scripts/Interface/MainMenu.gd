extends Control

onready var game_panel = $GamePanel
onready var help_panel = $HelpPanel
onready var credits_panel = $CreditsPanel

onready var control_grid = $HelpPanel/ControlGrid

var menu_music = load("res://Resources/Audio/Music/Dark Fog-Loop.ogg")

func _ready():
	AudioPlayer.play_music(menu_music)
	AudioPlayer.music_pitch = 1

func _on_StartButton_pressed():
	var level_select_menu = Helper.LevelSelectMenu.instance()
	level_select_menu.parent_menu = self
	add_child(level_select_menu)

func _on_SettingsButton_pressed():
	var settings_menu = Helper.SettingsMenu.instance()
	settings_menu.parent_menu = self
	add_child(settings_menu)

func _on_HelpButton_pressed():
	game_panel.visible = false
	credits_panel.visible = false
	help_panel.visible = true
	for child in control_grid.get_children():
		control_grid.remove_child(child)
		child.queue_free()
	for command in Settings.controls.keys():
		var ctrl = Settings.controls[command]
		var control_label = Label.new()
		control_label.text = ctrl
		control_label.align = Label.ALIGN_CENTER
		control_label.valign = Label.ALIGN_CENTER
		control_grid.add_child(control_label)
		var com_name = Helper.command_names[command]
		var command_label = Label.new()
		command_label.text = com_name
		command_label.align = Label.ALIGN_CENTER
		command_label.valign = Label.ALIGN_CENTER
		control_grid.add_child(command_label)

func _on_CreditsButton_pressed():
	game_panel.visible = false
	help_panel.visible = false
	credits_panel.visible = true

func _on_QuitButton_pressed():
	get_tree().quit()

func _exit_tree():
	queue_free()

func _on_BackButton_pressed():
	game_panel.visible = true
	help_panel.visible = false
	credits_panel.visible = false
