extends Node2D

var levels = ["res://world_1.tscn","res://world_2.tscn"]
var count = 0

func _on_quit_pressed():
	get_tree().quit()


func _on_play_pressed():
	get_tree().change_scene_to_file("res://world_1.tscn")
	
	
	

func countUp():
	count+1
