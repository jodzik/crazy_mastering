extends Node

@export var start_with_pause: bool = false

var next_frame = false
var process_slowmo = false


func _ready():
	if start_with_pause:
		get_tree().paused = true
		print("process paused")


func _process(delta):
	if get_tree().paused == false and next_frame == true:
		get_tree().paused = true
	
	if get_tree().paused == false and process_slowmo == true:
		get_tree().paused = true
		await get_tree().create_timer(1)
		get_tree().paused = false
		
	if get_tree().paused == true and Input.is_action_just_pressed("mouse_scroll_up"):
		next_frame = true
		process_slowmo = false
		get_tree().paused = false
		print("next frame")
	
	if get_tree().paused == true and Input.is_action_just_pressed("mouse_right"):
		process_slowmo = true
		next_frame = false
		get_tree().paused = false
		print("process_slowmo")
		
	if Input.is_action_just_pressed("mouse_middle"):
		if get_tree().paused == false:
			get_tree().paused = true
			print("process paused")
		elif get_tree().paused == true:
			process_slowmo = false
			next_frame = false
			get_tree().paused = false
			print("process unpaused")

