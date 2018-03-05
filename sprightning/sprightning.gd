#based on the tutorial here:
#https://gamedevelopment.tutsplus.com/tutorials/how-to-generate-shockingly-good-2d-lightning-effects--gamedev-2681
#all credit to Michael Hoffman

extends Node2D

var start
var end
var max_thickness
var min_thickness
var color = Color(1,0,0,1)

var current_alpha = 1
var start_alpha = 1
var alpha_step = 0.08
var decay_time = 0.5
var back_line_scale = 2
var use_timer = false

var bolt_points = []
var drawing = false

#if the fade time is set, use a timer
var timer

onready var bolt = get_node("bolt")


func set_fade_over_time(bolt_fade_time):
	decay_time = bolt_fade_time
	if use_timer == false:
		use_timer = true
		timer = Timer.new()
		add_child(timer)
	timer.set_wait_time(decay_time)
	timer.set_one_shot(true)


func set_fade_steps(bolt_fade_step_value):
	alpha_step = clamp(bolt_fade_step_value, 0, 1)
	if timer != null: timer.queue_free()
	use_timer = false



func is_running():
	#this should do something based on the timer
	return drawing


func make_bolt(start_pos, end_pos, col = Color(1, 1, 1, 1)):	
	start = start_pos
	end = end_pos
	color = col
	
	#generate the bolt points and set them into the Line2D
	bolt.points = generate_bolt_points()


func fire_bolt():
	if not drawing:
		drawing = true
		set_process(true)
		bolt.show() #bolt comes on screen
		if timer != null: timer.start()
	else:
		print("bolt still onscreen")




func reset_bolt():
	drawing = false
	current_alpha = start_alpha
	bolt.hide()
	bolt.modulate.a = 1
	set_process(false)


func generate_bolt_points():
	var bolt_lines = []
	var tangent = end - start
	var normal = Vector2(tangent.y, -tangent.x).normalized()
	var length = tangent.length()
	
	randomize()
	
	var positions = []
	
	var line_points = []
	line_points.append(start)
	
	positions.append(0)
	var spots = length/8
	
	for idx in range(spots):
		positions.append(rand_range(0, 1))
	positions.sort()
	
	var sway = float(80.0)
	var jaggedness = 1.0/sway
	
	var prev_point = start
	var prev_displacement = float(0.0)
	var point
	var seg_color
	
	for i in range(1, positions.size()): #start at the second point, end at the penultimate spot		
		var the_pos = positions[i]
		var scale = (length * jaggedness) * (the_pos - positions[i - 1])
		var envelope
		if the_pos > 0.95 :
			envelope = float(20.0) * (1.0 - the_pos)
		else:
			envelope = 1.0

		var displacement = rand_range(-sway, sway)
		displacement -= (displacement - prev_displacement) * (1 - scale)
		displacement *= envelope
		point = start + the_pos * tangent + displacement * normal
		
		line_points.append(point)
		
		prev_point = point
		prev_displacement = displacement
		
		var sub_tangent = point - prev_point
		var sub_tangent_length = sub_tangent.length()
		var rotation = atan2(float(sub_tangent.y), sub_tangent.x);
	
	line_points.append(end)
	return line_points


func _process(delta):
	if drawing:
		if use_timer:
			current_alpha = timer.get_time_left()/decay_time
		else:
			current_alpha -= alpha_step #TODO: base this on time, not a step, look at LERP?
		
		if current_alpha > 0:
			bolt.modulate.a = current_alpha
		else:
			reset_bolt()
