extends Area2D

var vitesse : float = 150.0

func _ready() -> void:
	# Connecter les signals b l-code bash t-hnnay
	area_entered.connect(_on_touche)
	body_entered.connect(_on_touche)

func _process(delta: float) -> void:
	position.y += vitesse * delta

func _on_touche(target: Node) -> void:
	# Kay-checki wash target huwa l-Player (Majuscule awla Minuscule)
	if target.is_in_group("player") or target.name == "Player" or target.name == "player":
		if target.has_method("upgrade_ship"):
			target.upgrade_ship()
		
		queue_free() # Kay-khtafi 100% daba!



func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
