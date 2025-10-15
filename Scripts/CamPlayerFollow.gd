extends Camera2D

func _ready():
	await get_tree().create_timer(0.05).timeout
	if get_tree().get_nodes_in_group("Kid").size() > 0:
		position = get_tree().get_nodes_in_group("Kid")[0].position
		await get_tree().create_timer(0.05).timeout
		#position_smoothing_enabled = true
		limit_smoothed = true

func _process(_delta):
	if get_tree().get_nodes_in_group("Kid").size() > 0:
		position = get_tree().get_nodes_in_group("Kid")[0].position
