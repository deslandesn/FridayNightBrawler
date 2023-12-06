extends Node3D

@onready var beerObject = $"Human FPS/Skeleton3D/BoneAttachment3D/Beer"
# Called when the node enters the scene tree for the first time.
func showBeer():
	beerObject.show()

func hideBeer():
	beerObject.hide()
