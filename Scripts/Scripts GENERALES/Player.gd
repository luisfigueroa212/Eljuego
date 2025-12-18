extends CharacterBody2D

# Constantes
const SPEED = 200.0
const JUMP_VELOCITY = -300.0
const MAX_JUMPS = 2

# Al principio con las variables
@onready var hitbox_ataque = $AnimatedSprite2D/HitboxAtaque # Ajusta la ruta si es necesario
@onready var sonido_espada = $SonidoEspada
@export var atacar: bool = false
@onready var hitbox_colision = %ColisionEspada

@export var attack_cooldown: float = 0.2  # Tiempo de espera entre golpes
var can_attack: bool = true               # ¿Está lista la espada?

# Vida del jugador
@export var max_health: float = 100.0  # Vida máxima
var health: float = 100.0              # Vida actual (empieza llena)
@export var life_steal: float = 5.0
@export var decay_rate: float = 5.0    # Cuánta vida pierdes por segundo
var is_dead: bool = false              # Para saber si ya morimos
@onready var barra_vida_sprite = $CanvasLayer/BarraVidaSprite

# Variables externas
@onready var animationPlayer = $AnimatedSprite2D
@onready var dash_particles = $Dash #PARTICULAS DASH
var infection_active: bool = false  # Por defecto apagada


# --- VARIABLES DE MOVIMIENTO ---
var normal_speed = SPEED
var current_speed = SPEED
var jump_count = 0
var is_invulnerable: bool = false
# --- NUEVO DASH: Variables de Configuración ---
@export var dash_speed: float = 400.0   # Velocidad del impulso
@export var dash_duration: float = 0.3  # Cuánto dura el impulso (segundos)
@export var dash_cooldown: float = 0.5  # Tiempo de espera para volver a usarlo
var is_dashing: bool = false            # ¿Estamos dashando ahora?
var can_dash: bool = true               # ¿Podemos usar el dash?
var is_in_dialogue: bool = false
@export var attack_damage: int = 35

func _ready():
	print("Player listo")
	
	# --- CONEXIONES DE DIÁLOGO ---
	Dialogic.timeline_ended.connect(func():
		print("✅ FIN DE DIÁLOGO - Iniciando cinemática...")
	)
	
	# --- CONEXIONES DE COMBATE ---
	hitbox_colision.disabled = true
	# Recuerda que _controlar_hitbox se encarga también del sonido ahora
	animationPlayer.frame_changed.connect(_controlar_hitbox)
	animationPlayer.animation_finished.connect(func(_anim_name): hitbox_colision.disabled = true)
	hitbox_ataque.body_entered.connect(_on_hitbox_ataque_body_entered)

func _process(delta):
		# --- LÓGICA DE INFECCIÓN (Aquí está la magia) ---
	# Preguntamos al padre (El Nivel) si es peligroso
	var nivel = get_parent()
	
	if nivel.is_in_group("infectado"):
		infection_active = true
		print("⚠️ ZONA PELIGROSA: La infección avanza")
		
		# ¡RECUPERAMOS EL DATO DEL NIVEL!
		# Si el nivel tiene la variable configurada, la copiamos.
		if "nivel_de_infeccion" in nivel:
			decay_rate = nivel.nivel_de_infeccion
			print("Intensidad de la radiación: ", decay_rate)
			
	else:
		infection_active = false
		print("✅ ZONA SEGURA: La infección se detuvo")
		


