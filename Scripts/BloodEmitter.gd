extends Node
const BloodScene = preload("res://Scenes/Blood.tscn")

var time = 0
var bloodAmount = round(randf_range(340, 620))

func _ready():
	randomize()
	if get_parent().has_node("Blood"):
		if get_parent().get_node("Blood").get_child_count() < bloodAmount:
			var blood = BloodScene.instantiate()
			get_parent().get_node("Blood").add_child(blood)
			blood.position = get_parent().get_node("DeathPos").position

func _process(_delta):
	time += 1
	if get_parent().get_node("Blood").get_child_count() < bloodAmount:
		for i in range(randi_range(5, 40)):
			var blood = BloodScene.instantiate()
			get_parent().get_node("Blood").add_child(blood)
			blood.position = get_parent().get_node("DeathPos").position
			

func restart():
	get_parent().get_node("DeathPos").queue_free()
	queue_free()
