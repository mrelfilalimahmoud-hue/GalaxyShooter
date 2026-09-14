extends Node2D

# Kanjbdo la scène dyal l'3dou
var enemy_scene = preload("res://scenes/enemy.tscn")
var boss_scene = preload("res://scenes/boss_1.tscn") # Zidna l-boss hna
var enemy2_scene = preload("res://scenes/enemy_2.tscn")
var mine_scene = preload("res://scenes/mine.tscn")

var screen_size : Vector2
var boss_est_arrive : bool = false

var ennemis_tues : int = 0
var boss_1_apparu : bool = false
var boss_2_apparu : bool = false
var score : float = 1.0
var jeu_en_cours : bool = true
var meteor_decor_scene = preload("res://scenes/meteor_decor.tscn")
var ennemis_vivants : int = 0
var is_spawning_wave : bool = false
var boss_est_mort : bool = false
var hp_bonus_scene = preload("res://scenes/hp_bonus.tscn")
var chronometre_bonus : float = 0.0 # Ghadi n-7esbo biha l-we9t
var chronometre_mine : float = 0.0



func _ready():
	var boss = get_tree().get_first_node_in_group("enemies")
	if boss and boss.has_signal("boss_mort"):
		boss.boss_mort.connect(_on_boss_died)
	screen_size = get_viewport_rect().size
	var player = $Player
	if player:
		player.mise_a_jour_ui.connect(_on_player_mise_a_jour_ui)
		player.game_over.connect(_on_player_game_over)
		
# Had l'fonction kat-t3iyyet kol taniya (3la 7sab l'Timer)



func _on_enemy_spawner_timeout() -> void:
	var enemy = enemy_scene.instantiate()
	enemy.mort.connect(_on_ennemi_mort)
	# N3zlo blassa random f l'axe X (bin 40 w 680 bash maykhrjsh f jnab d chacha)
	var random_x = randf_range(40.0, screen_size.x - 40.0)
	
	# Y katkon saliba (-50) bash ybda mn lfo9 lbarra dyal chacha 3ad yhbet
	var start_y = -50.0
	
	enemy.global_position = Vector2(random_x, start_y)
	
	# Kanzidou l'3dou f l'jeu
	add_child(enemy)

func _on_ennemi_mort() -> void:
	ennemis_tues += 1
	print("Kills: ", ennemis_tues) # Bach tchouf l7ssab f console
	
	# Nchoufo wach wselna l-30 wla 60
	if ennemis_tues >= 2 and not boss_1_apparu:
		boss_1_apparu = true
		faire_apparaitre_boss(1)


func faire_apparaitre_boss(niveau : int) -> void:
	# 1. N-7ebso Timer dyal l'3dyan l-3adiyin
	if has_node("EnemySpawner"):
		$EnemySpawner.stop()
		
	# 2. N-ms7ou ga3 l'3dyan li baqyin f chacha (ila kano f group "enemies")
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.queue_free()
		
	# 3. N-kherjou l-Boss
	var boss
	if niveau == 1:
		boss = boss_scene.instantiate()
	elif niveau == 2:
		boss = boss_scene.instantiate() # Hna bedlha b boss_2_scene ila 3ndek
		
	# Mli ymout lboss, yrj3o tiyarat
	boss.tree_exited.connect(_on_boss_died)
	
	# N-7ttoh f l-wst dyal chacha (axe X) w kharej mn lfo9 (axe Y) bach yhbet
	var boss_x = screen_size.x / 2.0
	var boss_y = -100.0 
	
	boss.global_position = Vector2(boss_x, boss_y)
	add_child(boss)

func _on_boss_died() -> void:
	boss_est_mort = true # هنا كنعلمو بلي البوس مات صافي
	await get_tree().create_timer(1.0).timeout
	spawn_v_formation()
	#if has_node("EnemySpawner"):
		#$EnemySpawner.start()
		
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

func _process(delta: float) -> void:
	if jeu_en_cours:
		# Ila l'Label kayn f chacha
		if has_node("%ScoreLabel"):
			# Zid l'score
			score += 15.0 * delta 
			var str_score = str(int(score))
			
			# Jbed l'Label w bdel l-ktaba
			var mon_label = get_node("%ScoreLabel")
			mon_label.text =  str_score
			
			# Ajustement dyal l'Khat
			var nb_chiffres = str_score.length()
			if nb_chiffres > 4:
				var taille = 45 - ((nb_chiffres - 4) * 5)
				if taille < 20:
					taille = 20
				mon_label.add_theme_font_size_override("font_size", taille)
			else:
				mon_label.add_theme_font_size_override("font_size", 45)
		# === ZID HAD L-PARTIE JDIDA HNA ===
		chronometre_bonus += delta
		if chronometre_bonus >= 90.0:
			spawn_hp_bonus()
			chronometre_bonus = 0.0 # N-raj3ou l-3adad l zero bash y3awd y7seb 60s
		# ==================================
		# Ila l-boss mat (ya3ni dkhlna f Level 2)
		if boss_est_mort:
			chronometre_mine += delta
			if chronometre_mine >= 10.0:
				spawn_mine()
				chronometre_mine = 0.0 # N-raj3ou l-we9t l-ziro bach y7seb 10s akhra
		# ============================

func _on_player_game_over() -> void:
	print("GAME OVER! L-Player mat!")
	jeu_en_cours = false
	if has_node("UI/LivesContainer"):
		$UI/LivesContainer/Life1.visible = false
		$UI/LivesContainer/Life2.visible = false
		$UI/LivesContainer/Life3.visible = false
	
	if has_node("GameOverSound"):
		$GameOverSound.play()
		
	# === JDID: N-7ebso mosi9a d-khalfya (Ila bghaytiha tesket) ===
	if has_node("BackgroundMusic"):
		$BackgroundMusic.stop()
		
	# N-7ebso Tiyarat l-3adiyin bash mayb9awch yti7o
	if has_node("EnemySpawner"):
		$EnemySpawner.stop()
	get_tree().paused = true


