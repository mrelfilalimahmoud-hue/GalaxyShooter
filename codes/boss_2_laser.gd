extends Area2D

var vitesse : float = 400.0
var explosion_scene = preload("res://scenes/explosion.tscn")
@onready var sprite = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("enemy_laser")
	# 1. Kay-bda l-animation
	sprite.play("default")
	# 2. Kay-ḥbbes l-animation f Frame 4 bdbt!
	sprite.frame = 4
	sprite.stop()

func _process(delta: float) -> void:
	global_position.y += vitesse * delta

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		if area.has_method("prendre_degats"):
			area.prendre_degats(20)
		
		# 3. Mli kay-9iss l-player, kay-kmml l-animation d l-infijar (Frames 6-11)
		sprite.frame = 6
		sprite.play("default")
		
		# N-ḥebso l-ḥaraka باش y-nfejer f blasso
		vitesse = 0
		
		# N-msḥo l-laser mli t-sali l-animation
		await sprite.animation_finished
		queue_free()
