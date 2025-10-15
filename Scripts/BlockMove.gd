extends StaticBody2D

@export var type: String = "Fall"
var moving
var player
var startPos

func _ready():
	startPos = global_position

func _process(_delta):
	if moving:
		if type == "Fall":
			position.y += 2
			if player:
				if position.distance_to(player.position) < 36:
						player.position.y += 2
		else:
			position.y -= 2
			if player:
				if position.distance_to(player.position) < 36:
					player.position.y -= 2
	
	for body in $Area2D.get_overlapping_bodies():
		if body.is_in_group("Kid"):
			moving = true
			player = body

func restart():
	global_position = startPos
	moving = false
