extends Control


func _on_map_1_button_pressed() -> void:
	Global.map_selectionnee = 1
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_map_2_button_pressed() -> void:
	Global.map_selectionnee = 2
	get_tree().change_scene_to_file("res://scenes/game.tscn")
