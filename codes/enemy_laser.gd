extends Area2D

var speed : float = 180.0 
var explosion_scene = preload("res://scenes/explosion.tscn")
func _ready():
	# Zid had l-khat hna b l-code b rassu
	add_to_group("enemy_laser")

func _process(delta):

		global_position.y += speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()





func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		if area.has_method("prendre_degats"):
			area.prendre_degats(10) # كينقص 10 ديال الدم
		queue_free()
	elif area.is_in_group("player_laser"):
	# 1. Nferg3o l9rtasa dyal l'player (kat3iyyet l fonction explode li 3ndek fiha)
		if area.has_method("explode"):
			area.explode()
		else:
			area.queue_free()
		
		# 2. Nsaybo infijar f blassat l9rtasa dyal l'enemy
		var explosion = explosion_scene.instantiate()
		explosion.global_position = global_position
		# T9der tsghr l'infijar chwia ila jak kbir 3la l9rtasa
		explosion.scale = Vector2(0.5, 0.5) 
		get_tree().root.add_child(explosion)
		
		# 3. Nms7o l9rtasa dyal l'enemy
		queue_free()
