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
