@tool
extends Area2D

var canSave = true # Sets whether the player can currently use this save
@export var grav: int = 1 # Sets which way the gravity has to be for this save to work
var time = 0
var waiting

func _ready():
	if grav == -1:
		rotation_degrees = 180

func _process(_delta):
	if Engine.is_editor_hint():
		if grav == -1:
			rotation_degrees = 180
		else:
			rotation_degrees = 0
	else:
		if waiting:
			time += 1
		if time == 30:
			canSave = true
		if time == 58:
			$Sprite.play("inactive")
			waiting = false
		
		for area in get_overlapping_areas():
			if "Bullets" in area.get_parent().name:
				save()
		for body in get_overlapping_bodies():
			if body.is_in_group("Kid") and Input.is_action_just_pressed("shootButton"):
				save()

func save():
	if canSave && get_tree().get_nodes_in_group("Kid").size() > 0 && global.grav == grav:
		canSave = false # Set it so that the player can't save again immediately
		waiting = true
		time = 0
		$Sprite.play("active") # Set the sprite to green
		global.save() # Save the game
