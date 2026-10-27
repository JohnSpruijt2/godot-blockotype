extends VehicleBody3D

@export var max_rpm: int = 450
@export var max_torque: int = 300
@export var turn_speed: int = 3
@export var turn_amount: float = .3
@export var canon_turn_speed: int = 3
@export var bulletAmount: int = 5
@export var rawChickenAmount: int = 3
@export var rawDrumStickAmount: int = 0
var bullet: PackedScene = preload("res://bullet.tscn")
@onready var bulletSpawnPoint: Node3D = $CSGBox3D2/CSGCylinder3D/bulletSpawnPoint
@onready var ammoCounter: RichTextLabel = $"CanvasLayer/Ammo Counter"
@onready var rawChickenCounter: RichTextLabel = $"CanvasLayer/Raw Chicken Counter"
@onready var rawDrumStickCounter: RichTextLabel = $"CanvasLayer/Raw Drumstick Counter"
@onready var canon: CSGCylinder3D = $CSGBox3D2/CSGCylinder3D
@onready var wheels: Array[Node] = [
	$LeftBackWheel,
	$LeftFrontWheel,
	$RightBackWheel,
	$RightFrontWheel
]
@onready var zombies: Dictionary[String, CSGBox3D] = {
	"left_back" = $Zombies/ZombieLeftBack,
	"middle_back" = $Zombies/ZombieMiddleBack,
	"right_back" = $Zombies/ZombieRightBack,
	"left_center" = $Zombies/ZombieLeftCenter,
	"right_center" = $Zombies/ZombieRightCenter
}
@onready var zombieBlood: Dictionary[String, GPUParticles3D] = {
	"left_back" = $Zombies/BloodLeftBack,
	"middle_back" = $Zombies/BloodMiddleBack,
	"right_back" = $Zombies/BloodRightBack,
	"left_center" = $Zombies/BloodLeftCenter,
	"right_center" = $Zombies/BloodRightCenter
}
@onready var doorLeft: Node3D = $"CSGBox3D/Door left hinge/DoorLeft"
@onready var doorRight: Node3D = $"CSGBox3D/Door Right hinge/DoorRight"

var zombieStates: Dictionary[String, bool] = {
	"left_back" = false,
	"middle_back" = false,
	"right_back" = false,
	"left_center" = false,
	"right_center" = false
}
@export var jump_force: float = 500.0

func _ready() -> void:
	update_ammo()
	update_raw_chicken()
	updateZombies()

func _physics_process(delta: float) -> void:
	var dir: float = Input.get_action_strength("move_forward") - Input.get_action_strength("move_back")
	var steering_dir: float = Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
	
	var rpm_left = abs($LeftBackWheel.get_rpm())
	var rpm_right = abs($RightBackWheel.get_rpm())
	var rpm = (rpm_left + rpm_right) / 2.0
	
	var torque = dir * max_torque * (1.0 - rpm / max_rpm)
	
	engine_force = torque
	steering = lerp(steering, steering_dir * turn_amount, turn_speed * delta)
	
	if (dir == 0):
		brake = 2;
		
	
	if (Input.is_action_pressed("turn_canon_left")):
		canon.rotation.y = clamp(canon.rotation.y + canon_turn_speed * delta, -.8, .8)
	if (Input.is_action_pressed("turn_canon_right")):
		canon.rotation.y = clamp(canon.rotation.y - canon_turn_speed * delta, -.8, .8)

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("shoot") and bulletAmount > 0):
		var bulletInstance: Node = bullet.instantiate();
		get_tree().root.add_child.call_deferred(bulletInstance)
		bulletInstance.global_transform = bulletSpawnPoint.global_transform
		bulletAmount -= 1
		
		update_ammo()
	
	if (event.is_action_pressed("jump")):
		jump()
		
	if (event.is_action_pressed("spawn_zombie_left_back")):
		zombieStates["left_back"] = true
		updateZombies()
	elif (event.is_action_pressed("spawn_zombie_middle_back")):
		zombieStates["middle_back"] = true
		updateZombies()
	elif (event.is_action_pressed("spawn_zombie_right_back")):
		zombieStates["right_back"] = true
		updateZombies()
	elif (event.is_action_pressed("spawn_zombie_left_center")):
		zombieStates["left_center"] = true
		updateZombies()
	elif (event.is_action_pressed("spawn_zombie_right_center")):
		zombieStates["right_center"] = true
		updateZombies()
		
func chop_chicken(amount: int = 1):
	if (rawChickenAmount > 0):
		rawDrumStickAmount += amount
		rawChickenAmount -= amount
		update_raw_drumstick()
		update_raw_chicken()

func add_ammo(amount: int = 1) -> void:
	if (rawDrumStickAmount > 0):
		bulletAmount += amount
		rawDrumStickAmount -= amount
		update_ammo()
		update_raw_drumstick()


func update_ammo():
	ammoCounter.text = "Ammo: " + str(bulletAmount)

func update_raw_chicken():
	rawChickenCounter.text = "Raw Chicken: " + str(rawChickenAmount)
	
func update_raw_drumstick():
	rawDrumStickCounter.text = "Raw DrumSticks: " + str(rawDrumStickAmount)
	
func add_ingredient(amount: int = 1):
	rawChickenAmount += amount
	update_raw_chicken()

func kicked(location):
	zombieStates[location+"_back"] = false
	updateZombies()
	if (location == "left"):
		doorLeft.kick()
	elif (location == "middle"):
		doorLeft.kick(true)
		doorRight.kick(true)
	elif (location == "right"):
		doorRight.kick()

func updateZombies():
	for zombie in zombieStates:
		if (zombies[zombie].visible and !zombieStates[zombie]):
			zombieBlood[zombie].emitting = true
		zombies[zombie].visible = zombieStates[zombie]
		

func doorKill(rightDoor: bool):
	if (rightDoor):
		zombieStates["right_center"] = false
	else:
		zombieStates["left_center"] = false
	updateZombies()

func attachZombie(zombiePosition: Vector3):
	var local_pos: Vector3 = to_local(zombiePosition)
	if abs(local_pos.z) > abs(local_pos.x):
		# Front or Rear
		if (local_pos.z > 0 and engine_force > 0):
			return
		else:
			var nonActiveSpots: Array[String] = []
			if (!zombieStates["left_back"]):
				nonActiveSpots.push_back("left_back")
			if (!zombieStates["middle_back"]):
				nonActiveSpots.push_back("middle_back")
			if (!zombieStates["right_back"]):
				nonActiveSpots.push_back("right_back")
			if (nonActiveSpots.size() == 0):
				return
			
			zombieStates[nonActiveSpots.pick_random()] = true
			
	else:
		# Left or Right
		if local_pos.x < 0:
			zombieStates["right_center"] = true
		else:
			zombieStates["left_center"] = true
	
	updateZombies()

func jump():
	if is_on_floor():
		apply_central_impulse(Vector3.UP * jump_force)

func is_on_floor() -> bool:
	for wheel in wheels:
		if wheel is VehicleWheel3D and wheel.is_in_contact():
			return true
	return false

func launch_upwards(force: float) -> void:
	apply_central_impulse(Vector3.UP * force)