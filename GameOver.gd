extends Node

var gameScene = load("res://Graveyard.tscn")
var kills = 0
var highscore = 0

func _ready():
	var file = File.new()
	var result = file.open("user://scores.dat", File.READ)
	if result != 0:
		file.close()
		print("Error opening file: " + str(result))
		return
	else:
		var fileData = parse_json(file.get_line())
		file.close()
		
		kills = fileData.kills
		highscore = fileData.highscore
	
	$MarginContainer/CenterContainer/VBoxContainer/Kills.text = "Kills: " + str(kills)
	$MarginContainer/CenterContainer/VBoxContainer/Highscore.text = "Highscore: " + str(highscore)
	
	
func _process(delta):
	if Input.is_action_pressed("restart"):
		get_tree().change_scene_to(gameScene)