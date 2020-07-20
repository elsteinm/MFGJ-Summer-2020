extends CanvasLayer

signal unpause(screen)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		emit_signal("unpause", self)
