extends Node3D

@onready var animator = $AnimationTree
var stateMachine

signal punchTriggered
# Called when the node enters the scene tree for the first time.
func _ready():
	stateMachine = animator["parameters/playback"]

func hitAnimation():
	stateMachine.start("Hit",true)
	
func dieAnimation():
	stateMachine.start("Dead",true)
	
func punchAnimation():
	stateMachine.start("Punch",true)

func setMoving(state:bool):
	if state == true:
		animator.set("parameters/conditions/Moving", true) 
		animator.set("parameters/conditions/NotMoving", false)
	else:
		animator.set("parameters/conditions/Moving", false) 
		animator.set("parameters/conditions/NotMoving", true)

func triggerPunch():
	punchTriggered.emit()
