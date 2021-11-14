extends Spatial

# Called when the node enters the scene tree for the first time.
func _ready():
	$Player.initialise()

func _input(event):
	if event is InputEventKey and event.scancode == KEY_ESCAPE:
		get_tree().quit()
		