func _physics_process(delta: float) -> void:
	
	# 1. BLOQUEOS TOTALES
	if is_dead: return

	# Si estamos haciendo Dash (Teleport o movimiento rápido), ignoramos gravedad
	if is_dashing:
		move_and_slide()
		return 

	if not is_on_floor():
		velocity += get_gravity() * delta
	# --------------------------------------------------
	if Input.is_action_just_pressed("Ataque") and can_attack and not is_in_dialogue:
		atacar = true
		ejecutar_ataque()
	
	if infection_active:
		health -= decay_rate * delta
		actualizar_barra_visual()
		
		if health <= 0:
			die()
	# Si estamos en diálogo
	if is_in_dialogue:
		velocity.x = 0
		move_and_slide()
		return

	# --- 3. CONTROLES DEL JUGADOR ---
	
	# A. Detectar INTENTO de ataque
	if Input.is_action_just_pressed("Ataque"):
		
		# GIRO AUTOMÁTICO ANTES DE ATACAR
		var input_dir = Input.get_axis("Izquierda", "Derecha")
		if input_dir != 0:
			if input_dir == 1: # Derecha
				animationPlayer.flip_h = false 
				if has_node("AnimatedSprite2D/HitboxAtaque"):
					$AnimatedSprite2D/HitboxAtaque.position.x = abs($AnimatedSprite2D/HitboxAtaque.position.x)
			elif input_dir == -1: # Izquierda
				animationPlayer.flip_h = true
				if has_node("AnimatedSprite2D/HitboxAtaque"):
					$AnimatedSprite2D/HitboxAtaque.position.x = -abs($AnimatedSprite2D/HitboxAtaque.position.x)
		
		atacar = true
		ejecutar_ataque()
		return 

	# B. Movimiento Horizontal
	var direction := Input.get_axis("Izquierda", "Derecha")
	
	# Dash
	if Input.is_action_just_pressed("Dash") and can_dash:
		start_dash(direction) 
		return

	# Caminar
	if direction:
		velocity.x = direction * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
	
	# C. Saltos
	if is_on_floor():
		jump_count = 0
	if Input.is_action_just_pressed("ui_accept") and jump_count < MAX_JUMPS:
		velocity.y = JUMP_VELOCITY
		jump_count += 1
		
	move_and_slide()

	# --- 4. ANIMACIONES ---
	animations(direction)
		
	if not is_dashing and not atacar: 
		if direction == 1:
			animationPlayer.flip_h = false
			if has_node("AnimatedSprite2D/HitboxAtaque"):
				$AnimatedSprite2D/HitboxAtaque.position.x = abs($AnimatedSprite2D/HitboxAtaque.position.x)
		elif direction == -1:
			animationPlayer.flip_h = true
			if has_node("AnimatedSprite2D/HitboxAtaque"):
				$AnimatedSprite2D/HitboxAtaque.position.x = -abs($AnimatedSprite2D/HitboxAtaque.position.x)

	# --- 4. ANIMACIONES ---
	
	if not is_dashing and not atacar: # Solo giramos si no estamos ocupados
		if direction == 1:
			animationPlayer.flip_h = false
			# Mover Hitbox a la DERECHA (Positivo)
			# Cambia '30' por la distancia que tenga tu hitbox en el editor
			$AnimatedSprite2D/HitboxAtaque.position.x = 25 
			
		elif direction == -1:
			animationPlayer.flip_h = true
			# Mover Hitbox a la IZQUIERDA (Negativo)
			$AnimatedSprite2D/HitboxAtaque.position.x = -25
			
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

# --------------------------------------

func die():
	if is_dead: return
	is_dead = true
	velocity = Vector2.ZERO
	# --- EFECTO DE MUERTE TEMPORAL (Sin Sprite) ---
	animationPlayer.play("Death")
	await animationPlayer.animation_finished
	await get_tree().create_timer(1.0).timeout
	# ------------------------------------
	SceneTransitioner.transition_to_scene(get_tree().current_scene.scene_file_path)


func animations(direction):
	if is_dashing: return 
	if atacar: return 
	if is_dead: return
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
				animationPlayer.play("Fall") # O la que tengas para caer

func actualizar_barra_visual():
	if not barra_vida_sprite or max_health <= 0:
		return
	var porcentaje = clamp(health / max_health, 0.0, 1.0)
	var total_frames = barra_vida_sprite.sprite_frames.get_frame_count("Vida") - 1
	var frame_correspondiente = total_frames - int(porcentaje * total_frames)
	
	# Esto sigue funcionando igual
	barra_vida_sprite.frame = frame_correspondiente

