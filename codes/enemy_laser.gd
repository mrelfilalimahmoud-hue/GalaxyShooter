extends Area2D

var speed : float = 250.0 

func _ready():
	# Zid had l-khat hna b l-code b rassu
	add_to_group("enemy_laser")
func _process(delta):
	# Kayhbet lta7t (Y mujaba)
	global_position.y += speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()





func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		if area.has_method("prendre_degats"):
			area.prendre_degats(10) # كينقص 10 ديال الدم
		queue_free()
