extends Control

# Referencias a nodos
@onready var text_label = $MarginContainer/VBoxContainer/TextLabel
@onready var continue_indicator = $MarginContainer/VBoxContainer/ContinueIndicator
@onready var background = $Background  # Panel oscuro de fondo

# El monólogo de tu juego
var monologue_lines = [
	"El Mercenario, sin nombre ni rostro ya, yacía vencido por la Peste, con el último aliento escapándose.",
	"Fue en esa negrura, en el umbral, que una voz tranquila se le acercó. 'El Sanguinario'.",
	"No ofreció sanación. Ofreció algo más cruel: supervivencia. Un pacto que la desesperación obligó a aceptar.",
	"El despertar fue en El Corazón, el último muro del mundo. Pero el Mercenario descubrió que la 'supervivencia' era la estafa más ruin. Era una maldición: un deterioro perpetuo que desgarraba su carne y alma.",
	"El cuerpo, en constante desmoronamiento, le gritaba un hambre insoportable. Un vacío que solo podía llenarse con una cosa: la Humanidad de otros.",
	"Con horror, el Mercenario comprendió su nuevo destino. Para mitigar su propia ruina, debía cazar a los últimos inocentes de El Corazón. Se había convertido en el depredador que El Sanguinario había planeado.",
	"Ahora, solo queda el camino de vuelta. No en busca de cura, sino en busca de venganza. El Corazón aguarda, y El Sanguinario será juzgado."
]

# Palabras clave que se escribirán más lento para énfasis
var emphasis_words = ["supervivencia", "Humanidad", "El Sanguinario", "El Corazón", "venganza"]

var current_line = 0
var current_char = 0
var is_typing = false
var base_typing_speed = 0.02
var emphasis_speed = 0.08  # Más lento para palabras importantes
var pause_between_lines = 0.8  # Segundos de pausa entre líneas
var can_skip = false

signal monologue_finished

func _ready():
	# Configurar el label para que no salte de línea innecesariamente
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_label.custom_minimum_size = Vector2(800, 0)  # Ajusta el ancho según tu pantalla
	text_label.size_flags_horizontal = Control.SIZE_FILL | Control.SIZE_EXPAND
	
	text_label.text = ""
	
	# Configurar fade in inicial
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.5)
	
	await tween.finished
	start_monologue()

func start_monologue():
	current_line = 0
	show_next_line()

func show_next_line():
	if current_line >= monologue_lines.size():
		finish_monologue()
		return
	
	text_label.text = ""
	current_char = 0
	is_typing = true
	type_text()

func type_text():
	if current_char < monologue_lines[current_line].length():
		var current_text = text_label.text
		var next_char = monologue_lines[current_line][current_char]
		text_label.text += next_char
		current_char += 1
		
		# Determinar velocidad basada en contexto
		var speed = base_typing_speed
		
		# Pausas más largas en puntos y comas
		if next_char == ".":
			speed = 0.3
		elif next_char == ",":
			speed = 0.15
		elif next_char == ":":
			speed = 0.2
		else:
			# Verificar si estamos en una palabra con énfasis
			for word in emphasis_words:
				if current_text.ends_with(word.substr(0, word.length() - 1)) and next_char == word[word.length() - 1]:
					speed = emphasis_speed
					break
		
		await get_tree().create_timer(speed).timeout
		type_text()
	else:
		is_typing = false
		# Esperar el tiempo de pausa y avanzar automáticamente
		await get_tree().create_timer(pause_between_lines).timeout
		current_line += 1
		show_next_line()

func skip_typing():
	if is_typing and can_skip:
		text_label.text = monologue_lines[current_line]
		is_typing = false
		current_char = monologue_lines[current_line].length()

func _input(event):
	# Presionar espacio o enter para saltar toda la animación del monólogo
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_select"):
		if can_skip:
			skip_entire_monologue()

func skip_entire_monologue():
	# Saltar directamente al final del monólogo
	can_skip = false
	is_typing = false
	
	# Fade out rápido
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await tween.finished
	
	emit_signal("monologue_finished")
	queue_free()

func finish_monologue():
	# Fade out dramático
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 2.0)
	await tween.finished
	
	emit_signal("monologue_finished")
	queue_free()

# Funciones auxiliares para personalización
func set_typing_speed(speed: float):
	base_typing_speed = speed

func set_pause_between_lines(seconds: float):
	pause_between_lines = seconds

func set_can_skip(value: bool):
	can_skip = value

func add_emphasis_word(word: String):
	emphasis_words.append(word)
