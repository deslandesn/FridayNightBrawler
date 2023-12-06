extends CharacterBody3D

const MOUSE_SENSITIVITY = 0.1
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var headPivot = $HeadPivot
@onready var animator = $HeadPivot/Fists/AnimationTree
@onready var stateMachine = animator["parameters/playback"]

@onready var punchRayCast = $HeadPivot/PunchCast
@onready var grabRayCast = $HeadPivot/GrabCast
@onready var handItemDisplay = $HeadPivot/Fists

@onready var uiManager = $UI

var input_mouse: Vector2

var startingHealth:float = 100
@onready var currentHealth = startingHealth

var punchL:bool
var hasDrink:bool = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	if hasDrink:
		isBeerDone()
		return false
		
	if Input.is_action_just_pressed("Punch"):
		if(punchL):
			stateMachine.start("PunchL")
			punchL = false
			punchCast()
		else:
			stateMachine.start("PunchR")
			punchL = true	
			punchCast()
		
	if grabRayCast.is_colliding():
		if hasDrink == false:
			if Input.is_action_pressed("Grab"):
				var drink = grabRayCast.get_collider()
				drink.queue_free()
				hasDrink = true
				handItemDisplay.showBeer()
				stateMachine.start("Grab")
				
				
	
	
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("WalkLeft", "WalkRight", "WalkForward", "WalkBack")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	move_and_slide()
	
	
	
func _input(event):
	if event is InputEventMouseMotion:
		headPivot.rotate_x(deg_to_rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		self.rotate_y(deg_to_rad(event.relative.x * MOUSE_SENSITIVITY * -1))
		pass

func punchCast():
	if punchRayCast.is_colliding():
		var enemy = punchRayCast.get_collider()
		if enemy.has_method("hit"):
				enemy.hit()
func hit():
	currentHealth -= 20
	uiManager.setHealth(currentHealth)
	uiManager.flashDamage()
	if currentHealth<=0:
		die()
		
func isBeerDone():
	var current_node = stateMachine.get_current_node()
	if current_node == "IDLE":
		handItemDisplay.hideBeer()
		hasDrink = false
		currentHealth = startingHealth
		uiManager.setHealth(currentHealth)
func die():
	get_tree().quit()
