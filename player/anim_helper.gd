extends Node2D

@onready var _text: RichTextLabel = get_node("./text")
var _selected_obj: RigidBody2D
var _selected_joint: JointBlend


func _ready():
	pass


func _process(delta):
	pass


func _format_label() -> String:
	return _selected_obj.name + "=%.0f" % rad_to_deg(_selected_joint.target_rotation)


func _handle_result(result: Array[Dictionary]):
	if result.is_empty():
		_text.text = "NULL"
		_text.push_color(Color.RED)
		_selected_obj = null
		_selected_joint = null
	else:
		for obj in result:
			var collider: Node2D = obj["collider"]
			if collider is RigidBody2D and collider != _selected_obj:
				print("click on: ", collider.name)
				#var joint: JointBlend = Find.child_of_type(collider, "JointBlend", 1)
				var joints: Array[Node] = collider.find_children("", "JointBlend", false)
				var joint: JointBlend = null
				if joints.size() > 0:
					joint = joints[0]
				if joint != null:
					_selected_obj = collider
					_selected_joint = joint
					_text.text = _format_label()
					_text.push_color(Color.GREEN)
					break


func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == 2 and event.is_pressed():
			self.global_position = get_global_mouse_position()
			var space = get_world_2d().direct_space_state
			var query = PhysicsPointQueryParameters2D.new()
			query.position = self.global_position
			var result = space.intersect_point(query)
			_handle_result(result)
	elif event is InputEventKey and event.is_pressed():
		if !_selected_joint:
			return
		var to_rotate: float = 0
		if event.as_text_keycode() == "Right":
			to_rotate += deg_to_rad(5)
		elif event.as_text_keycode() == "Left":
			to_rotate -= deg_to_rad(5)
		if to_rotate != 0:
			_selected_joint.target_rotation += to_rotate
			_text.text = _format_label()
