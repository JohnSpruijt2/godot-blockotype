extends Area3D

signal collected
@export var speed : float = 15

func _ready():
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if body.has_method("add_ingredient"):
		body.add_ingredient(1)
		collected.emit()
		queue_free()
