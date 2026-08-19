extends Area2D
var vitesse : float = 400.0

func _ready() -> void:
	add_to_group("enemy_laser")

func _process(delta: float) -> void:
	global_position.y += vitesse * delta

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
