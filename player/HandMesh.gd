extends MeshInstance

export var grab = 0.0 setget set_grab

func set_grab(p_grab):
	grab = p_grab
	if is_inside_tree():
		_update_grab()

func _update_grab():
	$AnimationTree.set("parameters/Blend2/blend_amount", grab)

# Called when the node enters the scene tree for the first time.
func _ready():
	_update_grab()

