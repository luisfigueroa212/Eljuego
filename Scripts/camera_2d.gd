extends Camera2D

@export var target: CharacterBody2D

func _process(delta: float) -> void:
	if target:
		var new_position = global_position

		new_position.x = target.global_position.x

		global_position = new_position
