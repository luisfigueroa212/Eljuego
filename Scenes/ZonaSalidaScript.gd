extends Area2D

# Esta variable nos permite elegir el destino DESDE EL INSPECTOR
# El "*.tscn" hace que Godot te deje buscar archivos fácilmente
@export_file("*.tscn") var escena_destino: String

func _ready():
	# Conectamos la señal automáticamente por código para no hacerlo manual siempre
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Si entra el jugador...
	if body.is_in_group("player"):
		# ... y si hemos configurado una escena destino
		if escena_destino:
			print("Viajando a: ", escena_destino)
			SceneTransitioner.transition_to_scene(escena_destino)
		else:
			print("ERROR: ¡No le pusiste destino a esta puerta!")
