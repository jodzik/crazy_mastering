extends Node

func draw_skeleton(node: Node2D, draw_node: Node2D = null):
	if !draw_node:
		draw_node = node
	var offset = draw_node.global_position
	for bone in Find.nodes_of_type(node, "Bone2D"):
		_draw_bone(bone, offset, draw_node)

func draw_collisions(node: Node2D, draw_node: Node2D = null):
	if !draw_node:
		draw_node = node
	var offset = draw_node.global_position
	for polygon in Find.nodes_of_type(node, "CollisionPolygon2D"):
		_draw_collision_polygon(polygon, offset, draw_node)
	for shape in Find.nodes_of_type(node, "CollisionShape2D"):
		_draw_collision_shape(shape, offset, draw_node)

func draw_joints(node: Node2D, draw_node: Node2D = null):
	if !draw_node:
		draw_node = node
	var offset = draw_node.global_position
	for joint in node.find_children("*", "PinJoint2D"):
		_draw_joint(joint, offset, draw_node)

func _scaled_point(point: Vector2, scale: Vector2) -> Vector2:
	var new = Vector2(point)
	new.x *= scale.x
	new.y *= scale.y
	return new

func _draw_bone(bone: Bone2D, offset: Vector2, draw_node: Node2D):
	var from = bone.global_position - offset
	var is_drawn = false
	for child in bone.get_children():
		if child is Bone2D:
			var to = child.global_position - offset
			draw_node.draw_line(from, to, Color.GRAY, 5.0)
			is_drawn = true
	if not is_drawn:
		var to = from + Vector2.from_angle(bone.global_rotation) * bone.get_length()
		draw_node.draw_line(from, to, Color.GRAY, 5.0)

func _draw_collision_polygon(polygon: CollisionPolygon2D, global_offset: Vector2, draw_node: Node2D):
	var size = polygon.polygon.size()
	for i: int in range(0, size):
		var offset = polygon.global_position - global_offset
		var from: Vector2 = _scaled_point(polygon.polygon[i], polygon.global_scale)
		var to: Vector2
		if i == size - 1:
			to = polygon.polygon[0]
		else:
			to = polygon.polygon[i+1]
		to = _scaled_point(to, polygon.global_scale)
		from = from.rotated(polygon.global_rotation) + offset
		to = to.rotated(polygon.global_rotation) + offset
		draw_node.draw_line(from, to, Color.AQUA, 3)

func _draw_collision_shape(shape: CollisionShape2D, global_offset: Vector2, draw_node: Node2D):
	print("draw collision shape: ", shape.get_path())
	shape.shape.draw(draw_node.get_canvas_item(), Color.AQUA)

func _draw_joint(joint: PinJoint2D, offset: Vector2, draw_node: Node2D):
	const LINE_LEN: float = 40.0
	const WIDTH: float = 8.0
	draw_cross(joint.global_position - offset, LINE_LEN, WIDTH, Color.BLUE_VIOLET, draw_node)

func draw_cross(pos: Vector2, len: float, width: float, color: Color, draw_node: Node2D):
	var from = pos - Vector2(len / 2, 0)
	var to = pos + Vector2(len / 2, 0)
	draw_node.draw_line(from, to, color, width)
	from = pos - Vector2(0, len / 2)
	to = pos + Vector2(0, len / 2)
	draw_node.draw_line(from, to, color, width)
