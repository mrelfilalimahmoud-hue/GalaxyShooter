extends Area2D

var speed : float = 100.0 

# 1. Kan-chargiw la scène dyal l'qortas
var enemy_laser_scene = preload("res://scenes/enemy_laser.tscn")
var explosion_scene = preload("res://scenes/explosion.tscn")
# 2. Kanjbdo l'Muzzle li sawbna
@onready var muzzle = $Muzzle
@onready var anim = $AnimatedSprite2D
func _process(delta):
	# L'enemy kayhbet lta7t
	global_position.y += speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

# 3. Had l'fonction kat-txdm kol 3 tawan (b sbabb l'Timer)




func _on_shoot_timer_timeout() -> void:
	# Nsaybo nskha jdida mn l'qortas
	var laser = enemy_laser_scene.instantiate()
	
	# 4. Hna fin s7i7: Kan7tto l'qortas bdbt f blassa d Muzzle li 7tina f fomm l'enemy
	laser.global_position = muzzle.global_position
	
	# Nzidou l'qortas f l'jeu kaml (root)
	get_tree().root.add_child(laser)




func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_laser") or area.name == "Laser": # 3la 7sab smiyt l'laser dyalk
		# Hna t9dar t3yyt l'fonction d'infijar awla tmsso bmara
	 # Kaytmseh l'enemy
		area.queue_free()
		explode()
	elif area.is_in_group("player"):
		if area.has_method("prendre_degats"):
			area.prendre_degats(15) # الـ Player كينقص ليه 15
		explode()


func explode():
	# 1. Nsaybo nskha mn l'infijar w n-7ttoha f nfs l'blassa dyal l'enemy
	var explosion = explosion_scene.instantiate()
	explosion.global_position = global_position
	get_tree().root.add_child(explosion)
	
	# 2. Nmsse7o l'enemy f nfs l'lahda
	queue_free()        # Kaytmseh l'enemy f lahkra
