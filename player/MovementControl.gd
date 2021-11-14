extends Spatial

export (NodePath) var left_hand
export (NodePath) var right_hand
export (NodePath) var origin

export var reset_button = 7
export var gravity = 9.8

onready var left_hand_node = get_node(left_hand) if left_hand else null
onready var right_hand_node = get_node(right_hand) if right_hand else null
onready var origin_node = get_node(origin) if origin else null

var left_hand_is_holding = false
var left_hand_last_position : Vector3
var right_hand_is_holding = false
var right_hand_last_position : Vector3
var fall_velocity : float = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var delta_movement : Vector3
	var hands_holding = 0
	
	# check our left hand first
	if left_hand_node:
		var is_holding = left_hand_node.get_is_holding()
		if left_hand_is_holding != is_holding:
			left_hand_is_holding = is_holding
		elif left_hand_is_holding:
			# we skip the first frame we're holding because we don't have our last position
			delta_movement += left_hand_node.global_transform.origin - left_hand_last_position
			hands_holding = hands_holding + 1

	# check our right hand first
	if right_hand_node:
		var is_holding = right_hand_node.get_is_holding()
		if right_hand_is_holding != is_holding:
			right_hand_is_holding = is_holding
		elif right_hand_is_holding:
			# we skip the first frame we're holding because we don't have our last position
			delta_movement += right_hand_node.global_transform.origin - right_hand_last_position
			hands_holding = hands_holding + 1

	if origin_node:
		# are we holding atleast one hand? then adjust our origin point accordingly
		if hands_holding > 0:
			# get our average
			delta_movement = delta_movement / hands_holding
		
			# move our origin
			origin_node.global_transform.origin -= delta_movement
			
			# move any hand anchor that is currently holding
			if left_hand_is_holding:
				var anchor = left_hand_node.get_node("HandAnchor")
				if anchor:
					anchor.global_transform.origin += delta_movement

			if right_hand_is_holding:
				var anchor = right_hand_node.get_node("HandAnchor")
				if anchor:
					anchor.global_transform.origin += delta_movement
			
			fall_velocity = 0.0
		else:
			# apply gravity to our origin point
			var y = origin_node.global_transform.origin.y
			
			fall_velocity += delta * gravity
			y -= fall_velocity * delta
			if y < 0:
				# should check if we hit the ground hard enough that we died....
				y = 0
			
			origin_node.global_transform.origin.y = y

	if left_hand_is_holding:
		left_hand_last_position = left_hand_node.global_transform.origin

	if right_hand_is_holding:
		right_hand_last_position = right_hand_node.global_transform.origin

func _on_RightHandController_button_pressed(button):
	if button == reset_button:
		$RecenterTimer.start()

func _on_RightHandController_button_release(button):
	if button == reset_button:
		$RecenterTimer.stop()

func _on_RecenterTimer_timeout():
	ARVRServer.center_on_hmd(ARVRServer.RESET_BUT_KEEP_TILT, true)
