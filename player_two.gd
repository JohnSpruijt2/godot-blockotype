extends Node3D

@export var cookDuration: float = 1.0

@onready var playerTwoLeft: CSGBox3D = $PlayerTwoLeft
@onready var playerTwoMiddle: CSGBox3D = $PlayerTwoMiddle
@onready var playerTwoRight: CSGBox3D = $PlayerTwoRight
@onready var playerTwoLeftKick: CSGBox3D = $PlayerTwoLeft/PlayerTwoLeftKick
@onready var playerTwoMiddleKick: CSGBox3D = $PlayerTwoMiddle/PlayerTwoMiddleKick
@onready var playerTwoRightKick: CSGBox3D = $PlayerTwoRight/PlayerTwoRightKick
var defaultPlayerTwoColor
@onready var car = $".."
var playerTwoLocation: String = "middle"

var cookingTime: float
var choppingProgress: int
@export var choppingLabourIntensity: int = 3

func _ready() -> void:
	playerTwoLeft.visible = false
	playerTwoMiddle.visible = true
	playerTwoRight.visible = false
	playerTwoLeftKick.visible = false
	playerTwoMiddleKick.visible = false
	playerTwoRightKick.visible = false
	defaultPlayerTwoColor = playerTwoLeft.material.albedo_color

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("player_two_left")):
		playerTwoLocation = "left"
		updatePlayerTwo()
	elif (event.is_action_pressed("player_two_middle")):
		playerTwoLocation = "middle"
		updatePlayerTwo()
	elif (event.is_action_pressed("player_two_right")):
		playerTwoLocation = "right"
		updatePlayerTwo()
	
	if (event.is_action_pressed("player_two_kick")):
		kick()
	
	if (event.is_action_released("player_two_kick")):
		resetKick()

	
	
func _process(delta):
	if playerTwoLocation == "left":
		if (Input.is_action_pressed("player_two_cook")):
			cook(delta)
	
		if (Input.is_action_just_released("player_two_cook")):
			resetCook()
	elif playerTwoLocation == "right" and Input.is_action_just_pressed("player_two_cook"):
		chop()
	
	
	
func updatePlayerTwo():
	playerTwoLeft.visible = playerTwoLocation == "left"
	playerTwoMiddle.visible = playerTwoLocation == "middle"
	playerTwoRight.visible = playerTwoLocation == "right"
	resetKick()
	resetCook()
	
func kick():
	if (playerTwoLocation == "left"):
		playerTwoLeftKick.visible = true
		car.kicked("left")
	elif (playerTwoLocation == "middle"):
		playerTwoMiddleKick.visible = true
		car.kicked("middle")
	elif (playerTwoLocation == "right"):
		playerTwoRightKick.visible = true
		car.kicked("right")

func resetKick():
	playerTwoLeftKick.visible = false
	playerTwoMiddleKick.visible = false
	playerTwoRightKick.visible = false
	
func cook(delta):
	if (car.rawDrumStickAmount > 0):
		cookingTime += delta
		var progress: float = cookingTime / cookDuration
		playerTwoLeft.material.albedo_color = defaultPlayerTwoColor.lerp(Color.RED, progress)
		
		if cookingTime >= cookDuration:
			car.add_ammo(1)
			resetCook()
	

func resetCook():
	cookingTime = 0
	playerTwoLeft.material.albedo_color = defaultPlayerTwoColor

func chop():
	if (car.rawChickenAmount > 0):
		print_debug("chop: " + str(choppingProgress + 1))
		choppingProgress += 1
		var progress: float = float(choppingProgress) / float(choppingLabourIntensity)
		playerTwoRight.material.albedo_color = defaultPlayerTwoColor.lerp(Color.HOT_PINK, progress)
		
		if (choppingProgress >= choppingLabourIntensity):
			car.chop_chicken(1)
			choppingProgress = 0
			playerTwoLeft.material.albedo_color = defaultPlayerTwoColor
