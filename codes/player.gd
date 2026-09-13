extends Area2D

# --- SIGNALS JDAD ---
signal mise_a_jour_ui(vie, vies_restantes)
signal game_over
signal player_upgraded

# --- VARIABLES JDAD ---
var degats_laser : int = 1
var est_invincible : bool = false
var vie : int = 100
var vies_restantes : int = 3
var position_depart : Vector2
var est_mort : bool = false # Bach n7ebso l-mouvement mli ymout
var explosion_scene = preload("res://scenes/explosion.tscn") # T2ked mn l-path dyal l-explosion

# --- VARIABLES DYAL L-UPGRADE ---
var is_upgraded : bool = false

# --- VARIABLES DYALK ---
var is_dragging : bool = false
var screen_size : Vector2
var last_x_pos : float = 0.0
var laser_scene = preload("res://scenes/laser.tscn")
var laser_upgraded_scene = preload("res://scenes/laser_2.tscn")
@onready var anim = $AnimatedSprite2D
@onready var muzzle_left = $MuzzleLeft 
@onready var muzzle_right = $MuzzleRight

var can_shoot : bool = true

func _ready():
	add_to_group("player") # Darouri bach l-3dyan y3rfouh
	
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
	
	# N-sauviw blassou l-asliya bach y-respawni fiha
	position_depart = global_position
	
	anim.play("idle")
	
	# N-siftou l-UI l-ma3loumat l-lwla
	mise_a_jour_ui.emit(vie, vies_restantes)

# --- FONCTION DYAL L-UPGRADE (Mli y-9iss l-bonus) ---
func upgrade_ship() -> void:
	if not is_upgraded:
		is_upgraded = true
		vie = 150
		degats_laser = 3
		
		# === JDID: Beddel l-laser l-laser_2 mli y-a3khas l-bonus ===
		laser_scene = laser_upgraded_scene
		
		mise_a_jour_ui.emit(vie, vies_restantes)
		player_upgraded.emit() # === Sift signal l game.gd ===
		anim.play("idle_upgraded")

func _input(event):
	if est_mort: return # May-t7rekch ila kan mat
	
	if event is InputEventScreenTouch:
		is_dragging = event.pressed
		# Remettre l'animation au centre quand on lève le doigt
		if not event.pressed:
			anim.play("idle_upgraded" if is_upgraded else "idle")
			
	elif event is InputEventScreenDrag and is_dragging:
		# Déplacer le vaisseau
		global_position += event.relative

func _process(delta):
	if est_mort: return # May-dir walo ila kan mat
	
	screen_size = get_viewport_rect().size
	
	# 1. Limiter sur l'axe X (Gauche / Droite avec marge de 40px)
	global_position.x = clamp(global_position.x, 40, screen_size.x - 40)
	
	# 2. Limiter sur l'axe Y (Strictement le quart inférieur de l'écran)
	var limite_haute = screen_size.y * 0.75 # 75% de l'écran (le quart bas)
	var limite_basse = screen_size.y - 60   # Marge avant le bord bas
	
	global_position.y = clamp(global_position.y, limite_haute, limite_basse)
	
	# 3. Logique d'animation (inclinaison fluide m3a support upgrade)
	if is_dragging:
		var delta_x = global_position.x - last_x_pos
		
		if delta_x < -1.5:
			var anim_left = "turn_left_upgraded" if is_upgraded else "turn_left"
			if anim.animation != anim_left:
				anim.play(anim_left)
		elif delta_x > 1.5:
			var anim_right = "turn_right_upgraded" if is_upgraded else "turn_right"
			if anim.animation != anim_right:
				anim.play(anim_right)
		else:
			var anim_idle = "idle_upgraded" if is_upgraded else "idle"
			if anim.animation != anim_idle:
				anim.play(anim_idle)
				
	# Sauvegarder la position pour la prochaine frame
	last_x_pos = global_position.x

func shoot():
	var laser1 = laser_scene.instantiate()
	laser1.global_position = muzzle_left.global_position
	# Zid l-damage l-laser
	if "degats" in laser1:
		laser1.degats = degats_laser
	get_tree().root.add_child(laser1)
	
	var laser2 = laser_scene.instantiate()
	laser2.global_position = muzzle_right.global_position
	# Zid l-damage l-laser
	if "degats" in laser2:
		laser2.degats = degats_laser
	get_tree().root.add_child(laser2)

func _on_shoot_timer_timeout() -> void:
	if est_mort: return # May-tirich ila kan mat
	if is_dragging:
		shoot()

# --- FONCTIONS JDAD DYAL LA VIE ---

func prendre_degats(degats: int) -> void:
	if est_mort or est_invincible: 
		return
	
	vie -= degats
	mise_a_jour_ui.emit(vie, vies_restantes)
	
	# خاصنا نتشيكيو واش مات قبل ما نديرو اللون الأحمر
	if vie <= 0:
		mourir()
		return # باش يحبس الكود هنا يلا مات ومايكملش لتحت
		
	# يلا بقى حي، عاد نديرو ليه تأثير الضربة (اللون الأحمر)
	modulate = Color(1.0, 0, 0)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)

func mourir() -> void:
	est_mort = true
	is_dragging = false # N-7ebso dragging bash mayb9ach wa7el
	anim.play("idle_upgraded" if is_upgraded else "idle")
	
	# L-infijar
	if explosion_scene:
		var explosion = explosion_scene.instantiate()
		explosion.global_position = global_position
		get_tree().root.add_child(explosion)
	
	vies_restantes -= 1
	
	if vies_restantes > 0:
		respawn()
	else:
		visible = false
		game_over.emit()
		queue_free() # Game Over nhaiyi

func respawn() -> void:
	visible = false
	global_position = position_depart
	vie = 100
	mise_a_jour_ui.emit(vie, vies_restantes)
	
	# N-tsnnaw 1.5 s 3ad n-raj3ouh
	await get_tree().create_timer(1.5).timeout
	
	visible = true
	est_mort = false
	activer_invincibilite(3.0)

# --- COLLISION ---

func activer_invincibilite(temps: float) -> void:
	est_invincible = true
	clignoter() # N-bdaou n-sniw
	
	# Kantsnaw l-mudda (مثلا 3 ثواني) تسالي
	await get_tree().create_timer(temps).timeout
	
	# Mli tsali l-mudda, kan-7iydo l-7imaya w n-rj3ouh 3adi
	est_invincible = false
	modulate.a = 1.0 # Nrj3o ch-chafafiya (Alpha) 100% 3adiya

func clignoter() -> void:
	# Bima annana m7myin, ghadi n-b9aw n-sniw
	while est_invincible:
		modulate.a = 0.3 # N-rdouh khavet (Chffaf)
		await get_tree().create_timer(0.1).timeout
		
		if not est_invincible: 
			break # Ila salat l-mudda, n7ebso
			
		modulate.a = 1.0 # N-rdouh 3adi
		await get_tree().create_timer(0.1).timeout
