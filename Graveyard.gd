extends Node

const MAX_ENEMY_COUNT = 5
const PLAYER_WALL_RANGE = 300 	# this is an estimate
const CAMERA_OFFSET = 200 		# this is an estimate
const ENEMY_BUFFER = 20 		# this is an estimate
const ENEMY_BUFFER_LOW = 8		# this is an estimate
const ENEMY_BUFFER_HIGH = 16	# this is an estimate

onready var enemies = [ load("res://Knight.tscn"), load("res://Crow.tscn"), load("res://Crow.tscn") ]
onready var wallLeftX = $Environment/WallLeft.global_position.x + 20
onready var wallRightX = $Environment/WallRight.global_position.x - 20

func _ready():
	randomize()
	

func _process(delta):
	var enemyCount = $Enemies.get_child_count()
	
	if (enemyCount < ($Skeleton.kills / 4) && enemyCount <= MAX_ENEMY_COUNT) || enemyCount == 0 && $Skeleton.state != $Skeleton.State.DEATH:
		print("spawned")
		var enemy = enemies[randi() % enemies.size()].instance()
		enemy.connect("enemy_death", $Skeleton, "_on_Enemy_Death")
		
		enemy.global_position.y = $Skeleton.global_position.y
		enemy.global_position.x = enemy_x_pos()
		$Enemies.add_child(enemy)
		
		
func enemy_x_pos():
	var skeletonX = $Skeleton.global_position.x
	var xPos = null
	
	# spawn inside walls
	if (skeletonX - wallLeftX) < PLAYER_WALL_RANGE:
		xPos = max(rand_range(skeletonX + CAMERA_OFFSET, wallRightX), wallRightX)
	elif (wallRightX - skeletonX) < PLAYER_WALL_RANGE:
		xPos = min(rand_range(wallLeftX, skeletonX - CAMERA_OFFSET), wallLeftX)
	else:
		if bool(randi() % 2):
			xPos = max(rand_range(skeletonX + CAMERA_OFFSET, wallRightX), wallRightX)
		else:
			xPos = min(rand_range(wallLeftX, skeletonX - CAMERA_OFFSET), wallLeftX)
			
	# don't spawn on top of each other
	for node in $Enemies.get_children():
		var pos = node.global_position.x
		var distance = abs(xPos - pos)
		var dir = sign(xPos - pos)
		if distance < ENEMY_BUFFER:
			if dir < 0:
				xPos -= rand_range(ENEMY_BUFFER_LOW, ENEMY_BUFFER_HIGH)
			else:
				xPos += rand_range(ENEMY_BUFFER_LOW, ENEMY_BUFFER_HIGH)
	
	# double check not outside walls
	if xPos < wallLeftX:
		xPos = wallLeftX
		
	if xPos > wallRightX:
		xPos = wallRightX
		
	return xPos
	
	