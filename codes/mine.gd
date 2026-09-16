extends Area2D

var speed : float = 80.0
var player = null
var direction : Vector2 = Vector2.DOWN

var est_detruite : bool = false
var est_amorcee : bool = false 
var ticks_restants : int = 4 

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
		
	if tick_timer and not tick_timer.timeout.is_connected(_on_tick_timer_timeout):
		tick_timer.timeout.connect(_on_tick_timer_timeout)

func _process(delta: float) -> void:
	if est_detruite or est_amorcee:
		return 
		
	if player and is_instance_valid(player):
		direction = global_position.direction_to(player.global_position)
	
	global_position += direction * speed * delta

func _on_area_entered(area: Area2D) -> void:
	if est_detruite:
		return
		
	if area.is_in_group("player_laser") or area.name == "Laser":
		area.queue_free() 
		if not est_amorcee:
			amorcer_mine() 
		
	elif area.is_in_group("player"):
		if area.has_method("prendre_degats"):
			area.prendre_degats(1000) 
		explode_aoe() 

func amorcer_mine() -> void:
	est_amorcee = true
	if tick_timer:
		tick_timer.start(0.4) 
		_on_tick_timer_timeout() 

func _on_tick_timer_timeout() -> void:
	if ticks_restants > 0:
		if tick_sound:
			tick_sound.play()
			
		modulate = Color(1, 0, 0) 
		await get_tree().create_timer(0.15).timeout
		modulate = Color(1, 1, 1) 
		
		ticks_restants -= 1
	else:
		tick_timer.stop()
		explode_aoe()

# === HNA FIN SLL7NA L-MOCHKIL ===
func explode_aoe() -> void:
	if est_detruite:
		return 
	est_detruite = true
	
	if hitbox:
		hitbox.set_deferred("disabled", true)

	var areas_in_radius = explosion_radius.get_overlapping_areas()
	for a in areas_in_radius:
		if a.is_in_group("enemies") or a.is_in_group("enemy2"):
			# 1. N-choufo wash hada Boss (7it 3ndo variable "vie")
			if "vie" in a:
				a.vie -= 20
				if a.vie <= 0:
					if a.has_method("die"):
						a.die()
				else:
					# N-lounouh b l-7mer chwiya hit t-derreb
					a.modulate = Color(1, 0, 0)
					get_tree().create_timer(0.1).timeout.connect(func(): if is_instance_valid(a): a.modulate = Color(1, 1, 1))
					
			# 2. Ila makanch Boss, idan 3dou 3adi, ymout f l-blassa
			elif a.has_method("explode"):
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
