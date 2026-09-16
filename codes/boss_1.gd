extends Area2D

signal boss_mort

# Kberna la vie chwiya bash maymoutsh f 3 d d-derbat
var vie : int = 4 
var vitesse : float = 150.0
var direction : int = 1

# Variables dyal l-hbot
var est_en_place : bool = false
var vitesse_descente : float = 100.0 
var position_cible_y : float = 200.0 

var explosion_scene = preload("res://scenes/explosion.tscn")
var boss_laser_scene = preload("res://scenes/boss_laser.tscn")
var bonus_scene = preload("res://scenes/boss_1_bonus.tscn") # L-bonus li ghayti7
@onready var health_bar = $CanvasLayer/HealthBar
@onready var muzzle = $Muzzle
@onready var shoot_timer = $ShootTimer

func _ready() -> void:
	add_to_group("enemies")
	# N3tiw l-bar l-max w l-valeur lowla
	health_bar.max_value = vie
	health_bar.value = vie

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
		
		# Hna kayt-7seb damage 3la 7ssab l-player wesh m-upgradi wla la
		if "degats" in area:
			vie -= area.degats
		else:
			vie -= 1
			
		# ++ ZID HAD SṬER HNA BASH T-UPDATER L-BAR ++
		health_bar.value = vie
		# Effet d-derba b l-7mer
		modulate = Color(1, 0, 0)
		await get_tree().create_timer(0.1).timeout
		modulate = Color(1, 1, 1)
		
		if vie <= 0:
			die()

func die() -> void:
	# 1. N-saybo l-explosion kbira
	var explosion = explosion_scene.instantiate()
	explosion.global_position = global_position
	explosion.scale = Vector2(3.0, 3.0)
	get_tree().root.add_child(explosion)
	
	# 2. N-saybo l-Bonus f nfs position dyal Boss 1 bash l-player yakhdo
	if bonus_scene:
		var bonus = bonus_scene.instantiate()
		bonus.global_position = global_position
		get_tree().root.add_child(bonus)
		
	# 3. N-siftou l-signal l-game.gd bash ykml l-vagues w n-ms7ou l-boss
	boss_mort.emit()
	queue_free()
