extends Node3D

@export var ingredient:PackedScene
@onready var timer: Timer = $Timer
@onready var spawnLocation: Node3D = $"Spawn Location"
var currentIngredient:Node3D = null

func _ready() -> void:
	timer.timeout.connect(spawnIngredient)
	spawnIngredient()
	
func spawnIngredient():
	currentIngredient = ingredient.instantiate()
	currentIngredient.collected.connect(ingredientCollected)

	get_tree().root.add_child.call_deferred(currentIngredient)
	currentIngredient.global_transform = spawnLocation.global_transform
	
func ingredientCollected():
	currentIngredient = null
	timer.start()
