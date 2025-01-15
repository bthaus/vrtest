extends MeshInstance3D

@export var anti_rot:Node3D
@export var origin:XROrigin3D
@export var ball:Node3D
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	visible=origin.current
	#rotation=anti_rot.rotation*-1
	rotation=ball.rotation+anti_rot.rotation
	pass
