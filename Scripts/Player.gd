extends CharacterBody2D
const BulletScene = preload("res://Scenes/Bullet.tscn")
const BloodEmitterScene = preload("res://Scenes/BloodEmitter.tscn")
const GameOverScene = preload("res://Scenes/GameOver.tscn")

var hspeed = 0
var vspeed = 0

var frozen = false # Sets if the player can move or not
var inWater

var jump
var jump2
var grav

var jumpTime = 3

var djump = 1 # Allow the player to double jump as soon as he spawns
var maxHSpeed = 3 # Max horizontal speed
var maxVSpeed = 9 # Max vertical speed
var prevPos = Vector2()
var slipBlockTouching
var onVineR
var onVineL
var slip = 0.2
var canWalljump = true
var slide = 0

func _ready():
	if global.difficulty == "Medium":
		var bowInst = preload("res://Scenes/Bow.tscn").instantiate()
		get_parent().add_child(bowInst)
	$Sprite.flip_h = false # Sets the direction the player is facing (false is facing right, true is facing left)
	
	if get_tree().current_scene.name != "DifficultySelect":
		global.gameStarted = true
	
	if get_tree().current_scene.name != "End":
		if global.savePlayerPos:
			position = global.savePlayerPos
			
		if global.saveGrav:
			global.grav = global.saveGrav
		else:
			global.saveGrav = global.grav
	else:
		global.gameClear = true
	
	if global.saveScene:
		if get_tree().current_scene.name in str(global.saveScene):
			if global.saveRoom:
				for room in get_tree().current_scene.get_node("Rooms").get_children():
					if room.enabled && room != global.saveRoom:
						room.enabled = false
					if room == global.saveRoom:
						room.enabled = true

