extends StaticBody

class_name HandHeld

func get_hand_anchor(for_controller) -> Transform:
	if for_controller == 1:
		return $LeftHandAnchor.global_transform
	if for_controller == 2:
		return $RightHandAnchor.global_transform
	
	return Transform()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
