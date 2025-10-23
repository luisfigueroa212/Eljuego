extends ParallaxLayer

@export var cloud_speed: float = -75.0

func _process(delta: float) -> void:

	motion_offset.x += cloud_speed * delta
	