func _physics_process(delta):
	grav = 0.4 * global.grav # Sets the player's gravity
	jump = 8 * global.grav # Sets how fast the player jumps
	jump2 = 6.5 * global.grav # Sets how fast the player double jumps
	
	for area in $Area.get_overlapping_areas():
		# Check if on a slip block
		if area.name == "SlipBlocks":
			slipBlockTouching = true
		if !is_on_floor() && is_on_wall():
			if area.name == "WalljumpArea":
				if !canWalljump: return
				if $VineCheck.is_colliding():
					onVineR = true
				else:
					onVineL = true
		if area.name == "Water":
			inWater = area.type
	
	if get_tree().current_scene.has_node("TileLayer/SlipBlocks"):
		if $Area.get_overlapping_areas().find(get_tree().current_scene.get_node("TileLayer/SlipBlocks")) == -1:
			slipBlockTouching = false
	if get_tree().current_scene.has_node("TileLayer/WalljumpArea"):
		if $Area.get_overlapping_areas().find(get_tree().current_scene.get_node("TileLayer/WalljumpArea")) == -1:
			onVineR = false
			onVineL = false
	if get_tree().current_scene.has_node("Objects/SlideBlocks"):
		var test
		for sb in get_tree().current_scene.get_node("Objects/SlideBlocks").get_children():
			if $Area.get_overlapping_areas().find(sb.get_node("Top")) != -1:
				test = true
		if !test:
			slide = 0
	if get_tree().current_scene.has_node("TileLayer/Water"):
		var test
		for w in get_tree().current_scene.get_node("TileLayer/Water").get_children():
			if $Area.get_overlapping_areas().find(w) != -1:
				test = true
		if !test:
			inWater = -1
	
	# Flips the player depending on gravity direction
	if global.grav == 1:
		scale.y = 1
	else:
		scale.y = -1
	
	var L = Input.is_action_pressed("leftButton")
	var R = Input.is_action_pressed("rightButton")
	
	var h = 0 # Keeps track if the player is moving left/right
	
	if !frozen: # Don't move if frozen
		if R:
			h = 1
		elif L:
			h = -1
	
	if h != 0: # Player is moving
		if !onVineL && !onVineR: # Make sure we're not currently on a vine
			$Sprite.flip_h = bool(clamp(h, -1, 0)) # Set the direction the player is facing
			$CollisionShape2D.scale.x = h
		
		if h == -1 && !onVineR || h == 1 && !onVineL: # Make sure we're not moving off a vine (that's handled later)
			if !slipBlockTouching: # Not touching a slip block, move immediately at full speed
				hspeed = maxHSpeed * h
			else: # Touching a slip block, use acceleration
				hspeed += slip * h
				
				if abs(hspeed) > maxHSpeed:
					hspeed = maxHSpeed * h
		
		$AnimationPlayer.play("Run")
	else: # Player is not moving
		
		if !slipBlockTouching: # Not touching a slip block, stop immediately
			hspeed = 0
		else: # Touching a slip block, slow down
			if hspeed > 0:
				hspeed -= slip
				
				if hspeed <= 0:
					hspeed = 0
			
			elif hspeed < 0:
				hspeed += slip
				
				if hspeed >= 0:
					hspeed = 0
		
		$AnimationPlayer.play("Idle")
	
	# Play jump and fall animations
	if !is_on_floor():
		if vspeed < 0:
			$AnimationPlayer.play("Jump")
		else:
			$AnimationPlayer.play("Fall")
	
	if abs(vspeed) > maxVSpeed: # Check if moving faster vertically than max speed
		vspeed = sign(vspeed) * maxVSpeed
	
	if !is_on_floor():
		vspeed += grav # Apply gravity to current vspeed to check where the player will be
	
	# Check for horizontal collisions
	if is_on_wall():
		hspeed = 0
	
	if is_on_floor():
		if (vspeed <= 0 and global.grav == -1) or (vspeed >= 0 and global.grav == 1):
			djump = 1
		
		# Reset *slight* momentum only when not actively jumping
		if vspeed > 0:
			vspeed = 0
			pass
	if is_on_ceiling():
		vspeed = grav
	#print(vspeed)
	# Check buttons for player actions
	if !frozen: # Check if frozen before doing anything
		if Input.is_action_just_pressed("jumpButton"):
			jumpFunc()
			jumpTime = 3
		if Input.is_action_just_released("jumpButton"):
			vJump()
		if Input.is_action_just_pressed("shootButton"):
			shoot()
		if Input.is_action_just_pressed("scuicideButton"):
			kill()
	
	jumpTime -= 1
	
	 #Handle walljumps
	if onVineR or onVineL:
		if onVineR:
			$Sprite.flip_h = true
			$CollisionShape2D.scale.x = h
			$Sprite.offset = Vector2(-9, 5)
		else:
			$Sprite.flip_h = false
			$CollisionShape2D.scale.x = h
			$Sprite.offset = Vector2(9, 5)
		
		vspeed = 2 * global.grav
		$AnimationPlayer.play("Slide")
		
		# Check if moving away from the vine
		if (onVineL && !Input.is_action_pressed("leftButton") && Input.is_action_pressed("rightButton")) or (onVineR && !Input.is_action_pressed("rightButton") && Input.is_action_pressed("leftButton")):
			if Input.is_action_pressed("jumpButton"): # Jumping off vine
				djump = 0
				if onVineR:
					hspeed = -15
				else:
					hspeed = 15
				
				vspeed = -9 * global.grav
				$SFXplayer.stream = preload("res://Audio/Walljump.wav")
				$SFXplayer.play()
				$AnimationPlayer.play("Jump")
				
			else:
				if onVineR:
					hspeed = -3
				else:
					hspeed = 3
				
				$AnimationPlayer.play("Fall")
			
			canWalljump = false
			var timer = Timer.new()
			add_child(timer)
			timer.one_shot = true
			timer.timeout.connect(_on_Timer_timeout)
			timer.start(0.2)
	else:
		$Sprite.offset = Vector2(0, 0)
	
	prevPos = position
	
	# Add hspeed and vspeed to position
	move_and_slide()
	velocity = Vector2(hspeed + slide, vspeed) / delta 
	up_direction = Vector2(0, global.grav * -1)
	position = Vector2(round(position.x), position.y)
	# Detect player on edges of screen
	if get_parent().has_node("Rooms"):
		for cam in get_parent().get_node("Rooms").get_children():
			if cam.enabled:
				var check = camCheck(cam)
				if check:
					if check.axis == "x":
						for camm in get_parent().get_node("Rooms").get_children():
							if camm.position == Vector2(cam.position.x + 800 * check.dir, cam.position.y):
								camm.enabled = true
								cam.enabled = false
						if cam.enabled:
							kill()
					elif check.axis == "y":
						for camm in get_parent().get_node("Rooms").get_children():
							if camm.position == Vector2(cam.position.x, cam.position.y + 608 * check.dir):
								camm.enabled = true
								cam.enabled = false
						if cam.enabled:
							kill()

