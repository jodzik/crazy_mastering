extends Node


const DEEP_MAX: int = 256


func _add_nodes_of_type_recursive(node: Node2D, stack: Array[Node2D], type: String, cur_deep: int, max_deep: int):
	for child in node.get_children():
		if not child is Node2D:
			continue
		if child.is_class(type):
			stack.push_back(child)
		if cur_deep < max_deep:
			_add_nodes_of_type_recursive(child, stack, type, cur_deep + 1, max_deep)


func nodes_of_type(node: Node2D, type: String, deep: int = DEEP_MAX) -> Array[Node2D]:
	var stack: Array[Node2D] = []
	if node.is_class(type):
		stack.push_back(node)
	if deep > 0:
		_add_nodes_of_type_recursive(node, stack, type, 1, deep)
	return stack

func _child_of_type_recursive(node: Node, type: String, cur_deep: int, max_deep: int) -> Node:
	for child in node.get_children():
		if child.is_class(type):
			return child
		if cur_deep < max_deep:
			var result = _child_of_type_recursive(child, type, cur_deep + 1, max_deep)
			if result != null:
				return result
	return null
	

func child_of_type(node: Node, type: String, deep: int = DEEP_MAX) -> Node:
	return _child_of_type_recursive(node, type, 1, deep)
