extends Node3D

@export var pillar_height: float = 4.0      # How tall the pillar rises
@export var rise_duration: float = 0.15     # Speed of the burst upward
@export var hold_duration: float = 1.0      # How long it stays fully up
@export var damage_amount: int = 25
@export var launch_force: float = 1600.0

@onready var area_3d: Area3D = $Area3D

func _ready() -> void:
	# Connect the collision signal
	area_3d.body_entered.connect(_on_body_entered)

	# 1. Start hidden underground
	area_3d.position.y = -pillar_height

	# 2. Animate the burst upward using a Tween
	var tween := create_tween()

	# Easing back out gives it an impactful "punch" when it stops at top height
	tween.tween_property(area_3d, "position:y", 0.0, rise_duration)\
			.set_trans(Tween.TRANS_BACK)\
			.set_ease(Tween.EASE_OUT)

	# 3. Wait for hold_duration, then delete the pillar scene
	tween.tween_interval(hold_duration)
	tween.tween_callback(queue_free)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		print("Pillar struck the player!")
		if body.has_method("take_damage"):
			body.take_damage(damage_amount)
		if body.has_method("launch_upwards"):
			body.launch_upwards(launch_force)
