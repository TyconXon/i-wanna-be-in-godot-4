@tool
extends StaticBody2D

@export var direction: String = "Left"
@export var speed = 2

func _ready():
	if !Engine.is_editor_hint():
		if direction == "Left":
			$SpriteL.visible = true
			speed = -speed
		else:
			$SpriteR.visible = true

func _process(_delta):
	for body in $Top.get_overlapping_bodies():
		if body.is_in_group("Kid"):
			body.slide = speed
	
	if Engine.is_editor_hint():
		if direction == "Left":
			$SpriteL.visible = true
			$SpriteR.visible = false
		else:
			$SpriteR.visible = true
			$SpriteL.visible = false
