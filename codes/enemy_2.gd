extends Area2D
signal mort

var speed : float = 180.0 
var hp : int = 3
var player = null

# سيناريوهات الليزر والانفجار
var enemy_laser_scene = preload("res://scenes/enemy_2_laser.tscn")
var explosion_scene = preload("res://scenes/explosion.tscn")

# متغيرات الهبوط بحال الـ Boss
var target_y : float = 0.0 
var offset_x : float = 0.0 
var est_en_place : bool = false
var vitesse_descente : float = 180.0


@onready var muzzle = $Muzzle
@onready var shoot_timer = $ShootTimer

func _ready():
	add_to_group("enemy2") # ضروري باش نقدروا نحسبوهم
	player = get_tree().get_first_node_in_group("player")

func _process(delta):
	if not est_en_place:
		# 1. المرحلة الأولى: الهبوط بحال الـ Boss
		global_position.y += vitesse_descente * delta
		if global_position.y >= target_y:
			global_position.y = target_y
			est_en_place = true
			if shoot_timer:
				shoot_timer.start() # غير يوقف، يبدا يتري بحال الـ Boss!
	else:
		# 2. المرحلة الثانية: تتبع اللاعب بـ V-formation مع الحفاظ على المسافة
		if player != null:
			var target_global_x = player.global_position.x + offset_x
			global_position.x = move_toward(global_position.x, target_global_x, speed * delta)
			
			var screen_width = get_viewport_rect().size.x
			global_position.x = clamp(global_position.x, 30.0, screen_width - 30.0)

# دالة التري (تطلق الليزر كلما سالا التيمر)
func _on_shoot_timer_timeout() -> void:
	if est_en_place:
		var laser = enemy_laser_scene.instantiate()
		laser.global_position = muzzle.global_position
		get_tree().root.add_child(laser)

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_area_entered(area: Area2D) -> void:

	if area.is_in_group("player_laser") or area.name == "Laser":
		area.queue_free()
		hp -= 1
		
		if hp <= 0:
			mort.emit()
			explode()
		else:
			modulate = Color(1, 0.3, 0.3)
			await get_tree().create_timer(0.1).timeout
			modulate = Color(1, 1, 1)
			
	elif area.is_in_group("player"):
		if area.has_method("prendre_degats"):
			area.prendre_degats(15)
		mort.emit()
		explode()

func explode():
	var explosion = explosion_scene.instantiate()
	explosion.global_position = global_position
	get_tree().root.add_child(explosion)
	queue_free()
