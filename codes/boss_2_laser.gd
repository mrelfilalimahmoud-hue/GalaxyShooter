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
	# 1. Ila 9ass l-Player
	if area.is_in_group("player"):
		if area.has_method("prendre_degats"):
			area.prendre_degats(20)
		
		sprite.frame = 6
		sprite.play("default")
		vitesse = 0
		await sprite.animation_finished
		queue_free()
		
	# 2. === JDID: Ila t-la9a m3a Laser dyal Player ===
	elif area.is_in_group("player_laser"):
		# N-ferg3o l9rtasa dyal l-Player
		if area.has_method("explode"):
			area.explode()
		else:
			area.queue_free()
			
		# N-ferg3o l-laser dyal Boss 2 b l-frames d l-infijar dyalo
		sprite.frame = 6
		sprite.play("default")
		vitesse = 0
		await sprite.animation_finished
		queue_free()
