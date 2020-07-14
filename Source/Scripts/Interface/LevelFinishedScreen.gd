extends CanvasLayer

onready var label = $Panel/Label
onready var retry_button = $Panel/RetryButton
onready var next_button = $Panel/NextButton
onready var menu_button = $Panel/MenuButton

signal retry
signal next
signal menu

func set_result(num_objects, dim_num):
	var ratio = stepify((float(dim_num) / float(num_objects)) * 100, 0.01) #Ratio of objects dimmed in level
	label.text = "You have dimmed " + str(ratio) + "% of the world."
	if ratio == 100:
		next_button.disabled = false

func _on_RetryButton_pressed():
	emit_signal("retry")

func _on_NextButton_pressed():
	emit_signal("next")

func _on_MenuButton_pressed():
	emit_signal("menu")
