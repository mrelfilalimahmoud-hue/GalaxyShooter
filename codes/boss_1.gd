extends Area2D
signal boss_mort
var vie : int = 50
var vitesse : float = 150.0
var direction : int = 1

# Variables jdad dyal l-hbot
var est_en_place : bool = false
var vitesse_descente : float = 100.0 # ch7al bach ghayhbet
var position_cible_y : float = 200.0 # l-blassa fin ghayw9ef (bedelha kima bghiti)
var explosion_scene = preload("res://scenes/explosion.tscn")
var boss_laser_scene = preload("res://scenes/boss_laser.tscn")
@onready var muzzle = $Muzzle
@onready var shoot_timer = $ShootTimer

func _ready() -> void:
	add_to_group("enemies")

func _process(delta: float) -> void:
	if not est_en_place:
		# L-Boss mazal habet mn foq
		position.y += vitesse_descente * delta
		if position.y >= position_cible_y:
			position.y = position_cible_y
			est_en_place = true
			shoot_timer.start() # Ybda ytiri mli yw9ef
	else:
		# L-Boss wsel blaysto, daba yt7rek limn w lissr
		position.x += vitesse * direction * delta
		if position.x > 600 or position.x < 100:
			direction *= -1


func _on_shoot_timer_timeout() -> void:
	var laser = boss_laser_scene.instantiate()
	laser.global_position = muzzle.global_position
	get_tree().root.add_child(laser)


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_laser") or area.name == "Laser":
		area.queue_free()
		vie -= 50
		modulate = Color(1, 0, 0)
		await get_tree().create_timer(0.1).timeout
		modulate = Color(1, 1, 1)
		
		if vie <= 0:
			die()



func die() -> void:
	# 1. N-saybo l-explosion
	var explosion = explosion_scene.instantiate()
	explosion.global_position = global_position
	
	# 2. Hna fin kan-kbrouha! (Vector2(3, 3) ya3ni kbira 3 d l-mrat, bdel l-raqm kima bghiti)
	explosion.scale = Vector2(3.0, 3.0)
	
	# 3. N-zidouha f l-jeu
	get_tree().root.add_child(explosion)
	
	# 4. N-siftou l-signal bash yrj3ou l-3dyan, 3ad n-ms7ou l-boss
	boss_mort.emit()
	queue_free()
