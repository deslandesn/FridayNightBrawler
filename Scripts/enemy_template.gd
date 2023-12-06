extends CharacterBody3D

@onready var EnemyAnimator = $EnemyModel
@onready var BodyCollider = $CollisionShape3D

var health = 10
var dead = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#attack vars
@onready var punchRay = $RayCast3D
var rng = RandomNumberGenerator.new()
var punching = false
@onready var punchCooldown = $PunchCooldown

#navmesh stuff
@onready var moveTarget:Node3D = get_tree().get_root().find_child("Player",true)
var movement_speed: float = 2.0
var movement_target_position: Vector3 = Vector3(-3.0,0.0,2.0)
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

func _ready():
	moveTarget = get_tree().get_root().find_child("Player",true,false)
	if moveTarget == null:
		return
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 1.5
	navigation_agent.target_desired_distance = 1.5

	# Make sure to not await during _ready.
	call_deferred("actor_setup")
	

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target()
	EnemyAnimator.setMoving(true)

func set_movement_target():
	navigation_agent.set_target_position(moveTarget.position)

func _physics_process(delta):
	if dead:
		return false
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	if moveTarget == null:
		return
		
	set_movement_target()
	if navigation_agent.is_navigation_finished():
		startPunchTimer()
		look_at(moveTarget.global_position)
		EnemyAnimator.setMoving(false)
		var distance = global_position.distance_squared_to(moveTarget.global_position)
		if(distance > 3.0):
			EnemyAnimator.setMoving(true)
			set_movement_target()
		else:
			return
		
	EnemyAnimator.setMoving(true)
	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	look_at(next_path_position)
	velocity = current_agent_position.direction_to(next_path_position) * movement_speed
	move_and_slide()

func hit():
	if dead:
		return false
	health -= 1
	if health < 1:
		die();
		return false
	if EnemyAnimator.has_method("hitAnimation"):
		EnemyAnimator.hitAnimation()

func die():
	dead = true
	BodyCollider.queue_free()
	if EnemyAnimator.has_method("dieAnimation"):
		EnemyAnimator.dieAnimation()

func startPunchTimer():
	if(punchCooldown.is_stopped()):
		punchCooldown.start()

func punch():
	if dead:
		return
	punching = true
	EnemyAnimator.punchAnimation()

func _on_enemy_model_punch_triggered():
	print("punch triggered")
	punching = false
	if punchRay.is_colliding():
		print("punch hit")
		var target = punchRay.get_collider()
		if target.has_method("hit"):
				target.hit() # Replace with function body.


func _on_punch_cooldown_timeout():
	punch()
