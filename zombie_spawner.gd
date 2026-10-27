extends Node3D

@export var zombie:PackedScene
@onready var timer: Timer = $Timer
@onready var spawnLocation: Node3D = $"Spawn Location"

func _ready() -> void:
	timer.timeout.connect(spawnZombie)
	spawnZombie()

func spawnZombie():
	var newZombie: Node = zombie.instantiate()

	get_tree().root.add_child.call_deferred(newZombie)
	newZombie.global_transform = spawnLocation.global_transform
	timer.start()
