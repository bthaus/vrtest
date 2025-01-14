extends RigidBody3D

var next_rot
# Called when the node enters the scene tree for the first time.

var smoothed_target_rotation : Vector3

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	transform.basis=next_rot

	
