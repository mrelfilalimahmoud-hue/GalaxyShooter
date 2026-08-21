extends Area2D
var vitesse : float = 400.0
var explosion_scene = preload("res://scenes/explosion.tscn")
func _ready() -> void:
	add_to_group("enemy_laser")

func _process(delta: float) -> void:
	global_position.y += vitesse * delta

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()





func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		if area.has_method("prendre_degats"):
			area.prendre_degats(20) # الـ Boss كينقص 20
		queue_free()
	elif area.is_in_group("player_laser"):
		# 1. Nferg3o l9rtasa dyal l'player
		if area.has_method("explode"):
			area.explode()
		else:
			area.queue_free()
		
		# 2. Nsaybo infijar f blassat l9rtasa dyal l'Boss
		var explosion = explosion_scene.instantiate()
		explosion.global_position = global_position
		# Nkhliw l'infijar chwia kbir 7it dyal lboss
		explosion.scale = Vector2(0.8, 0.8) 
		get_tree().root.add_child(explosion)
		
		# 3. Nms7o l9rtasa dyal l'Boss
		queue_free()
