extends Sprite2D

func _process(_delta):
	if get_tree().get_nodes_in_group("Kid").size() > 0:
		var player = get_tree().get_nodes_in_group("Kid")[0]
		
		flip_h = player.get_node("Sprite").flip_h
		scale.y = player.scale.y
		
		position = player.prevPos
	else:
		queue_free()
