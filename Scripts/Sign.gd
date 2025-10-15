@tool
extends Area2D

var showText = false
@export var signText: String
@export var centered = false
@export var signNum = 0

func _process(_delta):
	if Engine.is_editor_hint():
		if global_position.distance_to(get_global_mouse_position()) < 24:
			showText = true
		else:
			showText = false
	else:
		var player = null
		
		for body in get_overlapping_bodies():
			if body.is_in_group("Kid"):
				player = body
		
		if get_overlapping_bodies().has(player):
			if Input.is_action_just_pressed("upButton"):
				showText = true
		else:
			showText = false
	
	if showText:
		if !get_parent().has_node("Dialog" + str(signNum)):
			var dialog = preload("res://Scenes/Dialog.tscn").instantiate()
			dialog.name = "Dialog" + str(signNum)
			get_parent().add_child(dialog)
			dialog.get_node("Node2D/Label").text = signText
			if centered:
				dialog.get_node("Node2D/Label").valign = Label.PRESET_CENTER
			dialog.get_node("Node2D").position = position
	else:
		if get_parent().has_node("Dialog" + str(signNum)):
			get_parent().get_node("Dialog" + str(signNum)).queue_free()
