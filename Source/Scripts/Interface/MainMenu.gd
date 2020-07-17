extends Control

func _on_StartButton_pressed():
	get_tree().root.remove_child(self)
	Main.load_level(1)

func _on_HelpButton_pressed():
	$HelpPanel.visible = true

func _on_QuitButton_pressed():
	get_tree().quit()

func _exit_tree():
	queue_free()

func _on_BackButton_pressed():
	$HelpPanel.visible = false
