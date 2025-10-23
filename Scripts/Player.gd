extends CharacterBody2D

# Constantes
const SPEED = 200.0
const JUMP_VELOCITY = -300.0
const MAX_JUMPS = 2

# Variables externas
@onready var animationPlayer = $AnimatedSprite2D
@export var atacar: bool = false

# --- VARIABLES AÑADIDAS ---
var normal_speed = SPEED
var current_speed = SPEED

# Variable externa contador de saltos
var jump_count = 0

# Función de gravedad
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Variables
	# Entrada de movimiento Izquierda y Derecha
	var direction := Input.get_axis("Izquierda", "Derecha")
	if !atacar:
		if direction:
			# --- CAMBIO AQUÍ ---
			velocity.x = direction * current_speed
		else:
			velocity.x = move_toward(velocity.x, 0, current_speed)
		
		# Entrada de movimientos Salto doble
		if is_on_floor():
			jump_count = 0
		if Input.is_action_just_pressed("ui_accept") and jump_count < MAX_JUMPS:
			velocity.y = JUMP_VELOCITY
			jump_count += 1
		
		if Input.is_action_just_pressed("Ataque"):
			atacar = true
		move_and_slide()
	else:
		animationPlayer.play("Ataque1")
		await (animationPlayer.animation_finished)
		atacar = false

	# Llamar la función animaciones (No Tocar)
	animations(direction)
		
	# Dirección del sprite (No Tocar)
	if direction == 1:
		animationPlayer.flip_h = false

	elif direction == -1:
		animationPlayer.flip_h = true

func animations(direction):
	# En suelo
	if is_on_floor():
		if direction == 0:
			animationPlayer.play("Idle")
			
		else:
			animationPlayer.play("Run")
	# En aire
	else:
		if velocity.y < 0:
			animationPlayer.play("Jump")
			# Animación de caída luego del doble salto
			if jump_count == 2 and velocity.y > -30:
				animationPlayer.play("Fall")





func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == self:
		print("Entró en zona lenta")
		# Reduce la velocidad
		current_speed = 100.0

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == self:
		print("Salió de zona lenta")
		# Restaura la velocidad normal
		current_speed = normal_speed
		
func _on_cambio_escenario_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Scenes/scene2.tscn")
