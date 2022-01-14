extends Spatial

func _input(event):
	if event is InputEventKey and event.scancode == KEY_ESCAPE:
		get_tree().quit()
		
