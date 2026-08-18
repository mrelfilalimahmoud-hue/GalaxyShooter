extends AnimatedSprite2D

func _ready():
	play("explode")
	# Mli tsali l'animation d'infijar, l'scene kat-tmsse7 rassha bohdha!
	await animation_finished
	queue_free()
