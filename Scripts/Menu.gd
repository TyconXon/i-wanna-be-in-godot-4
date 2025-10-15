extends Node2D

func _ready():
	
	global.load(global.SaveFolder + ("save0.dat"))
	if global.loaded:
		$save1/DeathsTimes.text = "Deaths: " + str(global.deaths) + "\nTime: " + str(global.time.hours) + ":" + str(global.time.minutes) + ":" + str(global.time.seconds)
		$save1/Difficulty.text = global.difficulty
		if global.gameClear: $save1/Clear.visible = true
	
	global.load(global.SaveFolder + ("save1.dat"))
	if global.loaded:
		$save2/DeathsTimes.text = "Deaths: " + str(global.deaths) + "\nTime: " + str(global.time.hours) + ":" + str(global.time.minutes) + ":" + str(global.time.seconds)
		$save2/Difficulty.text = global.difficulty
		if global.gameClear: $save2/Clear.visible = true
	
	global.load(global.SaveFolder + ("save2.dat"))
	if global.loaded:
		$save3/DeathsTimes.text = "Deaths: " + str(global.deaths) + "\nTime: " + str(global.time.hours) + ":" + str(global.time.minutes) + ":" + str(global.time.seconds)
		$save3/Difficulty.text = global.difficulty
		if global.gameClear: $save3/Clear.visible = true
	global.wipe()

func _process(_delta):
	if Input.is_action_just_pressed("rightButton"):
		if $Picker.position.x == 656:
			$Picker.position.x = 144
		else:
			$Picker.position.x += 256
	
	if Input.is_action_just_pressed("leftButton"):
		if $Picker.position.x == 144:
			$Picker.position.x = 656
		else:
			$Picker.position.x -= 256
	
	if Input.is_action_just_pressed("jumpButton"):
		if $Picker.position.x == 144:
			global.saveNum = "0"
		elif $Picker.position.x == 400:
			global.saveNum = "1"
		else:
			global.saveNum = "2"
		
		get_tree().change_scene_to_file("res://Scenes/DifficultySelect.tscn")
