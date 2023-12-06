extends Node3D

@export var enemy_scene: PackedScene
var spawnRate = 20
@onready var options = [$SpawnPoint,$SpawnPoint2,$SpawnPoint3,$SpawnPoint4]
@onready var spawnTimer = $Timer

func _on_timer_timeout():
	var enemyInst = enemy_scene.instantiate()
	var enemyInst2 = enemy_scene.instantiate()
	add_child(enemyInst)
	var spawnLoc = options[randi() % options.size()]
	enemyInst.global_position = spawnLoc.global_position
	add_child(enemyInst2)
	spawnLoc = options[randi() % options.size()]
	enemyInst.global_position = spawnLoc.global_position
	
	if spawnRate > 3:
		spawnRate-=2
	else:
		spawnRate = 2
		
	spawnTimer.wait_time = spawnRate
