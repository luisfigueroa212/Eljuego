extends AudioStreamPlayer

const RETRASO_SEGUNDOS = 1 

var tiempo_transcurrido = 0.0

func _process(delta):
	# Incrementa el tiempo transcurrido con el tiempo delta de cada frame
	tiempo_transcurrido += delta
	
	# Verifica si el tiempo transcurrido es mayor o igual al retraso deseado
	if tiempo_transcurrido >= RETRASO_SEGUNDOS:
		# Llama a la función 'play()' para que el audio comience a sonar
		play()
		
		# Detiene el procesamiento de esta lógica una vez que el audio se reproduce
		set_process(false)
