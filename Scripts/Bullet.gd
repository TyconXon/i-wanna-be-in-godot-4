extends Area2D

var bulletDir
var hspeed
var time = 0
func _ready():
	
	# Get the bullet's direction based off the direction the player is facing
	if get_tree().get_nodes_in_group("Kid").size() > 0:
		bulletDir = get_tree().get_nodes_in_group("Kid")[0].get_node("Sprite").flip_h
		if bulletDir == true: bulletDir = -1
		else: bulletDir = 1
		
		hspeed = bulletDir * 16

func _physics_process(_delta):
	position.x += hspeed 
	
	# Destroy the bullet in 40 frames
	time += 1
	if time == 40:
		queue_free()
	
	for body in get_overlapping_bodies():
		if body.name == "Tiles":
			queue_free()
