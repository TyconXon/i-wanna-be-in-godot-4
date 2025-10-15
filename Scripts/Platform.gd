extends Area2D

@export var sprite: String = "0"
@export var speed = Vector2()
@export var bounce = true

var wallCollide = true
var prevPos = Vector2()

func _ready():
	$PreviewSprite.visible = false
	get_node("Sprite" + sprite).visible = true

func _process(_delta):
	$StaticBody2D/CollisionShape2D.scale.y = global.grav
	
	position += speed
	
	for body in get_overlapping_bodies():
		if body.is_in_group("Kid"):
			body.platformCollision(self)
		if body.name == "Tiles" && bounce && wallCollide:
			wallCollide = false
			speed = Vector2(-speed.x, -speed.y)
	
	if get_tree().current_scene.has_node("TileLayer/Tiles"):
		if get_overlapping_bodies().find(get_tree().current_scene.get_node("TileLayer/Tiles")) == -1 && !wallCollide:
			wallCollide = true
	
	if get_tree().get_nodes_in_group("Kid").size() > 0:
		var player = get_tree().get_nodes_in_group("Kid")[0]
		if position.distance_to(player.position) < 36:
			player.position.y += speed.y
			if player.is_on_floor(): player.position.x += speed.x
		if speed && player.position.y + 16 < position.y:
			$StaticBody2D/CollisionShape2D.one_way_collision = false
		else:
			$StaticBody2D/CollisionShape2D.one_way_collision = true
