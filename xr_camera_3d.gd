extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	return
	global_transform=Transform3D(transform.basis,Vector3(0,0,0))
	
	print(transform)
	pass
