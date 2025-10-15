extends Node
const SaveFolder = "user://"

var grav = 1
var deaths = 0
var timer = Timer.new()
var autosaveTimer = Timer.new()
var time = {"seconds":0, "minutes":0, "hours":0}
var infJump = true
var saveScene
var savePlayerPos
var saveGrav
var saveRoom
var gameClear
var saveNum = "0"
var gameStarted = false # Determines whether the game is currently in progress (enables saving, restarting, etc.)
var noPause = false # Sets whether or not to allow pausing (useful for bosses to prevent desync)
var loaded
var difficulty
var menuMusic = AudioStreamPlayer.new()
var deathMusic = AudioStreamPlayer.new()
var fadeTime = 80 # Sets how fast the music fades out (set to 80 for instant)
var deathTimer = Timer.new()
var masterVolume = 1

func _ready():
	var pauseMenu = preload("res://Scenes/PauseMenu.tscn").instantiate()
	add_child(pauseMenu)
	
	add_child(deathTimer)
	deathTimer.timeout.connect(_on_DeathTimer_timeout)
	menuMusic.stream = preload("res://Audio/musGuyRock.ogg")
	menuMusic.autoplay = true
	add_child(menuMusic)
	deathMusic.stream = preload("res://Audio/musOnDeath.ogg")
	add_child(deathMusic)
	
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(timer)
	timer.process_mode = Node.PROCESS_MODE_PAUSABLE
	timer.start(1)
	timer.timeout.connect(_on_Timer_timeout)
	
	add_child(autosaveTimer)
	autosaveTimer.timeout.connect(autosave)

func _process(_delta):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(masterVolume))
	
	if Input.is_action_just_pressed("quitButton"):
		if gameStarted: save(true)
		get_tree().quit()
	
	if Input.is_action_just_pressed("pauseButton") && !noPause && gameStarted:
		get_tree().paused = not get_tree().paused
	
	if Input.is_action_just_pressed("resetButton"):
		restart()
	
	if gameStarted:
		DisplayServer.window_set_title(ProjectSettings.get_setting("application/config/name") + " [Death: " + str(deaths) + "] [Time: " + str(time.hours) + ":" + str(time.minutes) + ":" + str(time.seconds) + "]")
		if autosaveTimer.is_stopped(): autosaveTimer.start(10)

func _on_Timer_timeout():
	if !gameClear:
		time.seconds += 1
		if time.seconds == 60:
			time.minutes += 1
			time.seconds = 0
			if time.minutes == 60:
				time.hours += 1
				time.minutes = 0

func save(autosave=false):
	
	# Save the player's current location variables
	if !autosave:
		saveScene = get_tree().current_scene.get_path()
		savePlayerPos = get_tree().get_first_node_in_group("Kid").position
		saveGrav = grav
		if get_tree().current_scene.has_node("Rooms"):
			for room in get_tree().current_scene.get_node("Rooms").get_children():
				if room.enabled:
					saveRoom = room
	
	# Create a dictionary for save data
	var saveDict = {
		"deaths" : deaths, 
		"time" : time, 
		"saveScene" : saveScene, 
		"saveRoom" : saveRoom, 
		"savePlayerPos" : savePlayerPos, 
		"saveGrav" : saveGrav, 
		"difficulty" : difficulty, 
		"gameClear" : gameClear
	}
	

	var err = FileAccess.open(SaveFolder + "save" + saveNum + ".dat", FileAccess.WRITE)
	if err != null:
		err.store_var(saveDict)
		err.close()
	return

func load(arg0):
	
	if FileAccess.file_exists(arg0):
		var err = FileAccess.open(arg0, FileAccess.READ)
		if err != null:
			var data = err.get_var()
			err.close()
			
			loaded = true
			if data.deaths: deaths = data.deaths
			if data.time: time = data.time
			if data.saveScene: saveScene = data.saveScene
			if data.saveRoom: saveRoom = instance_from_id(data.saveRoom.object_id)
			if data.savePlayerPos: savePlayerPos = data.savePlayerPos
			if data.saveGrav:
				grav = data.saveGrav
				saveGrav = data.saveGrav
			if data.difficulty: difficulty = data.difficulty
			if data.gameClear: gameClear = data.gameClear
	else:
		loaded = false
	return

func autosave():
	save(true)

func wipe():
	grav = 1
	deaths = 0
	timer = Timer.new()
	time = {"seconds":0, "minutes":0, "hours":0}
	infJump = false
	saveScene = null
	savePlayerPos = null
	saveGrav = null
	saveRoom = null
	gameClear = null
	gameStarted = false
	noPause = false
	loaded = null
	difficulty = null

func fadeMusic():
	deathTimer.start(0.1)

func _on_DeathTimer_timeout():
	if menuMusic.volume_db > -80:
		menuMusic.volume_db -= fadeTime
	else:
		deathTimer.stop()

func restart():
	deaths += 1
	menuMusic.volume_db = 0
	deathTimer.stop()
	deathMusic.volume_db = -80
	#
	#get_tree().call_group("Restart", "restart")
	#get_tree().call_group("Kid", "queue_free")
	#get_tree().call_group("Blood", "queue_free")
	get_tree().reload_current_scene()
