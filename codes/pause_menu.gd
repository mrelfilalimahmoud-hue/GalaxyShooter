extends CanvasLayer

func _ready() -> void:
	hide() # N-khbiw l-menu f l-bidaya dyal l-game

func _on_resume_button_pressed() -> void:
	# Mli kan-berko 3la Completer
	get_tree().paused = false # Kan-tleqou l-game
	hide() # Kan-khbiw l-menu

func _on_restart_button_pressed() -> void:
	# Mli kan-berko 3la I3ada
	get_tree().paused = false # Kan-tleqou l-game 9bel man-3awdouh
	get_tree().reload_current_scene() # Kan-3awdou la scène mn l-wl

func _on_exit_button_pressed() -> void:
	# Mli kan-berko 3la Khroj
	get_tree().paused = false 
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn") # Kan-rj3ou l-menu principal
