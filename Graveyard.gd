extends Node

const MAX_ENEMY_COUNT = 5
const PLAYER_WALL_RANGE = 300 	# this is an estimate
const CAMERA_OFFSET = 200 		# this is an estimate
const ENEMY_BUFFER = 20 		# this is an estimate
const ENEMY_BUFFER_LOW = 8		# this is an estimate
const ENEMY_BUFFER_HIGH = 16	# this is an estimate

var screenShake = 0
var deathCam
var isBoss = false

onready var enemies = [ load("res://Knight.tscn"), load("res://Crow.tscn"), load("res://Crow.tscn") ]
onready var enemiesWithBoss = [ load("res://Knight.tscn"), load("res://Crow.tscn"), load("res://Boss.tscn"), load("res://Boss.tscn") ]
onready var wallLeftX = $Environment/WallLeft.global_position.x + 20
onready var wallRightX = $Environment/WallRight.global_position.x - 20

func _ready():
	randomize()
	

func _process(delta):
	var enemyCount = $Enemies.get_child_count()
	
	if find_node("Skeleton"):
		if (enemyCount < ($Skeleton.kills / 4) && enemyCount <= MAX_ENEMY_COUNT) || enemyCount == 0:
			var enemy = null
			if $Skeleton.kills > 5 && !isBoss:
				enemy = enemiesWithBoss[randi() % enemies.size()].instance()
			else:
				enemy = enemies[randi() % enemies.size()].instance()
				
			enemy = enemiesWithBoss[randi() % enemies.size()].instance()
			enemy.connect("enemy_death", $Skeleton, "_on_Enemy_Death")
			$Skeleton.connect("player_death", enemy, "_on_Player_Death")
			
			enemy.global_position.y = $Skeleton.global_position.y
			if enemy.name == "Boss":
				enemy.global_position.y -= 16
				isBoss = true
				enemy.connect("boss_death", self, "_on_Boss_Death")
				
			enemy.global_position.x = enemy_x_pos()
			$Enemies.add_child(enemy)
	else:
		if screenShake > 0:
			process_camera_shake()
		
		
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
	
	
func process_camera_shake():
	if screenShake > 0.15:	# lessening by 15% everytime means I'll never really hit 0
		deathCam.offset = Vector2(rand_range(-screenShake, screenShake), rand_range(-screenShake, screenShake) - 36)
		screenShake *= 0.85	# lessent shake by 15% each frame - basically this is the duration
	else:
		# set back to normal offset
		deathCam.offset = Vector2(0, -36)
		screenShake = 0
	

func _on_Skeleton_player_death():	# switch cameras so I can delete player node
	deathCam = $Skeleton/Camera.duplicate()
	deathCam.global_position = $Skeleton/Camera.get_camera_position()
	deathCam.global_position.x = $Skeleton/Camera.get_camera_screen_center().x
	deathCam.offset_h = 0
	
	add_child(deathCam)
	deathCam.current = true
	screenShake = 17
	$Skeleton.queue_free()
	
	
func _on_Boss_Death():
	isBoss = false
