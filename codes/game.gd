extends Node2D

# Kanjbdo la scène dyal l'3dou
var enemy_scene = preload("res://scenes/enemy.tscn")
var screen_size : Vector2

func _ready():
	screen_size = get_viewport_rect().size

# Had l'fonction kat-t3iyyet kol taniya (3la 7sab l'Timer)



func _on_enemy_spawner_timeout() -> void:
	var enemy = enemy_scene.instantiate()
	
	# N3zlo blassa random f l'axe X (bin 40 w 680 bash maykhrjsh f jnab d chacha)
	var random_x = randf_range(40.0, screen_size.x - 40.0)
	
	# Y katkon saliba (-50) bash ybda mn lfo9 lbarra dyal chacha 3ad yhbet
	var start_y = -50.0
	
	enemy.global_position = Vector2(random_x, start_y)
	
	# Kanzidou l'3dou f l'jeu
	add_child(enemy)
