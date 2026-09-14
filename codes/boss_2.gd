extends Area2D

signal boss_mort
var vie : int = 75 # Zdt l-vie chwia hit Boss 2 kbir
var vitesse : float = 200.0
var direction : int = 1

# Variables dyal l-hbot
var est_en_place : bool = false
var vitesse_descente : float = 100.0
var position_cible_y : float = 200.0

var explosion_scene = preload("res://scenes/explosion.tscn")
var boss_laser_scene = preload("res://scenes/boss2_laser.tscn")

@onready var muzzle = $Muzzle
@onready var shoot_timer = $ShootTimer

func _ready() -> void:
	add_to_group("enemies")

func _process(delta: float) -> void:
	if not est_en_place:
		# L-Boss kay-hbet mn foq
		position.y += vitesse_descente * delta
		if position.y >= position_cible_y:
			position.y = position_cible_y
			est_en_place = true
			shoot_timer.start()
	else:
		# L-Boss kay-t7rek limn w lissr
		position.x += vitesse * direction * delta
		if position.x > 600 or position.x < 100:
			direction *= -1

func _on_shoot_timer_timeout() -> void:
	var laser = boss_laser_scene.instantiate()
	laser.global_position = muzzle.global_position
	
	# HNA FIN KAT-KEBER L-ḤAJM DYAL L-ṬAL9A:
	# Vector2(2.5, 2.5) kat-kebbar l-laser 2 marrat w nṣf
	
	
	get_tree().root.add_child(laser)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_laser") or area.name == "Laser":
		area.queue_free()
		if "degats" in area:
			vie -= area.degats
		else:
			vie -= 1
		modulate = Color(1, 0, 0)
		await get_tree().create_timer(0.1).timeout
		modulate = Color(1, 1, 1)
		
		if vie <= 0:
			die()

func die() -> void:
	var explosion = explosion_scene.instantiate()
	explosion.global_position = global_position
	explosion.scale = Vector2(4.0, 4.0) # Explosion kbira d Boss 2
	get_tree().root.add_child(explosion)
	
	boss_mort.emit()
	queue_free()
