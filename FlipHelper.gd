extends Object

class_name FlipHelper

var flip_h = false
var flip_v = false
var node = null

func _init(node):
	self.node = node

func get_flip_h():
	return flip_h

func set_flip_h(enable):
	if enable == flip_h:
		return

	flip_h = enable
	h_flip_children()

func get_flip_v():
	return flip_v

func set_flip_v(enable):
	if enable == flip_v:
		return

	flip_v = enable
	v_flip_children()

func h_flip_children():
	for n in node.get_children():
		if not (n is Node2D) or n is Camera2D:
			continue
		n = n as Node2D
		if n is CollisionShape2D or n is CollisionObject2D:
			n.rotate(-2.0 * n.rotation)
		else:
			n.apply_scale(Vector2(-1, 1))
			
		var pos = n.position
		n.translate(Vector2(-2.0 * pos.x, 0.0))

func v_flip_children():
	for n in node.get_children():
		if not (n is Node2D):
			continue
		
		if n is CollisionShape2D or n is CollisionObject2D:
			n.rotate(-2.0 * n.get_rot())
		else:
			n.scale(Vector2(1, -1))
			
		var pos = n.get_pos()
		n.translate(Vector2(0.0, -2.0 * pos.y))
