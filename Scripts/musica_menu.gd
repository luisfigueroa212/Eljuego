extends AudioStreamPlayer

#Sonido en bucle
func _on_finished():
	self.play()
