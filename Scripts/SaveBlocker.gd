extends Area2D

var fade = 0.05
var nope = false

func _ready():
	modulate.a = 0

func _process(_delta):
	for area in get_overlapping_areas():
		if "Bullets" in area.get_parent().name:
			area.queue_free()
			modulate.a = 1
			nope = true
			var timer = Timer.new()
			add_child(timer)
			timer.one_shot = true
			timer.timeout.connect(_on_Timer_timeout)
			timer.start(0.3)
		
	if modulate.a > 0 && !nope:
		modulate.a -= fade

func _on_Timer_timeout():
	nope = false
