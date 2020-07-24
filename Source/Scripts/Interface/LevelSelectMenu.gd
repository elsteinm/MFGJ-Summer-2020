extends Control

onready var level_grid = $VBoxContainer/LevelGrid
onready var back_button = $VBoxContainer/BackButton

var parent_menu = null

func _ready():
	for i in range(1, Helper.LEVELS + 1):
		var level_button = Button.new()
		level_button.text = str(i)
		level_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		level_button.size_flags_vertical = Control.SIZE_EXPAND_FILL
		level_button.connect("pressed", self, "load_level", [i])
		level_grid.add_child(level_button)

func load_level(level_num):
	get_tree().root.remove_child(parent_menu)
	Main.load_level(level_num)

func _on_BackButton_pressed():
	if parent_menu != null:
		parent_menu.remove_child(self)
		queue_free()
