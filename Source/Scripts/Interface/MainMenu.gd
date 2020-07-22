extends Control

onready var game_panel = $GamePanel
onready var help_panel = $HelpPanel

var menu_music = load("res://Resources/Audio/Music/Dark Fog-Loop.ogg")

func _ready():
	AudioPlayer.play_music(menu_music)
	AudioPlayer.music_pitch = 1

func _on_StartButton_pressed():
	get_tree().root.remove_child(self)
	Main.load_level(2020)

func _on_OptionsButton_pressed():
	var settings_menu = Helper.SettingsMenu.instance()
	settings_menu.parent_menu = self
	add_child(settings_menu)

func _on_HelpButton_pressed():
	game_panel.visible = false
	help_panel.visible = true

func _on_QuitButton_pressed():
	get_tree().quit()

func _exit_tree():
	queue_free()

func _on_BackButton_pressed():
	game_panel.visible = true
	help_panel.visible = false
