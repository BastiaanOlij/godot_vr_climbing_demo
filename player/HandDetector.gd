extends Area

export var radius = 0.3 setget set_radius

func set_radius(p_new_radius):
	radius = p_new_radius
	if is_inside_tree():
		_update_radius()

func _update_radius():
	var sphere_shape : SphereShape = $CollisionShape.shape
	sphere_shape.radius = radius

# Called when the node enters the scene tree for the first time.
func _ready():
	_update_radius()
