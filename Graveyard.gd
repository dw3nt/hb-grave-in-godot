extends Node

const MAX_ENEMY_COUNT = 5

onready var enemies = [ load("res://Knight.tscn"), load("res://Crow.tscn"), load("res://Crow.tscn") ]
onready var wallLeftX = $Environment/WallLeft.global_position.x + 20
onready var wallRightX = $Environment/WallRight.global_position.x - 20

func _ready():
	randomize()
	

func _process(delta):
	var enemyCount = $Enemies.get_child_count()
	
	if enemyCount < MAX_ENEMY_COUNT:
		var enemy = enemies[randi() % enemies.size()].instance()
		enemy.global_position.y = $Skeleton.global_position.y
		enemy.global_position.x = enemy_x_pos()
		$Enemies.add_child(enemy)
		
		
func enemy_x_pos():
	var skeletonX = $Skeleton.global_position.x
	
	if (skeletonX - wallLeftX) < 150:
		return max(rand_range(skeletonX + 200, wallRightX), wallRightX - 20)
	elif (wallRightX - skeletonX) < 150:
		return rand_range(wallLeftX, skeletonX - 200)
	else:
		if bool(randi() % 2):
			return rand_range(skeletonX + 200, wallRightX)
		else:
			return rand_range(wallLeftX, skeletonX - 200)