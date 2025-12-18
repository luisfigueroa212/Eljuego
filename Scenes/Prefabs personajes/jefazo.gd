extends CharacterBody2D

# --- CONFIGURACIÓN ---
@export var max_health: int = 200
@export var speed: float = 80.0     # Velocidad al caminar
@export var attack_range: float = 60.0 # Distancia para empezar a pegar
@export var damage: int = 20        # Daño que hace el jefe

# --- VARIABLES ---
var is_invulnerable: bool = false # Para que el jefe no sea un saco de boxeo infinito
var current_health: int
var can_attack: bool = true
var is_dead: bool = false
var is_busy: bool = false # Si es true, el jefe no piensa ni se mueve
var player_target: Node2D = null

# --- REFERENCIAS ---
@onready var sprite = $AnimatedSprite2D
@onready var hitbox_colision = $HitboxMelee/CollisionShape2D # <--- ASEGURATE DE TENER ESTO

signal jefe_derrotado

func _ready():
	current_health = max_health
	player_target = get_tree().get_first_node_in_group("player")
	# Desactivamos el hitbox al nacer por seguridad
	hitbox_colision.disabled = true

func _physics_process(delta):
	# 1. ESTADOS DE BLOQUEO
	if is_dead: return
	
	# Gravedad siempre
	if not is_on_floor():
		velocity += get_gravity() * delta

	if is_busy: 
		move_and_slide()
		return # Si está atacando o herido, no hace nada más

	# 2. IA BÁSICA (Cerebro)
	if player_target:
		var distancia = global_position.distance_to(player_target.global_position)
		
		# A. ¿Está suficientemente cerca para pegar?
		if distancia <= attack_range:
			atacar_melee()
			
		# B. ¿Está lejos? ¡A perseguir!
		else:
			perseguir_jugador()
	
	move_and_slide()
	
	# Control de animación de movimiento
	if not is_busy:
		if velocity.x == 0:
			sprite.play("Idle")
		else:
			sprite.play("Walk")

# --- LÓGICA DE PERSECUCIÓN ---
func perseguir_jugador():
	# Calculamos dirección hacia el jugador (-1 o 1)
	var direccion = global_position.direction_to(player_target.global_position).x
	
	if direccion > 0:
		velocity.x = speed
		girar(false) # Mirar derecha
	else:
		velocity.x = -speed
		girar(true)  # Mirar izquierda

# --- LÓGICA DE GIRO (Para mover el Hitbox también) ---
func girar(mirar_izquierda: bool):
	sprite.flip_h = not mirar_izquierda
	
	# Movemos el Hitbox del golpe al lado correcto
	if mirar_izquierda:
		$HitboxMelee.position.x = -abs($HitboxMelee.position.x)
	else:
		$HitboxMelee.position.x = abs($HitboxMelee.position.x)

# --- ATAQUE MELEE (Golpe de espada) ---
func atacar_melee():
	# Si no puede atacar (cooldown), no hacemos nada
	if not can_attack: return

	is_busy = true
	can_attack = false # Bloqueamos el siguiente ataque
	velocity.x = 0 
	
	var dir_x = global_position.direction_to(player_target.global_position).x
	
	# Ajuste de giro según tu corrección anterior
	if dir_x < 0: girar(true)
	else: girar(false)
	
	sprite.play("Attack")
	await sprite.animation_finished
	
	is_busy = false # Ya se puede mover
	
	# --- COOLDOWN ---
	# El jefe espera 1.5 segundos (o lo que quieras) antes de volver a pensar en atacar
	await get_tree().create_timer(1.5).timeout
	can_attack = true
# --- CONTROL DEL HITBOX (Frames) ---
func _process(delta):
	# Esto se ejecuta en cada frame para verificar la animación exacta
	if sprite.animation == "Attack":
		var frame = sprite.frame
		
		# VIENDO TU IMAGEN: El golpe parece ser frames 4, 5 y 6
		if frame >= 4 and frame <= 6:
			hitbox_colision.disabled = false # ¡DAÑO ACTIVO!
		else:
			hitbox_colision.disabled = true  # Apagado
	else:
		# Si no está atacando, hitbox siempre apagado
		hitbox_colision.disabled = true

# --- DETECCIÓN DE GOLPE AL JUGADOR ---
# Conecta la señal "body_entered" de tu Area2D HitboxMelee a este script
func _on_hitbox_melee_body_entered(body):
	# Verificamos si lo que tocó la espada es el Jugador
	if body.is_in_group("player"):
		
		# Verificamos si el jugador tiene la función de daño (por seguridad)
		if body.has_method("recibir_dano"):
			# ¡Aquí es donde ocurre la magia!
			# Le pasamos la variable 'damage' que definimos arriba (ej. 20)
			body.recibir_dano(damage)
			
		print("¡Intento de golpe al jugador!")
		
# --- SISTEMA DE DAÑO Y MUERTE ---

func recibir_daño(cantidad: int):
	# 1. FILTRO DE SEGURIDAD
	# Si está muerto o tiene el escudo de invencibilidad activo, ignoramos el golpe.
	# Esto ROMPE el stun-lock: tus golpes "rebotarán" y él seguirá moviéndose.
	if is_dead or is_invulnerable: 
		return

	# 2. RESTAR VIDA
	current_health -= cantidad
	print("Jefe herido! Vida restante: ", current_health)
	
	if current_health <= 0:
		die()
	else:
		# --- GESTIÓN DE DAÑO Y ATURDIMIENTO ---
		
		# A. Activamos la invulnerabilidad INMEDIATAMENTE
		is_invulnerable = true
		
		# B. Aturdimiento visual (Se queda quieto y se queja)
		is_busy = true
		velocity.x = 0
		sprite.play("Hurt")
		
		# C. Efecto visual de daño (Flash Rojo/Blanco opcional)
		sprite.modulate = Color(10, 0, 0) # Rojo intenso
		
		# Esperamos SOLO lo que dura la animación de dolor
		await sprite.animation_finished
		
		# --- RECUPERACIÓN DEL JEFE ---
		sprite.modulate = Color(1, 1, 1) # Color normal
		is_busy = false     # <--- ¡AQUI ESTÁ LA CLAVE! El jefe se despierta...
		sprite.play("Idle") # ...y ya puede volver a atacarte.
		
		# D. PERO sigue siendo invulnerable un rato más
		# El jefe te atacará mientras tú intentas pegarle en vano.
		await get_tree().create_timer(1.0).timeout # 1 segundo extra de "Escudo"
		
		is_invulnerable = false # Ahora sí, ya le puedes pegar otra vez
func die():
	print("¡El jefe ha sido derrotado!")
	is_dead = true
	is_busy = true
	velocity.x = 0
	
	# --- EMITE LA SEÑAL AQUÍ ---
	jefe_derrotado.emit() # Esto avisa a quien esté escuchando
	
	$CollisionShape2D.set_deferred("disabled", true)
	hitbox_colision.set_deferred("disabled", true)
	
	sprite.play("Death")
	await sprite.animation_finished
	
	queue_free()
