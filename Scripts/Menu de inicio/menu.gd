extends Control

func _on_button_jugar_pressed() -> void:
	# Llamamos a nuestro Autoload en lugar de cambiar la escena directamente
	print("Cambiando escena..")
	SceneTransitioner.transition_to_scene("res://Scenes/bosque.tscn")
	
	
func _on_button_salir_pressed() -> void:
	SceneTransitioner.transition_to_quit()
