extends Camera3D

@export var mirrorPosition: Node3D

func _process(delta: float) -> void:
	if not mirrorPosition:
		return

	global_transform = mirrorPosition.global_transform