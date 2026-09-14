extends Area2D

var vitesse : float = 1000.0
var degats : int = 3

@onready var sprite = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("player_laser")
	if sprite:
		sprite.play("default")

func _process(delta: float) -> void:
	# Mouvement l-fo9
	global_position.y -= vitesse * delta

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func explode() -> void:
	vitesse = 0
	if sprite and sprite.sprite_frames.has_animation("impact"):
		sprite.play("impact")
		await sprite.animation_finished
	queue_free()
