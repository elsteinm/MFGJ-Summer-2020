extends Control

onready var display_mode_option = $VSplitContainer/TabContainer/Display/DisplayModeOption
onready var borderless_option = $VSplitContainer/TabContainer/Display/BorderlessOption

onready var master_volume_slider = $VSplitContainer/TabContainer/Audio/MasterVolumeSlider
onready var music_volume_slider = $VSplitContainer/TabContainer/Audio/MusicVolumeSlider
onready var sfx_volume_slider = $VSplitContainer/TabContainer/Audio/SFXVolumeSlider

onready var control_type_option = $VSplitContainer/TabContainer/Controls/ControlTypeOption

var parent_menu = null

func _ready():
	display_mode_option.add_item("Windowed", Settings.DisplayMode.WINDOWED)
	display_mode_option.add_item("Fullscreen", Settings.DisplayMode.FULLSCREEN)
	borderless_option.add_item("On", true)
	borderless_option.add_item("Off", false)
	
	control_type_option.add_item("Keyboard & Mouse", Settings.ControlType.KEYBOARD_MOUSE)
	control_type_option.add_item("Just Keyboard", Settings.ControlType.KEYBOARD)
	
	display_mode_option.selected = Settings.display_mode
	borderless_option.selected = Settings.borderless
	
	master_volume_slider.value = Settings.master_volume
	music_volume_slider.value = Settings.music_volume
	sfx_volume_slider.value = Settings.sfx_volume
	
	control_type_option.selected = Settings.control_type

func _on_DisplayModeOption_item_selected(id):
	Settings.display_mode = id

func _on_BorderlessOption_item_selected(id):
	Settings.borderless = id

func _on_MasterVolumeSlider_value_changed(value):
	Settings.master_volume = value

func _on_MusicVolumeSlider_value_changed(value):
	Settings.music_volume = value

func _on_SFXVolumeSlider_value_changed(value):
	Settings.sfx_volume = value

func _on_ControlTypeOption_item_selected(id):
	Settings.control_type = id

func _on_ReturnButton_pressed():
	if parent_menu != null:
		Settings.save_settings()
		parent_menu.remove_child(self)
		queue_free()
