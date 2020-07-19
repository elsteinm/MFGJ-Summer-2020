extends CanvasLayer

onready var label = $Panel/Label
onready var retry_button = $Panel/RetryButton
onready var menu_button = $Panel/MenuButton

signal retry
signal menu

func _on_RetryButton_pressed():
	emit_signal("retry")

func _on_MenuButton_pressed():
	emit_signal("menu")

func _exit_tree():
	queue_free()
