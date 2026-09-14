extends Area2D

var speed : float = 120.0 # Sour3a bach kayhbet l-bonus

func _process(delta: float) -> void:
	# L-bonus kayhbet l-te7t
	global_position.y += speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free() # Kaytmse7 ila makhedahch l-player w khrej mn chacha

func _on_area_entered(area: Area2D) -> void:
	# Ila 9asso l-player
	if area.is_in_group("player"):
		# Kan3iytou l-fonction d-ziyada dyal dem
		if area.has_method("gagner_vie"):
			area.gagner_vie()
		queue_free() # L-bonus kaykhtafi
