extends RichTextLabel

@onready var panel: CanvasLayer = $"../CanvasLayer"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if (Input.is_action_just_pressed("show_controls")):
		panel.visible = true

	if (Input.is_action_just_released("show_controls")):
		panel.visible = false
