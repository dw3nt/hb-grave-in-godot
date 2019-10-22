extends Node

const MAX_ENEMY_COUNT = 5

onready var enemies = [ load("res://Knight.tscn"), load("res://Crow.tscn"), load("res://Crow.tscn") ]

func _ready():
	randomize()
	

func _process(delta):
	var enemyCount = $Enemies.get_child_count()
	
	if enemyCount < MAX_ENEMY_COUNT:
		var enemy = enemies[randi() % enemies.size()].instance()
		enemy.global_position = $Skeleton.global_position
		enemy.global_position.x += rand_range(200, 300)
		$Enemies.add_child(enemy)