extends Node2D

# Kanjbdo la scène dyal l'3dou
var enemy_scene = preload("res://scenes/enemy.tscn")
var boss_scene = preload("res://scenes/boss_1.tscn") # Zidna l-boss hna

var screen_size : Vector2
var boss_est_arrive : bool = false

func _ready():
	screen_size = get_viewport_rect().size
	var player = $Player
	if player:
		player.mise_a_jour_ui.connect(_on_player_mise_a_jour_ui)
		player.game_over.connect(_on_player_game_over)
		
# Had l'fonction kat-t3iyyet kol taniya (3la 7sab l'Timer)



func _on_enemy_spawner_timeout() -> void:
	var enemy = enemy_scene.instantiate()
	
	# N3zlo blassa random f l'axe X (bin 40 w 680 bash maykhrjsh f jnab d chacha)
	var random_x = randf_range(40.0, screen_size.x - 40.0)
	
	# Y katkon saliba (-50) bash ybda mn lfo9 lbarra dyal chacha 3ad yhbet
	var start_y = -50.0
	
	enemy.global_position = Vector2(random_x, start_y)
	
	# Kanzidou l'3dou f l'jeu
	add_child(enemy)


func _on_boss_1_timer_timeout() -> void:
	if not boss_est_arrive:
		boss_est_arrive = true
		
		# 1. N-7ebso Timer dyal l'3dyan l-3adiyin
		# (T2ked bli smyat l-Timer dyalk hiya "EnemySpawner")
		if has_node("EnemySpawner"):
			$EnemySpawner.stop()
			
		# 2. N-ms7ou ga3 l'3dyan li baqyin
		for enemy in get_tree().get_nodes_in_group("enemies"):
			enemy.queue_free()
			
		# 3. N-kherjou l-Boss
		var boss = boss_scene.instantiate()
		boss.tree_exited.connect(_on_boss_died)
		# N-7ttoh f l-wst dyal chacha (axe X) w kharej mn lfo9 (axe Y) bach yhbet
		var boss_x = screen_size.x / 2.0
		var boss_y = -100.0 
		
		boss.global_position = Vector2(boss_x, boss_y)
		
		add_child(boss)
		
func _on_boss_died() -> void:
	if has_node("EnemySpawner"):
		$EnemySpawner.start()
		
func _on_player_mise_a_jour_ui(vie: int, vies_restantes: int) -> void:
	# 1. N-bedlo d-dem f l-ProgressBar
	if has_node("UI/HealthBar"):
		$UI/HealthBar.value = vie
	
	# 2. N-biynou wla n-khbiw les icones (Tiyarat)
	if has_node("UI/LivesContainer"):
		var life1 = $UI/LivesContainer/Life1
		var life2 = $UI/LivesContainer/Life2
		var life3 = $UI/LivesContainer/Life3
		
		if vies_restantes == 3:
			life1.visible = true
			life2.visible = true
			life3.visible = true
		elif vies_restantes == 2:
			life1.visible = true
			life2.visible = true
			life3.visible = false
		elif vies_restantes == 1:
			life1.visible = true
			life2.visible = false
			life3.visible = false
		else:
			life1.visible = false
			life2.visible = false
			life3.visible = false

func _on_player_game_over() -> void:
	print("GAME OVER! L-Player mat!")
