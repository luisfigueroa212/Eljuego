extends CharacterBody2D

@onready var sangre = $Sangre
@onready var sonido_golpe = $SonidoGolpe
@onready var sprite = $AnimatedSprite2D
@onready var anim = $AnimatedSprite2D

func _ready():
	# Le decimos explícitamente qué animación tocar al nacer
	anim.play("Muñeca")

func recibir_dano(cantidad: float):
	print("¡Auch! Me pegaste.")
	
	# 1. Efecto de Sangre
	sangre.restart() # Reinicia las partículas
	sangre.emitting = true
	
	# 2. Sonido
	sonido_golpe.pitch_scale = randf_range(0.9, 1.1) # Variación leve para que no suene robótico
	sonido_golpe.play()
	
	# 3. Feedback Visual (Flash Blanco opcional)
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.RED, 0.1)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)
