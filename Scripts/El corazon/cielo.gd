extends ParallaxLayer

# Velocidad de movimiento de esta capa
@export var velocidad_movimiento = 50

# Ancho de la textura de esta capa (ajusta este valor)
@export var ancho_imagen = 642

func _process(delta):
	# Mueve la capa
	motion_offset.x -= velocidad_movimiento * delta

	# Si la capa se ha movido completamente fuera de la pantalla,
	# la teletransportamos de vuelta al inicio.
	if motion_offset.x <= -ancho_imagen:
		motion_offset.x += ancho_imagen
