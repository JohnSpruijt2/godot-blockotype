extends Node3D

@export var speed : float = 40
@export var damage : float = 10

func _ready():
	$RigidBody3D.linear_velocity = transform.basis.y * speed



func _on_timer_timeout() -> void:
	queue_free.call_deferred()


func _on_rigid_body_3d_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
