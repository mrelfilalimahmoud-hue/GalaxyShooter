extends Node2D

# Kanjbdo la scène dyal l'3dou w l-bosses
var enemy_scene = preload("res://scenes/enemy.tscn")
var boss_scene = preload("res://scenes/boss_1.tscn") 
var boss2_scene = preload("res://scenes/boss_2.tscn") # Zidna Boss 2 hna!

# === JDID: Preload dyal l-image d l-icon l-jdida dyal l-ship ===
var upgraded_icon_texture = preload("res://assets/Player/player_r_m.png") # T-aked mn l-path d l-image dyalk

var screen_size : Vector2
var boss_est_arrive : bool = false

var ennemis_tues : int = 0
var boss_1_apparu : bool = false
var boss_2_apparu : bool = false
var score : float = 1.0
var jeu_en_cours : bool = true

func _ready():
	screen_size = get_viewport_rect().size
	var player = $Player
	if player:
		player.mise_a_jour_ui.connect(_on_player_mise_a_jour_ui)
		player.game_over.connect(_on_player_game_over)
		
		# === JDID: Connecter l-signal d l-upgrade m3a la fonction d l-UI ===
		if player.has_signal("player_upgraded"):
			player.player_upgraded.connect(_on_player_upgraded)

func _on_enemy_spawner_timeout() -> void:
	var enemy = enemy_scene.instantiate()
	enemy.mort.connect(_on_ennemi_mort)
	var random_x = randf_range(40.0, screen_size.x - 40.0)
	var start_y = -50.0
	
	enemy.global_position = Vector2(random_x, start_y)
	add_child(enemy)

func _on_ennemi_mort() -> void:
	ennemis_tues += 1
	print("Kills: ", ennemis_tues)
	
	# Boss 1 f 30 Kills
	if ennemis_tues >= 30 and not boss_1_apparu:
		boss_1_apparu = true
		faire_apparaitre_boss(1)
	
	# Boss 2 f 60 Kills
	elif ennemis_tues >= 60 and not boss_2_apparu:
		boss_2_apparu = true
		faire_apparaitre_boss(2)

func faire_apparaitre_boss(niveau : int) -> void:
	# 1. N-7ebso Timer dyal l'3dyan l-3adiyin
	if has_node("EnemySpawner"):
		$EnemySpawner.stop()
		
	# 2. N-ms7ou ga3 l'3dyan li baqyin f chacha
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.queue_free()
		
	# 3. N-kherjou l-Boss 3la ḥsab l-niveau
	var boss
	if niveau == 1:
		boss = boss_scene.instantiate()
	elif niveau == 2:
		boss = boss2_scene.instantiate()
		
	boss.tree_exited.connect(_on_boss_died)
	
	var boss_x = screen_size.x / 2.0
	var boss_y = -100.0
	
	boss.global_position = Vector2(boss_x, boss_y)
	add_child(boss)

func _on_boss_died() -> void:
	if has_node("EnemySpawner"):
		$EnemySpawner.start()

# === JDID: Fonction kat-t-appela mli l-Player kay-t-upgrada ===
func _on_player_upgraded() -> void:
	if has_node("UI/LivesContainer"):
		$UI/LivesContainer/Life1.texture = upgraded_icon_texture
		$UI/LivesContainer/Life2.texture = upgraded_icon_texture
		$UI/LivesContainer/Life3.texture = upgraded_icon_texture

func _on_player_mise_a_jour_ui(vie: int, vies_restantes: int) -> void:
	if has_node("UI/HealthBar"):
		$UI/HealthBar.value = vie
	
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

func _process(delta: float) -> void:
	if jeu_en_cours:
		if has_node("%ScoreLabel"):
			score += 15.0 * delta 
			var str_score = str(int(score))
			
			var mon_label = get_node("%ScoreLabel")
			mon_label.text = str_score
			
			var nb_chiffres = str_score.length()
			if nb_chiffres > 4:
				var taille = 45 - ((nb_chiffres - 4) * 5)
				if taille < 20:
					taille = 20
				mon_label.add_theme_font_size_override("font_size", taille)
			else:
				mon_label.add_theme_font_size_override("font_size", 45)

func _on_player_game_over() -> void:
	print("GAME OVER! L-Player mat!")
	jeu_en_cours = false
	if has_node("UI/LivesContainer"):
		$UI/LivesContainer/Life1.visible = false
		$UI/LivesContainer/Life2.visible = false
		$UI/LivesContainer/Life3.visible = false
	
	if has_node("GameOverSound"):
		$GameOverSound.play()
		
	if has_node("BackgroundMusic"):
		$BackgroundMusic.stop()
		
	if has_node("EnemySpawner"):
		$EnemySpawner.stop()
	get_tree().paused = true
