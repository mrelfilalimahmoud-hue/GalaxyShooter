extends Area2D
var vitesse : float = 400.0

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