func spawn_v_formation() -> void:
	# نتاكدو واش البوس (اللي في جروب enemies) باقي حي ولا مات
	var boss = get_tree().get_first_node_in_group("enemies")
	if is_instance_valid(boss):
		return # إلا كان البوس باقي حي، ما تسـپـاودش Enemy2 كاع
	# نجبدو الأبعاد الحقيقية والظاهرة ديال الشاشة بدقة
	var visible_rect = get_viewport().get_visible_rect()
	var centre_x = visible_rect.size.x / 2.0
	var centre_y = visible_rect.size.y / 2.0 
	
	var formation = [
		{"x": 0, "y_start": -50, "y_cible": centre_y - 80},       # الرأس ديال السهم
		{"x": -70, "y_start": -100, "y_cible": centre_y - 130},         # الجناح الأيسر 1
		{"x": 70, "y_start": -100, "y_cible": centre_y - 130},          # الجناح الأيمن 1
		{"x": -140, "y_start": -150, "y_cible": centre_y - 180},   # الجناح الأيسر 2
		{"x": 140, "y_start": -150, "y_cible": centre_y - 180}     # الجناح الأيمن 2
	]
	# نحدّدو شحال من عدو كاين في السرب (مثلاً 5 هنا)
	ennemis_vivants = formation.size()
	for pos in formation:
		var enemy2 = enemy2_scene.instantiate()
		enemy2.mort.connect(_on_ennemi_mort)
		
		# الاعتماد على centre_x الحقيقي باش يتسـپـاوضو في الوسط تماماً
		enemy2.global_position = Vector2(centre_x + pos["x"], pos["y_start"])
		
		enemy2.target_y = pos["y_cible"]
		enemy2.offset_x = pos["x"] 
		
		add_child(enemy2)
	

func _on_meteor_timer_timeout() -> void:
	for i in range(2):
		var decor_meteor = meteor_decor_scene.instantiate()
		var screen_size = get_viewport_rect().size
		
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
		
		# 1. نضيفوه للعبة
		add_child(decor_meteor)
		
		# 2. نردوه مباشرة فوق الخلفية (الرقم 1 أو 2 على حسب فين كاين عندك الخلفية في الـ Scene Tree)
		# تأكد أن الخلفية هي الأولى كاع (Index 0)، إذن النيازك نديروهم في Index 1 باش يبانو فوقها وتحت اللاعب والأعداء
		move_child(decor_meteor, 1)




func process2(_delta: float) -> void:
	# إلا البوس مازال حي، حبس وما تقلبش على الأعداء في البداية
	if not boss_est_mort:
		return
		
	# إلا ما كناش ديماندين سرب جديد، نشوفو شحال باقيين ديال enemy2
	if not is_spawning_wave:
		var remaining_enemies = get_tree().get_node_count_in_group("enemy2")
		
		# إلا ماتوا كاملين والعدد وصل لـ 0
		if remaining_enemies == 0:
			is_spawning_wave = true # نحبسوا التكرار مؤقتاً
			
			# نتسناو 2 ثواني عاد يجي السرب الموالي
			await get_tree().create_timer(2.0).timeout
			
			# نعاودو نتأكدو بلي مازال 0 وعاد نكاريو السرب الجديد
			if get_tree().get_node_count_in_group("enemy2") == 0:
				spawn_v_formation()
				
			is_spawning_wave = false # نرجعو نطلقو المراقبة

func _on_wave_timer_timeout() -> void:
	if not boss_est_mort:
		return
	# نحسبو شحال باقي ديال enemy2 في اللعبة
	var remaining_enemies = get_tree().get_node_count_in_group("enemy2")
	
	# إلا ماتوا كاملين (العدد وصل لـ 0)
	if remaining_enemies == 0:
		# نوقفوا التيمر مؤقتاً باش ما يبقاش يعاود يدخل كل ثانية وحنا كنتسناو
		$WaveTimer.stop()
		
		# نتسناو 2 ثواني عاد يجي السرب الموالي
		await get_tree().create_timer(2.0).timeout
		
		# نعاودو نتأكدو بلي مازال 0 (احتياطاً) وعاد نكاريو السرب الجديد
		if get_tree().get_node_count_in_group("enemy2") == 0:
			spawn_v_formation()
			
		# نعاودو نشعلو التيمر باش يبقى يراقب السرب الجديد عتاني
		$WaveTimer.start()
		
func spawn_hp_bonus() -> void:
	var bonus = hp_bonus_scene.instantiate()
	# N-khtarou blassa 3achwaiya f l'axe X
	var random_x = randf_range(40.0, screen_size.x - 40.0)
	
	# Ybda yti7 mn l-fo9 kharej mn chacha
	bonus.global_position = Vector2(random_x, -50.0)
	add_child(bonus)

func spawn_mine() -> void:
	var mine = mine_scene.instantiate()
	
	# N-khtarou blassa 3achwaiya f l-axe X (b7al l-meteors w l-3dyan)
	var random_x = randf_range(40.0, screen_size.x - 40.0)
	
	# Ybda yti7 mn l-fo9 kharej mn chacha
	mine.global_position = Vector2(random_x, -50.0)
	
	add_child(mine)
func _on_pause_button_pressed() -> void:
	# Ila l-player baqi 7ay w l-game makhessersh
	if jeu_en_cours:
		get_tree().paused = true # Kan-jamdou l-jeu (l-3dyan, l-we9t, kolchi)
		if has_node("PauseMenu"):
			$PauseMenu.show() # Kan-biynou l-menu dyal pause
