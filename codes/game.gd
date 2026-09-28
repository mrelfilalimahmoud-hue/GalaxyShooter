extends Node2D

# === Preloads dyal les Scènes w les Textures ===
var enemy_scene = preload("res://scenes/enemy.tscn")
var enemy2_scene = preload("res://scenes/enemy_2.tscn")
var boss_scene = preload("res://scenes/boss_1.tscn")
var boss2_scene = preload("res://scenes/boss_2.tscn") 
var mine_scene = preload("res://scenes/mine.tscn")
var meteor_decor_scene = preload("res://scenes/meteor_decor.tscn")
var hp_bonus_scene = preload("res://scenes/hp_bonus.tscn")
var upgraded_icon_texture = preload("res://assets/Player/player_r_m.png")

# === Variables d l-état w l-we9t ===
var screen_size : Vector2
var jeu_en_cours : bool = true
var score : float = 1.0

var ennemis_tues : int = 0
var ennemis_vivants : int = 0

var boss_1_apparu : bool = false
var boss_2_apparu : bool = false
var boss_est_mort : bool = false # Hadi kat3ni Boss 1 mat bash tbda Phase 2

var chronometre_bonus : float = 0.0
var chronometre_mine : float = 0.0

func _ready():
	screen_size = get_viewport_rect().size
	var player = $Player
	if player:
		player.mise_a_jour_ui.connect(_on_player_mise_a_jour_ui)
		player.game_over.connect(_on_player_game_over)
		
		# Signal dyal l-upgrade mli yakl l-bonus d Boss 1
		if player.has_signal("player_upgraded"):
			player.player_upgraded.connect(_on_player_upgraded)


# === PHASE 1 : ENEMY 1 (Stochastique / Markov) ===
func _on_enemy_spawner_timeout() -> void:
	var enemy = enemy_scene.instantiate()
	enemy.mort.connect(_on_ennemi_mort)
	
	# 1. Nchoufo fin wa9ef l-Player dba (L'état actuel X_n)
	var player_x = screen_size.x / 2.0 # par défaut f l-west
	if has_node("Player"):
		player_x = $Player.global_position.x
		#position Xn {chaine de markov}
		
	# 2. L-Calcul Stochastique (Distribution Normale)
	# randfn(moyen, ecart_type) -> kay3ti probabilité kbira yti7 f l-moyen (player_x)
	var random_x = randfn(player_x, 100.0) 
	
	#loi normale X_n+1 ~ N(mu , sigma^2)
	#mu = playerx == Xn
	#sigma == 100px (erreur) 
	
	# 3. N-t2ekdo blli l-9ima makhrejatch 3la jnab d chacha
	random_x = clamp(random_x, 40.0, screen_size.x - 40.0)
	
	var start_y = -50.0
	enemy.global_position = Vector2(random_x, start_y)
	add_child(enemy)

func _on_ennemi_mort() -> void:
	ennemis_tues += 1
	print("Kills: ", ennemis_tues)
	
	# Boss 1 kaykherrej f 30 kills dyal enemy 1
	if ennemis_tues == 20 and not boss_1_apparu:
		boss_1_apparu = true
		faire_apparaitre_boss(1)
		
	# Boss 2 kaykherrej f 60 kills (30 dyal enemy 1 + 30 dyal enemy 2)
	elif ennemis_tues == 30 and not boss_2_apparu:
		boss_2_apparu = true
		faire_apparaitre_boss(2)

# === FONCTION KATMSSAH L-ACHRAR W KATKHEREJ L-BOSS ===
func faire_apparaitre_boss(niveau : int) -> void:
	# 1. N-7ebso ga3 spawner (Enemy 1 w Wave d Enemy 2)
	if has_node("EnemySpawner"):
		$EnemySpawner.stop()
	if has_node("WaveTimer"):
		$WaveTimer.stop()
		
		
	# 3. N-kherjou l-Boss
	var boss
	if niveau == 1:
		boss = boss_scene.instantiate()
		boss.tree_exited.connect(_on_boss_1_died) # Connectiw l'Boss 1 b fonction dyalo
	elif niveau == 2:
		boss = boss2_scene.instantiate()
		boss.tree_exited.connect(_on_boss_2_died) # Connectiw l'Boss 2 b fonction dyalo
		
	var boss_x = screen_size.x / 2.0
	var boss_y = -100.0 
	boss.global_position = Vector2(boss_x, boss_y)
	add_child(boss)

# === MOUT DYAL BOSS 1 (BIDAYAT PHASE 2) ===
func _on_boss_1_died() -> void:
	boss_est_mort = true # Katbda phase d mines w v-formation
	
	#jdid
	ennemis_tues = 0
	
	# N-tsnnaw 2 tawan bash yakhod l-player l-bonus 3ad njibou l-wave jdida
	await get_tree().create_timer(2.0).timeout
	spawn_v_formation()
	
	# N-khdmo WaveTimer dyal enemy 2 (W MAN-KHDMOUCH EnemySpawner l9dim)
	if has_node("WaveTimer"):
		$WaveTimer.start()

