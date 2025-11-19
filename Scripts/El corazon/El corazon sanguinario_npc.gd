extends CharacterBody2D

# Variable para saber si el jugador está cerca
var player_in_area = false

@export var sanguinario_dialogic_char: DialogicCharacter

func _ready():
	# Conectamos las señales del Area2D por código (o hazlo visualmente si prefieres)
	# Asumo que tu nodo Area2D se llama "AreaInteraccion"
	$AreaInteraccion.body_entered.connect(_on_area_entered)
	$AreaInteraccion.body_exited.connect(_on_area_exited)

func _process(delta):
	# Si el jugador está en la zona Y presiona "Aceptar" (Enter/Espacio)
	# Y ademas, evitamos que se active si ya hay un dialogo ocurriendo
	if player_in_area and Input.is_action_just_pressed("interactuar"):
		print("¡Tecla presionada!")
		if Dialogic.current_timeline == null:
			print("Iniciando Dialogic...") # <--- MIRA LA CONSOLA
			run_dialogue()
		else:
			print("Ya hay un dialogo")

func run_dialogue():
	# 1. Iniciamos el diálogo
	var layout = Dialogic.start("charla_npc_sanguinario")
	
	# 2. Cargamos el personaje MANUALMENTE (Pega tu ruta aquí abajo entre comillas)
	# IMPORTANTE: Reemplaza la ruta de abajo por la que copiaste en el Paso 1
	var personaje = load("res://TimelinesDialogic/El_Sanguinario.dch") 
	
	# 3. Verificamos si el marcador existe (Para depurar)
	if has_node("AnimatedSprite2D/BubbleMarker"):
		print("Marcador encontrado, intentando registrar...")
		# 4. Registramos el personaje en la posición del marcador
		layout.register_character(personaje, $AnimatedSprite2D/BubbleMarker)
	else:
		print("ERROR: No encuentro el nodo Sprite2D/BubbleMarker")
# --- Señales ---
func _on_area_entered(body):
	if body.is_in_group("player"):
		player_in_area = true
		print("Jugador cerca. Presiona Enter para hablar.")

func _on_area_exited(body):
	if body.is_in_group("player"):
		player_in_area = false