func _controlar_hitbox():
	# Solo nos importa si estamos haciendo la animación de Ataque
	if animationPlayer.animation == "Ataque1":
		
		# OBTENER EL FRAME ACTUAL
		var frame_actual = animationPlayer.frame
		
		if frame_actual == 3: 
			hitbox_colision.disabled = false
			sonido_espada.pitch_scale = randf_range(0.9, 1.2)
			sonido_espada.play()
			
		elif frame_actual == 4:
			hitbox_colision.disabled = true  # ¡APAGAR! (Ya pasó el golpe)
	else:
		hitbox_colision.disabled = true

func ejecutar_ataque():
	# 1. Bloqueamos inmediatamente para no atacar de nuevo
	can_attack = false 
	
	# --- GIRO AUTOMÁTICO (Tu código de antes) ---
	var direction_ataque = Input.get_axis("Izquierda", "Derecha")
	if direction_ataque != 0:
		if direction_ataque == 1: 
			animationPlayer.flip_h = false
			if has_node("AnimatedSprite2D/HitboxAtaque"):
				$AnimatedSprite2D/HitboxAtaque.position.x = abs($AnimatedSprite2D/HitboxAtaque.position.x)
		elif direction_ataque == -1: 
			animationPlayer.flip_h = true
			if has_node("AnimatedSprite2D/HitboxAtaque"):
				$AnimatedSprite2D/HitboxAtaque.position.x = -abs($AnimatedSprite2D/HitboxAtaque.position.x)
	# --------------------------------------------

	# 2. Acción
	animationPlayer.play("Ataque1")
	
	# 3. Esperar a que termine la ANIMACIÓN
	await animationPlayer.animation_finished
	
	# 4. Soltamos el estado visual (para que pueda volver a correr/idle)
	atacar = false 
	
	# 5. COOLDOWN: Esperamos el tiempo extra (0.2s) antes de permitir otro golpe
	await get_tree().create_timer(attack_cooldown).timeout
	
	# 6. ¡Listo para la próxima!
	can_attack = true
	
func _on_hitbox_body_entered(body):
	# Verificamos si lo que tocamos tiene la función "recibir_dano"
	if body.has_method("recibir_dano"):
		body.recibir_dano(10)

func recibir_dano(cantidad: int):
	# 1. Si ya soy inmortal (me acaban de pegar), ignoro el golpe
	if is_invulnerable or is_dead:
		return
	
	# 2. Restar vida
	health -= cantidad
	print("Auch! Vida restante: ", health)
	actualizar_barra_visual() # (Si tienes la barra de vida conectada)
	
	# 3. Muerte
	if health <= 0:
		die()
		return

	# 4. Activar Inmortalidad temporal (I-Frames)
	is_invulnerable = true
	
	# Efecto visual: Parpadear en rojo (Opcional)
	modulate = Color(10, 0, 0) # Se pone rojo brillante
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1) # Vuelve a normal
	
	# Esperar 1 segundo antes de poder ser golpeado de nuevo
	await get_tree().create_timer(1.0).timeout
	is_invulnerable = false		


func _on_hitbox_ataque_body_entered(body):
	# 1. ¿Golpeé a un enemigo?
	if body.is_in_group("enemigos"):
		# 2. Aplicamos daño al enemigo
		if body.has_method("recibir_daño"):
			body.recibir_daño(attack_damage)
			curar(life_steal)

func curar(cantidad: float):
	# Sumamos vida
	health += cantidad
	
	# "Clamp" sirve para asegurar que la vida nunca supere el máximo
	health = clamp(health, 0, max_health)
	
	print("¡Robo de vida! Salud actual: ", health)
	actualizar_barra_visual()
	
	# (Opcional) Efecto visual verde al curarse
	modulate = Color(0, 3, 0) # Flash Verde brillante
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1) # Volver a normal
