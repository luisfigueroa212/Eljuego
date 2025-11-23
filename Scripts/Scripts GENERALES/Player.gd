extends CharacterBody2D

# Constantes
const SPEED = 200.0
const JUMP_VELOCITY = -300.0
const MAX_JUMPS = 2

# Variables externas
@onready var animationPlayer = $AnimatedSprite2D
@onready var dash_particles = $Dash #PARTICULAS DASH
@export var atacar: bool = false

# --- VARIABLES DE MOVIMIENTO ---
var normal_speed = SPEED
var current_speed = SPEED
var jump_count = 0

# --- NUEVO DASH: Variables de Configuración ---
@export var dash_speed: float = 400.0   # Velocidad del impulso
@export var dash_duration: float = 0.3  # Cuánto dura el impulso (segundos)
@export var dash_cooldown: float = 0.5  # Tiempo de espera para volver a usarlo
var is_dashing: bool = false            # ¿Estamos dashando ahora?
var can_dash: bool = true               # ¿Podemos usar el dash?
var is_in_dialogue: bool = false

func _ready():
	print("Player listo")
	Dialogic.timeline_ended.connect(func():
		print("✅ FIN DE DIÁLOGO DETECTADO - Desbloqueando controles")
		is_in_dialogue = false
	)

func _physics_process(delta: float) -> void:
	if is_dashing:
		move_and_slide()
		return # Salimos de la función aquí para no procesar gravedad ni teclas
	# --------------------------------------
	# Gravedad normal
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if is_in_dialogue:
			velocity.x = 0         # Aseguramos que no se deslice
			move_and_slide()       # Aplicamos gravedad
			return                 # ¡STOP! No leemos teclas

	# Variables
	var direction := Input.get_axis("Izquierda", "Derecha")
	
	if !atacar:
	
		if Input.is_action_just_pressed("Dash") and can_dash:
			start_dash(direction)
			return
		# ------------------------------
		if direction:
			velocity.x = direction * current_speed
		else:
			velocity.x = move_toward(velocity.x, 0, current_speed)
		
		# Salto doble
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

	# Llamar la función animaciones
	animations(direction)
		
	# Dirección del sprite
	if not is_dashing: 
		if direction == 1:
			animationPlayer.flip_h = false
		elif direction == -1:
			animationPlayer.flip_h = true

# --- NUEVO DASH: Función de Control ---
func start_dash(input_direction: float):
	is_dashing = true
	can_dash = false
	
	dash_particles.emitting = true #PARTICULAS DASH
	# Determinar la dirección del dash
	var dash_dir = input_direction
	
	# Si el jugador no está presionando nada, usar hacia donde mira el sprite
	if dash_dir == 0:
		if animationPlayer.flip_h: # Si mira a la izquierda
			dash_dir = -1
		else: # Si mira a la derecha
			dash_dir = 1
			
	# Aplicar la velocidad de Dash (solo en horizontal, y quitamos vertical)
	velocity.x = dash_dir * dash_speed
	velocity.y = 0 # Opcional: Para que no caiga mientras dasha
	
	# Reproducir animación de Dash (si la tienes, si no, usa Run o Jump)
	#animationPlayer.play("Dash") 
	
	# Esperar la duración del dash
	await get_tree().create_timer(dash_duration).timeout
	
	dash_particles.emitting = false #PARTICULAS DASH
	# Termina el dash
	is_dashing = false
	velocity.x = 0 # Frenar un poco al terminar (opcional)
	
	# Esperar el enfriamiento (Cooldown)
	await get_tree().create_timer(dash_cooldown).timeout
	can_dash = true
	print("Dash listo de nuevo")

# --------------------------------------

func animations(direction):
	if is_dashing: return # No cambiar animaciones si estamos dashando
	
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
			if jump_count == 2 and velocity.y > -30:
				animationPlayer.play("Fall")


func _on_area_2d_body_entered(body: Node2D) -> void:
		SceneTransitioner.transition_to_scene("res://Scenes/elcorazon.tscn")
