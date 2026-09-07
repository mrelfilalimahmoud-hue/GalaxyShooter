extends Control


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_map_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/map_menu.tscn")



func _on_facebook_pressed() -> void:
	pass # Replace with function body.
