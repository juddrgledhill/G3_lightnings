#based on the tutorial here:
#https://gamedevelopment.tutsplus.com/tutorials/how-to-generate-shockingly-good-2d-lightning-effects--gamedev-2681
#all credit to Michael Hoffman

extends Node2D

var start
var end
var max_thickness
var min_thickness
var color = Color()
var back_color = Color()

var current_alpha = 1
var start_alpha = 1
var alpha_step = 0.08
var decay_time = 0.5
var back_line_scale = 2
var use_timer = false

var bolt_segments = []
var drawing = false

#if the fade time is set, use a timer
var timer


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
	return drawing


func make_bolt(start_pos, end_pos, col = Color(1, 1, 1, 1), back_col = Color(0, 0, 1, 0.75), max_thick = 8, min_thick = 1):	
	start = start_pos
	end = end_pos
	max_thickness = max_thick
	min_thickness = min_thick
	color = col
	back_color = back_col
	
	bolt_segments.clear()
	bolt_segments = generate_bolt_segments()


func fire_bolt():
	drawing = true
	if timer != null: timer.start()
	update()


func generate_bolt_segments():
	var bolt_lines = []
	var tangent = end - start
	var normal = Vector2(tangent.y, -tangent.x).normalized()
	var length = tangent.length()
	
	randomize()
	
	var positions = []
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
		var segment = [prev_point, point, rand_range(min_thickness, max_thickness)]
		bolt_lines.append(segment)
		
		prev_point = point
		prev_displacement = displacement
		
	bolt_lines.append( [prev_point, end, rand_range(min_thickness, max_thickness)] )
	return bolt_lines


func _ready():
	set_process(true) #just let it call the update all the time
	
	
func _process(delta):
	update()


func _draw():
	if drawing:
		if use_timer:
			current_alpha = timer.get_time_left()/decay_time
		else:
			current_alpha -= alpha_step #TODO: base this on time, not a step, look at LERP?

		if current_alpha > 0:
			color.a = current_alpha
			back_color.a = current_alpha
			for seg in bolt_segments:
				draw_line(seg[0], seg[1], back_color, seg[2] * back_line_scale) #back line
				draw_line(seg[0], seg[1], back_color.blend(color), seg[2]) #top line
		else:
			drawing = false
			current_alpha = start_alpha