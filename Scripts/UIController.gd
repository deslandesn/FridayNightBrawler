extends Control

@onready var damageFlash = $DamageFlash
@onready var flashTimer = $FlashTimer
@onready var healthBar = $HealthBar
# Called when the node enters the scene tree for the first time.
func _ready():
	damageFlash.hide() 

func flashDamage():
	damageFlash.show()
	flashTimer.start()

func _on_flash_timer_timeout():
	damageFlash.hide()
	
func setHealth(newHealth:float):
	healthBar.value = newHealth