# === MOUT DYAL BOSS 2 ===
func _on_boss_2_died() -> void:
	print("VICTOIRE ! Boss 2 mat w l-jeu sala (wla zid niveau 3) !")
	# Hna t9der tzid l-menu dyal YOU WIN

# === PHASE 2 : V-FORMATION (ENEMY 2) ===
func spawn_v_formation() -> void:
	# N-verifiw wash Boss 2 ba9i makhrejsh
	if boss_2_apparu:
		return 
		
	var visible_rect = get_viewport().get_visible_rect()
	var centre_x = visible_rect.size.x / 2.0
	var centre_y = visible_rect.size.y / 2.0 
	
	var formation = [
		{"x": 0, "y_start": -50, "y_cible": centre_y - 80},     
		{"x": -70, "y_start": -100, "y_cible": centre_y - 130},        
		{"x": 70, "y_start": -100, "y_cible": centre_y - 130},          
		{"x": -140, "y_start": -150, "y_cible": centre_y - 180},   
		{"x": 140, "y_start": -150, "y_cible": centre_y - 180}     
	]
	
	ennemis_vivants = formation.size()
	for pos in formation:
		var enemy2 = enemy2_scene.instantiate()
		enemy2.mort.connect(_on_ennemi_mort) # Nfs l-compteur d l'kills
		
		enemy2.global_position = Vector2(centre_x + pos["x"], pos["y_start"])
		enemy2.target_y = pos["y_cible"]
		enemy2.offset_x = pos["x"] 
		add_child(enemy2)

func _on_wave_timer_timeout() -> void:
	# Ila baqi mawsalnash l phase 2 awla dkhelna f phase d boss 2, maydir walo
	if not boss_est_mort or boss_2_apparu:
		return
		
	var remaining_enemies = get_tree().get_node_count_in_group("enemy2")
	if remaining_enemies == 0:
		$WaveTimer.stop()
		await get_tree().create_timer(2.0).timeout
		
		# N-t'akdou mara akhra blli mabghinash njibou Boss 2 f had l-la7da
		if get_tree().get_node_count_in_group("enemy2") == 0 and not boss_2_apparu:
			spawn_v_formation()
			$WaveTimer.start()

# === UI W UPGRADE ===
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
		
		life1.visible = (vies_restantes >= 1)
		life2.visible = (vies_restantes >= 2)
		life3.visible = (vies_restantes == 3)

# === EVENTS DYAL L-WE9T (SCORE, MINES, BONUS) ===
func _process(delta: float) -> void:
	if jeu_en_cours:
		if has_node("%ScoreLabel"):
			score += 15.0 * delta 
			var str_score = str(int(score))
			var mon_label = get_node("%ScoreLabel")
			mon_label.text = str_score
			
			var nb_chiffres = str_score.length()
			if nb_chiffres > 4:
				var taille = max(20, 45 - ((nb_chiffres - 4) * 5))
				mon_label.add_theme_font_size_override("font_size", taille)
			else:
				mon_label.add_theme_font_size_override("font_size", 45)
				
		chronometre_bonus += delta
		if chronometre_bonus >= 90.0:
			spawn_hp_bonus()
			chronometre_bonus = 0.0 
			
		# L-mines kaybdaw ghir mli ymout Boss 1
		if boss_est_mort:
			chronometre_mine += delta
			if chronometre_mine >= 10.0:
				spawn_mine()
				chronometre_mine = 0.0 

# === SPAWNERS JDAD (BONUS, MINE, METEOR) ===
func spawn_hp_bonus() -> void:
	var bonus = hp_bonus_scene.instantiate()
	var random_x = randf_range(40.0, screen_size.x - 40.0)
	bonus.global_position = Vector2(random_x, -50.0)
	add_child(bonus)

func spawn_mine() -> void:
	var mine = mine_scene.instantiate()
	var random_x = randf_range(40.0, screen_size.x - 40.0)
	mine.global_position = Vector2(random_x, -50.0)
	add_child(mine)

func _on_meteor_timer_timeout() -> void:
	for i in range(2):
		var decor_meteor = meteor_decor_scene.instantiate()
		var spawn_side = randi() % 3
		var spawn_pos = Vector2.ZERO
		
		match spawn_side:
			0:
				spawn_pos = Vector2(randf_range(0, screen_size.x), -50.0)
			1:
				spawn_pos = Vector2(-50.0, randf_range(0, screen_size.y / 2.0))
			2:
				spawn_pos = Vector2(screen_size.x + 50.0, randf_range(0, screen_size.y / 2.0))
		
		decor_meteor.global_position = spawn_pos
		add_child(decor_meteor)
		move_child(decor_meteor, 1)

# === GAME OVER W PAUSE ===
func _on_player_game_over() -> void:
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
	if has_node("WaveTimer"):
		$WaveTimer.stop()
		
	get_tree().paused = true

func _on_pause_button_pressed() -> void:
	if jeu_en_cours:
		get_tree().paused = true 
		if has_node("PauseMenu"):
			$PauseMenu.show()
