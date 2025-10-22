extends Control

func _on_button_jugar_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/elcorazon.tscn")
	
func _on_button_salir_pressed() -> void:
	get_tree().quit()