# Makes the player jump
func jumpFunc():
	if is_on_floor() or inWater == 0:
		$SFXplayer.stream = preload("res://Audio/Jump.wav")
		$SFXplayer.play()
		vspeed = -jump
		djump = 1
	elif djump == 1 or inWater == 1 or inWater == 2 or global.infJump:
		if onVineL or onVineR:
			return
		$SFXplayer.stream = preload("res://Audio/Jump2.wav")
		$SFXplayer.play()
		vspeed = -jump2
		
		if inWater != 2:
			djump = 0
		else:
			djump = 1

# Makes the player lose upward vertical momentum
func vJump():
	if vspeed * global.grav < 0:
		vspeed *= 0.45

# Makes the player shoot a bullet
func shoot():
	if get_parent().has_node("Bullets"):
		if get_parent().get_node("Bullets").get_child_count() < 4:
			$SFXplayer.stream = preload("res://Audio/Shoot.wav")
			$SFXplayer.play()
			var bullet = BulletScene.instantiate()
			get_parent().get_node("Bullets").add_child(bullet)
			bullet.position = Vector2(position.x, position.y + (global.grav * 2))

# Kills the player
func kill():
	global.deathMusic.volume_db = 0
	global.deathMusic.play()
	global.fadeMusic()
	if !get_parent().has_node("DeathPos"):
		var deathPos = Marker2D.new()
		deathPos.name = "DeathPos"
		get_parent().add_child(deathPos)
		deathPos.position = position
		var deathsfx = AudioStreamPlayer.new()
		deathPos.add_child(deathsfx)
		deathsfx.stream = preload("res://Audio/Death.wav")
		deathsfx.play()
		
		var bloodEmitter = BloodEmitterScene.instantiate()
		get_parent().add_child(bloodEmitter)
		
		var gameOver = GameOverScene.instantiate()
		get_parent().add_child(gameOver)
		
		queue_free()

func camCheck(cam):
	if position.x > cam.position.x + 400:
		return {"axis":"x", "dir":1}
	elif position.x < cam.position.x - 400:
		return {"axis":"x", "dir":-1}
	elif position.y > cam.position.y + 304:
		return {"axis":"y", "dir":1}
	elif position.y < cam.position.y - 304:
		return {"axis":"y", "dir":-1}
	return false

func platformCollision(other):
	if global.grav == 1: # Check if on top of the platform (when right-side up)
		if position.y - vspeed / 2 + 16 <= other.position.y:
			if vspeed <= 0 && jumpTime <= 0:
				position.y = other.position.y - 25 # Snap to the platform
				vspeed = 0
		
		djump = 1
	else: # Check if on top of the platform (when flipped)
		if position.y - vspeed / 2 - 16 >= other.position.y:
			if vspeed >= 0 && jumpTime <= 0:
				position.y = other.position.y + 25 # Snap to the platform
				vspeed = 0
		
		djump = 1

func _on_Timer_timeout():
	canWalljump = true
