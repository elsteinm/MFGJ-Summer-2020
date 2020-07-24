extends CanvasLayer

onready var label = $Panel/Label
onready var retry_button = $Panel/RetryButton
onready var next_button = $Panel/NextButton
onready var menu_button = $Panel/MenuButton

signal retry
signal next
signal menu

func set_result(progress, time, completed):
	label.text = "You have dimmed " + progress + " objects in the world in " + time
	if completed == true:
		label.text += "\n\nWORLD HAS BEEN DIMMED"
		next_button.disabled = false

func _on_RetryButton_pressed():
	emit_signal("retry")

func _on_NextButton_pressed():
	emit_signal("next")

func _on_MenuButton_pressed():
	emit_signal("menu")

func _exit_tree():
	queue_free()
