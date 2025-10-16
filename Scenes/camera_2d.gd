extends Camera2D

# En el editor de Godot, arrastra tu nodo Player a esta variable.
@export var target: CharacterBody2D

func _process(delta: float) -> void:
	# Nos aseguramos de que el objetivo (target) exista.
	if target:
		# Creamos una nueva posición para la cámara.
		var new_position = global_position

		# Copiamos ÚNICAMENTE la posición X del jugador.
		new_position.x = target.global_position.x

		# Aplicamos la nueva posición a la cámara. La posición Y no se toca.
		global_position = new_position
