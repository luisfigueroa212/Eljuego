extends Area2D
@export var next_scene_path: String = "res://Scenes/menu.tscn"

func _ready():
	hide() 
	monitoring = false 
	Dialogic.signal_event.connect(_on_dialogic_signal)
	body_entered.connect(_on_body_entered)

func _on_dialogic_signal(argumento: String):
	if argumento == "abrir_portal":
		show()
		monitoring = true
		$AnimatedSprite2D.play("Portal")
		print("🌀 ¡Portal abierto!")

# Esta función cambia de nivel
func _on_body_entered(body):
	if body.is_in_group("player"):
		SceneTransitioner.transition_to_scene(next_scene_path)
