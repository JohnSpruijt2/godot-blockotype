extends CharacterBody3D

@export var health: float = 100.0
@onready var healthLabel = $"../CanvasLayer/BossHealth"
@export var movement_speed: float = 8.0
var movement_target_position: Vector3 = Vector3(-3.0,0.0,2.0)

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var upAttackArea : Node3D = $upAttackArea
@onready var player: Node = get_tree().get_first_node_in_group("player")
@onready var upAttackTimer : Timer = $"upAttackArea/UpAttackTimer"
const PILLAR_SCENE: PackedScene = preload("res://up_attack.tscn")

func _ready():
	updateHealthBar()

	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 0.5
	navigation_agent.target_desired_distance = 0.5

	# Make sure to not await during _ready.
	actor_setup.call_deferred()

func take_damage(damage):
	health -= damage
	updateHealthBar()
	
	if (health <= 0):
		queue_free()

func updateHealthBar():
	healthLabel.text = "Boss health: " + str(health)

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(movement_target_position)

func _process(_delta: float) -> void:
	set_movement_target(player.global_position)

func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)

func _physics_process(delta):
	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()

	var direction: Vector3 = current_agent_position.direction_to(next_path_position)
	velocity = direction * movement_speed

	if direction.length_squared() > 0.001:
		# Flattens the Y axis so the boss doesn't tilt up/down
		var look_target: Vector3 = global_position - Vector3(direction.x, 0, direction.z)
		look_at(look_target, Vector3.UP)
	
	move_and_slide()

	# for i in range(get_slide_collision_count()):
	# 	var collision: KinematicCollision3D = get_slide_collision(i)
	# 	var collider: Object = collision.get_collider()
	# 
	# 	# Check if we hit the player vehicle
	# 	if collider is VehicleBody3D:

func _on_attack_area_entered(body: Node3D) -> void:
	if body.is_in_group("player") and upAttackTimer.is_stopped():
		upAttackTimer.start()
		var pillar: Node = PILLAR_SCENE.instantiate()
		get_parent().add_child(pillar)
	
		# Set the pillar's root position on the ground where the player is standing
		pillar.global_position = upAttackArea.global_position
