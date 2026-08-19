extends Area2D

var is_dragging : bool = false
var screen_size : Vector2
var last_x_pos : float = 0.0
var laser_scene = preload("res://scenes/laser.tscn")
@onready var anim = $AnimatedSprite2D
@onready var muzzle_left = $MuzzleLeft 
@onready var muzzle_right = $MuzzleRight
func _ready():
		# Récupérer la taille réelle de l'écran
		screen_size = get_viewport_rect().size
	
		# N7sbo l'limites kima darna f _process
		var limite_haute = screen_size.y * 0.75
		var limite_basse = screen_size.y - 60
	
	# N7sbo l'wst bdbt dyal dik l'masaha
		var centre_y = (limite_haute + limite_basse) / 2.0
	
	# Placer le joueur au centre de sa zone de mouvement
		global_position = Vector2(screen_size.x / 2.0, centre_y)
		last_x_pos = global_position.x
	
		anim.play("idle")

func _input(event):
	if event is InputEventScreenTouch:
		is_dragging = event.pressed
		# Remettre l'animation au centre quand on lève le doigt
		if not event.pressed:
			anim.play("idle")
			
	elif event is InputEventScreenDrag and is_dragging:
		# Déplacer le vaisseau
		global_position += event.relative

func _process(delta):
	screen_size = get_viewport_rect().size
	
	# 1. Limiter sur l'axe X (Gauche / Droite avec marge de 40px)
	global_position.x = clamp(global_position.x, 40, screen_size.x - 40)
	
	# 2. Limiter sur l'axe Y (Strictement le quart inférieur de l'écran)
	var limite_haute = screen_size.y * 0.75 # 75% de l'écran (le quart bas)
	var limite_basse = screen_size.y - 60   # Marge avant le bord bas
	
	global_position.y = clamp(global_position.y, limite_haute, limite_basse)
	
	# 3. Logique d'animation (inclinaison fluide)
	if is_dragging:
		var delta_x = global_position.x - last_x_pos
		
		if delta_x < -1.5:
			if anim.animation != "turn_left":
				anim.play("turn_left")
		elif delta_x > 1.5:
			if anim.animation != "turn_right":
				anim.play("turn_right")
		else:
			if anim.animation != "idle":
				anim.play("idle")
				
	# Sauvegarder la position pour la prochaine frame
	last_x_pos = global_position.x
func shoot():
# Kanjbdo w n7tto l'qortasa dyal Lissr
	var laser1 = laser_scene.instantiate()
	laser1.global_position = muzzle_left.global_position
	get_tree().root.add_child(laser1)
	
	# Kanjbdo w n7tto l'qortasa dyal Limn
	var laser2 = laser_scene.instantiate()
	laser2.global_position = muzzle_right.global_position
	get_tree().root.add_child(laser2)

func _on_shoot_timer_timeout() -> void:
	if is_dragging:
		shoot()




func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_laser"):
		print("player hit!")
		# Hna t9dar t-n9ss l'vie (HP)
		area.queue_free()
		# 1. Rdina l'AnimatedSprite2D (awla l'Player kaml) 7mer
		modulate = Color(1.0, 0, 0) # R=1, G=0, B=0 (A7mer sfi)
		
		# 2. Kantsnaw 1 taniya
		await get_tree().create_timer(0.1).timeout
		
		# 3. N-rdo l'lon l'asli dyalo (Abyad / Normal)
		modulate = Color(1, 1, 1)
