extends Node3D

@export var move_speed: float = 5.0
@export var look_sensitivity: float = 0.1
@export var sprint_multiplier: float = 2.0
@export var locked_height: float = 1.0  # Fixed Y position for the camera
@export var reference_view_direction:Node3D
var rotation_x: float = 0.0
var rotation_y: float = 0.0

func _ready():
	locked_height=position.y
	# Hide the cursor and capture the mouse when the game starts.
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Set the initial locked height
	position.y = locked_height

#func _unhandled_input(event):
	#if event is InputEventMouseMotion:
		## Update camera rotation based on mouse movement
		#rotation_x -= event.relative.y * look_sensitivity
		#rotation_y -= event.relative.x * look_sensitivity
#
		## Clamp the vertical rotation to avoid flipping
		#rotation_x = clamp(rotation_x, -90.0, 90.0)
#
		## Apply rotation to the camera
		#rotation_degrees.x = rotation_x
		#rotation_degrees.y = rotation_y

func _process(delta):
	return
	var camera=$XRCamera3D as XRCamera3D
	
	var speed = move_speed
	if Input.is_action_pressed("sprint"):
		speed *= sprint_multiplier
	
	# WASD movement
	var direction = Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	if Input.is_action_pressed("move_backward"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		direction += transform.basis.x
	if Input.is_action_pressed(&"jump"):
		direction += transform.basis.y
	# Normalize direction to avoid faster diagonal movement
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		

	# Move the camera horizontally, locking the y position
	var new_position = position + direction * speed * delta
	
	#new_position.y = locked_height  # Lock the height
	position = new_position
