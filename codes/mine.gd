extends Area2D

var speed : float = 80.0
var player = null
var direction : Vector2 = Vector2.DOWN

var est_detruite : bool = false
var est_amorcee : bool = false # Kat-werri wesh l-mine bdat katsni
var ticks_restants : int = 4 # Ch7al mn "Tik" ghat-dir 9bel mat-tferge3

var explosion_scene = preload("res://scenes/explosion.tscn")

@onready var anim = $AnimatedSprite2D
@onready var explosion_radius = $ExplosionRadius
@onready var hitbox = $Hitbox
@onready var tick_timer = $TickTimer
@onready var tick_sound = $TickSound

func _ready() -> void:
	add_to_group("mines")
	player = get_tree().get_first_node_in_group("player")
	if anim:
		anim.play("rotate")
		
	# Kan-connectiw l-Timer m3a l-script (Ila maderthash mn l'interface)
	if tick_timer and not tick_timer.timeout.is_connected(_on_tick_timer_timeout):
		tick_timer.timeout.connect(_on_tick_timer_timeout)

func _process(delta: float) -> void:
	if est_detruite or est_amorcee:
		return # Ila tferg3at awla bdat katsni, kat-7bess f blassetha makatb9ash tayra
		
	if player and is_instance_valid(player):
		direction = global_position.direction_to(player.global_position)
	
	global_position += direction * speed * delta

func _on_area_entered(area: Area2D) -> void:
	if est_detruite:
		return
		
	if area.is_in_group("player_laser") or area.name == "Laser":
		area.queue_free() # L-qortasa kat-tmsse7
		if not est_amorcee:
			amorcer_mine() # Knbdaw l-compteur d l-infijar
		
	elif area.is_in_group("player"):
		if area.has_method("prendre_degats"):
			area.prendre_degats(1000) # L-player kaymout
		explode_aoe() # Infijar mobashir

# L-Fonction li katbda "Tik Tik"
func amorcer_mine() -> void:
	est_amorcee = true
	if tick_timer:
		tick_timer.start(0.4) # Kol 0.4 taniya ghat-dir Tik
		_on_tick_timer_timeout() # Kan-l3bou awel Tik f l-blassa

# Had l-Fonction kat-t3iyt rasha kol 0.4s 
func _on_tick_timer_timeout() -> void:
	if ticks_restants > 0:
		# 1. N-l3bou Sawt
		if tick_sound:
			tick_sound.play()
			
		# 2. N-redouha 7emra (Blink)
		modulate = Color(1, 0, 0) # Loun 7mer
		await get_tree().create_timer(0.15).timeout
		modulate = Color(1, 1, 1) # Terje3 l-loun l-3adi
		
		ticks_restants -= 1
	else:
		# Salaw les Tiks, daba ghat-tferge3 dbsah!
		tick_timer.stop()
		explode_aoe()

func explode_aoe() -> void:
	if est_detruite:
		return 
	est_detruite = true
	
	if hitbox:
		hitbox.set_deferred("disabled", true)

	var areas_in_radius = explosion_radius.get_overlapping_areas()
	for a in areas_in_radius:
		if a.is_in_group("enemies") or a.is_in_group("enemy2"):
			if a.has_method("explode"):
				a.explode()
			else:
				a.queue_free()
		elif a.is_in_group("player") and a != self:
			if a.has_method("prendre_degats"):
				a.prendre_degats(30)
		elif a.is_in_group("mines") and a != self:
			if a.has_method("explode_aoe"):
				a.explode_aoe()

	var explosion = explosion_scene.instantiate()
	explosion.global_position = global_position
	explosion.scale = Vector2(2.5, 2.5) 
	get_tree().root.add_child(explosion)
	
	queue_free()
