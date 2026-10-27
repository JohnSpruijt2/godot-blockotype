extends Node3D

@onready var car: VehicleBody3D = $"../../.."

var door_angle: float = 0.0
var door_velocity: float = 0.0

@export var max_angle: float = 80.0
@export var min_angle: float = -180.0
@export var spring_back: float = 8.0
@export var rightDoor: bool = false
var locked : bool = false

func _process(delta: float) -> void:
	if locked:
		return

	var car_speed: float = car.linear_velocity.length()
	var steering_force: float = -car.steering * car_speed * 200
	door_velocity += steering_force * delta
	door_velocity -= door_angle * spring_back * delta
	door_velocity *= 0.20
	door_angle += door_velocity
	door_angle = clamp(door_angle, min_angle, max_angle)
	rotation.y = deg_to_rad(door_angle)
	
	if ((rightDoor and door_angle > (max_angle - 45)) or (!rightDoor and door_angle < (min_angle + 45))):
		car.doorKill(rightDoor)

	if (rightDoor):
		if (door_angle < (min_angle + 15)):
			locked = true
	else:
		if (door_angle > (max_angle - 15)):
			locked = true
		

func kick(fromMiddle: bool = false):
	if (fromMiddle && !locked):
		return
	
	if (rightDoor):
		if (door_angle > (max_angle - 90)):
			return
		door_angle = max_angle
	else:
		if (door_angle < (min_angle + 90)):
			return
		door_angle = min_angle
	rotation.y = deg_to_rad(door_angle)
	door_velocity = 0.0
	locked = false
