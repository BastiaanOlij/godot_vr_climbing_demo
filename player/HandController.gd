extends "res://addons/godot-openxr/scenes/controller.gd"

export var grip_button = 2
export var grip_axis = 4

var nearest_handheld : HandHeld
var is_holding = false
onready var source_transform = $HandAnchor.transform

func get_is_holding() -> bool:
	return is_holding

# Called when the node enters the scene tree for the first time.
func _ready():
	_check_closes_handheld()

func _process(delta):
	is_holding = false
	if nearest_handheld:
		var hand_held_anchor : Transform = nearest_handheld.get_hand_anchor(controller_id)
		
		# convert this to our local space
		hand_held_anchor = global_transform.inverse() * hand_held_anchor
		
		if is_button_pressed(grip_button):
			# if grip is true place hand anchor on handheld and close hand
			$HandAnchor.transform = hand_held_anchor
			$HandAnchor/HandMesh.grab = 1.0
			is_holding = true
		else:
			# else position hand anchor between hand and handheld to simulate magnet
			var distance = (source_transform.origin - hand_held_anchor.origin).length()
			var factor = distance / $HandDetector.radius
			$HandAnchor.transform = hand_held_anchor.interpolate_with(source_transform, factor)
			
			# and animate hand based on grip analogue input
			$HandAnchor/HandMesh.grab = get_joystick_axis(grip_axis)
		pass
	else:
		# place our hand anchor in our original position
		$HandAnchor.transform = source_transform
		
		# animate hand based on grip analogue input
		$HandAnchor/HandMesh.grab = get_joystick_axis(grip_axis)

func _check_closes_handheld():
	# Our hand detector should only find hand helds as it is only checking physics layer 2
	var in_area : Array = $HandDetector.get_overlapping_bodies()
	if in_area.empty():
		nearest_handheld = null
	else:
		var closest_distance = 1000.0
		var hand_origin : Vector3 = global_transform.origin
		for handheld in in_area:
			var distance = (handheld.global_transform.origin - hand_origin).length()
			if distance < closest_distance:
				nearest_handheld = handheld
				closest_distance = distance

func _on_handheld_entered(body):
	_check_closes_handheld()

func _on_handheld_exited(body):
	_check_closes_handheld()
