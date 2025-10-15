extends Area2D

@export var speed = Vector2()
@export var bounce = true
var prevPos
var wallCollide = true

func _process(delta):
	prevPos = position
	position += speed * delta
	
	for body in get_overlapping_bodies():
		if body.is_in_group("Kid"):
			body.kill()
		if body.name == "Tiles" && bounce && wallCollide:
			wallCollide = false
			position = prevPos
			speed = Vector2(-speed.x, -speed.y)
	
	if get_tree().current_scene.has_node("TileLayer/Tiles"):
		if get_overlapping_bodies().find(get_tree().current_scene.get_node("TileLayer/Tiles")) == -1:
			wallCollide = true
