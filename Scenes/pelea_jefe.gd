extends Node2D

@export var nivel_de_infeccion: float = 5.0 # La variable que lee tu jugador

func _ready():
	# Buscamos al jefe por su nombre. Asegúrate que en la escena se llame "Jefe"
	if has_node("Jefazo"):
		$Jefazo.jefe_derrotado.connect(_on_jefe_derrotado)

func _on_jefe_derrotado():
	# ¡ESTO ES LO QUE DETIENE LA INFECCIÓN!
	remove_from_group("infectado")
	print("✨ ¡NIVEL PURIFICADO! El grupo 'infectado' ha sido removido.")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
