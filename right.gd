extends XRController3D
class_name Rot


@export var rotation_smooth_factor: float = 0.1
@export var ball:Node3D
@export var target: Node3D

func _physics_process(delta: float) -> void:
	
	if target:
		
		
		var a=Quaternion(transform.basis)
		var b=Quaternion(target.transform.basis)
		if not get_parent().current:
			return
			var d=Quaternion(ball.transform.basis)
			a-=d
		var c= b.slerp(a,1*delta)
		target.next_rot=Basis(c)
	
