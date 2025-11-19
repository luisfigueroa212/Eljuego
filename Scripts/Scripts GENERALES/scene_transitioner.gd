extends CanvasLayer

# Hacemos una referencia al AnimationPlayer
@onready var anim_player = $AnimationPlayer


# Esta es la función que llamaremos desde CUALQUIER LUGAR
func transition_to_scene(scene_path: String):
	
	# 1. Reproducimos el fade a negro
	anim_player.play("fade_out")
	
	# 2. ESPERAMOS a que la animación termine
	await anim_player.animation_finished
	
	# 3. Solo ENTONCES cambiamos la escena
	var error = get_tree().change_scene_to_file(scene_path)
	
	# 4. En la nueva escena, reproducimos el fade de entrada
	# (El Autoload sigue vivo, así que esto funciona)
	anim_player.play("fade_in")
	
	

func transition_to_quit():
	# 1. Reproducimos el fade a negro
	anim_player.play("fade_out")
	
	# 2. ESPERAMOS a que la animación termine
	await anim_player.animation_finished
	
	# 3. Solo ENTONCES cerramos el juego
	get_tree().quit()
