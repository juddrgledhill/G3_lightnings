#based on the tutorial here:
#https://gamedevelopment.tutsplus.com/tutorials/how-to-generate-shockingly-good-2d-lightning-effects--gamedev-2681
#all credit to Michael Hoffman

extends Node2D

var start
var end
var max_thickness
var min_thickness
var color
const image_thickness = 8 #thickness of the line in the image

var current_alpha = 1
var start_alpha = 1
var alpha_step = 0.08
var decay_time = 0.5
var use_timer = false

var available_lines = 0
var drawing = false

#if the fade time is set, use a timer
var timer

onready var bolt = self #adapted from the simpler code base
onready var bolt_template = $bolt

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

func make_bolt(start_pos, end_pos, col = Color(1, 1, 1, 1), min_thick = 16, max_thick = 160):
	if not drawing:
		start = start_pos
		end = end_pos
		min_thickness = min_thick
		max_thickness = max_thick
		color = col
		generate_bolt_segments()
	else:
		print("bolt still onscreen")

func fire_bolt():
	if not drawing:
		set_process(true)
		drawing = true
		bolt.show() #bolt comes on screen
		if timer != null: timer.start()
	else:
		print("bolt still onscreen")


func reset_bolt():
	drawing = false
	current_alpha = start_alpha
	bolt.hide()
	bolt.modulate.a = 1
	for bolt in get_tree().get_nodes_in_group("bolts"):
		bolt.hide()
	set_process(false)


func generate_bolt_segments():
	var bolt_lines = []
	var tangent = end - start
	var normal = Vector2(tangent.y, -tangent.x).normalized()
	var length = tangent.length()
	
	randomize()
	
	var positions = []
	positions.append(0)
	var spots = floor(length/8)
	
	make_line_pool(spots + 2) #make sure we have enough line2d nodes to do the job
	
	for idx in range(spots):
		positions.append(rand_range(0, 1))
	positions.sort()
	
	var sway = float(80.0)
	var jaggedness = 1.0/sway
	
	var prev_point = start
	var prev_displacement = float(0.0)
	var point
#	var seg_color
	
	var middle_scale
	var line_tangent
	var thickness_scale
	
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
		
		thickness_scale = rand_range(min_thickness, max_thickness)/image_thickness
#		line_tangent = point - prev_point
#		middle_scale = Vector2(line_tangent, thickness_scale)
		
		place_line(i, prev_point, point, thickness_scale)
		
		prev_point = point
		prev_displacement = displacement
	
	place_line(positions.size() + 1, prev_point, end, thickness_scale)


	
#TODO figure out how to integrate the thickness code in here...
#public void Draw(SpriteBatch spriteBatch, Color color)
#{
#    Vector2 tangent = B - A;
#    float rotation = (float)Math.Atan2(tangent.Y, tangent.X);
#
#    const float ImageThickness = 8;
#    float thicknessScale = Thickness / ImageThickness;
#
#    Vector2 capOrigin = new Vector2(Art.HalfCircle.Width, Art.HalfCircle.Height / 2f);
#    Vector2 middleOrigin = new Vector2(0, Art.LightningSegment.Height / 2f);
#    Vector2 middleScale = new Vector2(tangent.Length(), thicknessScale);
#
#    spriteBatch.Draw(Art.LightningSegment, A, null, color, rotation, middleOrigin, middleScale, SpriteEffects.None, 0f);
#    spriteBatch.Draw(Art.HalfCircle, A, null, color, rotation, capOrigin, thicknessScale, SpriteEffects.None, 0f);
#    spriteBatch.Draw(Art.HalfCircle, B, null, color, rotation + MathHelper.Pi, capOrigin, thicknessScale, SpriteEffects.None, 0f);
#}





func place_line(index, start, end, thickness):
	var name = str("bolt_", index)
	var bolt = get_node(name)
	bolt.points = []
	bolt.add_point(start)
	bolt.add_point(end)
	bolt.width = thickness
	bolt.show()


func make_line_pool(num_lines):
	if num_lines > available_lines:
#		print("making lines. Have: ", available_lines, " Need: ", num_lines)
		for i in range(available_lines + 1, num_lines + 1):
			var new_bolt = bolt_template.duplicate()
			new_bolt.name = str("bolt_", i)
			new_bolt.add_to_group("bolts")
			new_bolt.hide()
			self.add_child(new_bolt)
		available_lines = num_lines
		


func _ready():
	set_process(true)


func _process(delta):
	#fade the bolt out over time
	if drawing:
		if use_timer:
			current_alpha = timer.get_time_left()/decay_time
		else:
			current_alpha -= alpha_step
		
		if current_alpha > 0:
			bolt.modulate.a = current_alpha
		else:
			reset_bolt()