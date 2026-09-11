extends Area2D

var speed : float = 1200.0 
var state : String = "spawn" # L'7ala l'bad2iya

# === JDID: Variable d l-damage (kat-t-beddel f shoot() d player) ===
var degats : int = 1 

@onready var anim = $AnimatedSprite2D

func _ready():
	# Zid had l-khat hna b l-code
	add_to_group("player_laser")
	# 1. Kanbdaw b tsawira dyal l'khoroj mn l'mdfe3
	anim.play("spawn")
	
	# Kantsnaw wa7d l'joz2 sghir mn taniya (0.05s) bach tban l'cha3la
	await get_tree().create_timer(0.01).timeout
	
	# 2. Kandouzou l'tsawira dyal l'hwa (ila makantch deja tfrg3at)
	if state != "impact":
		state = "travel"
		anim.play("travel")

func _process(delta):
	# L'qortasa katl3 lfo9 ghir ila kant f l'hwa awla yallah khrjat
	if state == "travel" or state == "spawn":
		global_position.y -= speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

# 3. L'fonction li ghadi n3iyto liha mli l'qortasa t9iss l'3dou (Enemies)
func explode():
	state = "impact"
	anim.play("impact")
	speed = 0 # Kat7bess f blassetha mli kat9iss l'3dou
	
	# Kantsnaw l'infijar yban (0.1s) w kanms7ouha
	await get_tree().create_timer(0.1).timeout
	queue_free()
