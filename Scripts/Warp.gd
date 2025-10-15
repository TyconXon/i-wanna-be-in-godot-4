extends Area2D

@export var type: String = "Change Scene"
@export var warpPosition = Vector2()
@export var scene: PackedScene
@export var difficulty: String = "Medium"

func _process(_delta):
	for body in get_overlapping_bodies():
		if body.is_in_group("Kid"):
			
			if type == "Change Player Position" && warpPosition:
				
				var nearest = INF
				var nearestRoom
				var current
				if get_tree().current_scene.has_node("Rooms"):
					for room in get_tree().curent_scene.get_node("Rooms").get_children():
						if warpPosition.distance_to(room.position) < nearest:
							nearestRoom = room
							nearest = warpPosition.distance_to(room.position)
						if room.current:
							current = room
				
				current.current = false
				nearestRoom.current = true
				body.global_position = warpPosition
				body.vspeed = 0
				
			elif type == "Change Scene" && scene:
				get_tree().change_scene_to_packed(scene)
			
			elif type == "Start" && difficulty:
				if difficulty == "Load Game":
					global.load(global.SaveFolder + ("save") + global.saveNum + ".dat")
					if global.loaded:
						global.saveScene = str(global.saveScene).replace("/root", "res://")
						if !global.saveScene.ends_with(".tscn"):
							global.saveScene += ".tscn"
						get_tree().change_scene_to_file(global.saveScene)
				else:
					global.wipe()
					global.difficulty = difficulty
					get_tree().change_scene_to_file("res://Scenes/Sample01.tscn")
