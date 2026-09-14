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
var est_mort : bool = false 
var explosion_scene = preload("res://scenes/explosion.tscn")

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
	add_to_group("player") 
	
	screen_size = get_viewport_rect().size
	var limite_haute = screen_size.y * 0.75
	var limite_basse = screen_size.y - 60
	var centre_y = (limite_haute + limite_basse) / 2.0
	
	global_position = Vector2(screen_size.x / 2.0, centre_y)
	last_x_pos = global_position.x
	position_depart = global_position
	
	anim.play("idle")
	mise_a_jour_ui.emit(vie, vies_restantes)

# --- FONCTION DYAL L-UPGRADE ---
func upgrade_ship() -> void:
	if not is_upgraded:
		is_upgraded = true
		vie = 150
		degats_laser = 3
		laser_scene = laser_upgraded_scene
		
		mise_a_jour_ui.emit(vie, vies_restantes)
		player_upgraded.emit() 
		anim.play("idle_upgraded")

func _input(event):
	if est_mort: return 
	
	if event is InputEventScreenTouch:
		is_dragging = event.pressed
		if not event.pressed:
			anim.play("idle_upgraded" if is_upgraded else "idle")
			
	elif event is InputEventScreenDrag and is_dragging:
		global_position += event.relative

func _process(delta):
	if est_mort: return 
	
	screen_size = get_viewport_rect().size
	global_position.x = clamp(global_position.x, 40, screen_size.x - 40)
	
	var limite_haute = screen_size.y * 0.75 
	var limite_basse = screen_size.y - 60   
	
	global_position.y = clamp(global_position.y, limite_haute, limite_basse)
	
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
				
	last_x_pos = global_position.x

func shoot():
	var laser1 = laser_scene.instantiate()
	laser1.global_position = muzzle_left.global_position
	if "degats" in laser1:
		laser1.degats = degats_laser
	get_tree().root.add_child(laser1)
	
	var laser2 = laser_scene.instantiate()
	laser2.global_position = muzzle_right.global_position
	if "degats" in laser2:
		laser2.degats = degats_laser
	get_tree().root.add_child(laser2)

func _on_shoot_timer_timeout() -> void:
	if est_mort: return 
	if is_dragging:
		shoot()

# --- FONCTIONS JDAD DYAL LA VIE ---

func prendre_degats(degats: int) -> void:
	if est_mort or est_invincible: 
		return
	
	vie -= degats
	mise_a_jour_ui.emit(vie, vies_restantes)
	
	if vie <= 0:
		mourir()
		return 
		
	modulate = Color(1.0, 0, 0)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)

func mourir() -> void:
	est_mort = true
	is_dragging = false 
	anim.play("idle_upgraded" if is_upgraded else "idle")
	
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
		queue_free() 

func respawn() -> void:
	visible = false
	global_position = position_depart
	
	# Mli kayrespawni, kayred HP max dyalou 3la ḥssab wesh m-upgradi awla la
	vie = 150 if is_upgraded else 100
	mise_a_jour_ui.emit(vie, vies_restantes)
	
	await get_tree().create_timer(1.5).timeout
	
	visible = true
	est_mort = false
	activer_invincibilite(3.0)

# --- COLLISION ---

func activer_invincibilite(temps: float) -> void:
	est_invincible = true
	clignoter() 
	
	await get_tree().create_timer(temps).timeout
	
	est_invincible = false
	modulate.a = 1.0 

func clignoter() -> void:
	while est_invincible:
		modulate.a = 0.3 
		await get_tree().create_timer(0.1).timeout
		
		if not est_invincible: 
			break 
			
		modulate.a = 1.0 
		await get_tree().create_timer(0.1).timeout

func gagner_vie() -> void:
	if vies_restantes < 3:
		vies_restantes += 1
		# Ta hna kanchoufo wesh m-upgradi
		vie = 150 if is_upgraded else 100 
		mise_a_jour_ui.emit(vie, vies_restantes)
