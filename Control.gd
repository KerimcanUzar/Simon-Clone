extends ColorRect

var start = false
var ontimer = Timer.new()
var offtimer = Timer.new()
var clicktimer = Timer.new()
var blockertimer = Timer.new()
var blink = 0
var rng = RandomNumberGenerator.new()
var blocks
var block = 0
var level = 1
var seq = []
var clicks = 0
var current

# Called when the node enters the scene tree for the first time.
func _ready():
	
	add_child(ontimer)
	ontimer.one_shot = true
	ontimer.wait_time = 0.3
	ontimer.connect("timeout", self, "_on_ontimer_timeout")
	
	add_child(offtimer)
	offtimer.one_shot = true
	offtimer.wait_time = 0.3
	offtimer.connect("timeout", self, "_on_offtimer_timeout")
	
	add_child(clicktimer)
	clicktimer.one_shot = true
	clicktimer.wait_time = 0.15
	clicktimer.connect("timeout", self, "_on_clicktimer_timeout")
	
	blocks = [$Boxes/C1, $Boxes/C2, $Boxes/C3, $Boxes/C4]


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Start_pressed():
	$Blocker.show()
	level_check()

# Keeps the loop going
func level_check():
	rng.randomize()
	block = rng.randi_range(0, 3)
	seq.append(blocks[block])
	if blink < level:
		current = seq[blink]
		ontimer.start()
	else:
		$Blocker.hide()


func _on_ontimer_timeout():
	blink += 1
	if clicks <= blink:
		current.modulate.a = 1
		offtimer.start()


func _on_offtimer_timeout():
	current.modulate.a = 0.75
	level_check()

# Plays click animation
func _on_clicktimer_timeout():
	$Boxes/C1.set_scale(Vector2(1, 1))
	$Boxes/C1.set_position(Vector2(0, 0))
	$Boxes/C2.set_scale(Vector2(1, 1))
	$Boxes/C2.set_position(Vector2(360, 0))
	$Boxes/C3.set_scale(Vector2(1, 1))
	$Boxes/C3.set_position(Vector2(0, 360))
	$Boxes/C4.set_scale(Vector2(1, 1))
	$Boxes/C4.set_position(Vector2(360, 360))


func inputs(event, grid, x, y):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_LEFT:
			grid.set_scale(Vector2(0.8, 0.8))
			grid.set_position(Vector2(x, y))
			clicktimer.start()
			if seq[clicks] != grid:
				$GameOver.show()
				$GameOver/Points.text = str(level - 1) + " POINTS"
			else:
				clicks += 1
				if clicks == level:
					level += 1
					clicks = 0
					blink = 0
					$Level.text = "LEVEL: " + str(level)
					$Blocker.show()
				level_check()


func _on_C1_gui_input(event):
	inputs(event, $Boxes/C1, 36, 36)


func _on_C2_gui_input(event):
	inputs(event, $Boxes/C2, 396, 36)


func _on_C3_gui_input(event):
	inputs(event, $Boxes/C3, 36, 396)


func _on_C4_gui_input(event):
	inputs(event, $Boxes/C4, 396, 396)


func _on_Retry_pressed():
	level = 1
	clicks = 0
	blink = 0
	seq.clear()
	$Level.text = "Level: " + str(level)
	$Blocker.show()
	$GameOver.hide()
