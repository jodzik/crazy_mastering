extends Node

class_name AnimCtl

class DesiredState:
	var speed: float
	
	func _init(speed: float = 1):
		self.speed = speed
	
	static func from(state: DesiredState) -> DesiredState:
		var new = DesiredState.new()
		new.speed = state.speed
		return new


@export var anim_tree: AnimationTree

# {param_name: {requester: value}}
var _state: Dictionary
var _distributors: Array[AnimDistributor]


func _ready():
	_distributors.assign($"../distributors".find_children("*", "AnimDistributor"))

func set_anim(anim_name: String):
	print("current animation: ", anim_tree.get("parameters/transition/current_state"))
	if anim_tree.get("parameters/transition/current_state") != anim_name:
		anim_tree.set("parameters/transition/transition_request", anim_name)
		print("set anim: ", anim_name)

func set_speed(requester: Node, anim_name: String, speed: float):
	var param_name = anim_name + "/speed"
	if param_name in _state:
		var param = _state[param_name]
		param[requester] = speed
	else:
		_state[param_name] = {requester: speed}
	_update_param_as_min(param_name, "parameters/" + anim_name + "_speed/scale")

func set_flip(is_flip: bool):
	for distrib in _distributors:
		distrib.is_flip = is_flip

func _update_param_as_min(param_name: String, param_path: String):
	var param: Dictionary = _state[param_name]
	var min_value: float = param.values()[0]
	for value in param.values():
		if value < min_value:
			min_value = value
	anim_tree.set(param_path, min_value)
