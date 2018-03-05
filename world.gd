#harness for the lightning emitter node
extends Node2D

onready var lightning = get_node('lightning')
onready var line_lightning = get_node('sprightning')
onready var multi_line_lightning = get_node("sprightning_ml")


func _ready():
	set_process_unhandled_input(true)
	print(lightning)


func _unhandled_input(event):
	if ((event is InputEventMouseButton) and (event.button_index == BUTTON_LEFT) and (event.is_pressed())):
		randomize()
		var topx = floor(rand_range(0, get_viewport_rect().size.x))
		
		#default case
		#make_bolt(start_pos, end_pos, col = Color(1, 1, 1, 1), back_col = Color(0, 0, 1, 0.75), max_thick = 8, min_thick = 1):	
		lightning.make_bolt(Vector2(topx, 0), get_global_mouse_position()) #start, end
		lightning.set_fade_over_time(0.5) #default is to fade in steps, this overrides that
		
		topx = floor(rand_range(0, get_viewport_rect().size.x))
		line_lightning.make_bolt(Vector2(topx, 0), get_global_mouse_position()) #start, end
		line_lightning.set_fade_over_time(0.5) #default is to fade in steps, this overrides that
		
		topx = floor(rand_range(0, get_viewport_rect().size.x))
		multi_line_lightning.make_bolt(Vector2(topx, 0), get_global_mouse_position()) #start, end
		multi_line_lightning.set_fade_over_time(0.5) #default is to fade in steps, this overrides that
		
#		print("Drawn bolt, Fire!")
		lightning.fire_bolt() #put the bolt onscreen
		
#		print("Line bolt, Fire!")
		line_lightning.fire_bolt() #put the bolt onscreen
		
#		print("Multi Line bolt, Fire!")
		multi_line_lightning.fire_bolt() #put the bolt onscreen