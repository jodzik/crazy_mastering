extends Node

class_name JointBlend

enum BlendMode {
	ADD,
	MUL,
}


@export_range(-180.0, 180.0, 0.1, "radians_as_degrees") var target_rotation: float = 0.0:
	set(value):
		target_rotation = value
		set_joint_modification(current_modificator)

@export var joint_path: NodePath
@export_range(0, 20) var lerp_speed: float = 2
@export_range(0, 20) var lerp_speed_extra: float = 2

var blend_mode: BlendMode = BlendMode.ADD
var current_modificator: float = 0
var blend_mode_extra: BlendMode = BlendMode.ADD
var current_modificator_extra: float = 0

@onready var _parent = get_parent()
var _joint: PinJoint2DReinforced


func _ready():
	if blend_mode == BlendMode.MUL:
		current_modificator = 1
	if blend_mode_extra == BlendMode.MUL:
		current_modificator_extra = 1

func _update_joint(is_force: bool = false) -> PinJoint2DReinforced:
	if !is_instance_valid(_joint) or is_force:
		_joint = get_node(joint_path)
	return _joint

func set_joint_modification(modificator: float, delta: float = 0.01):
	if not is_node_ready():
		return
	
	var lerp_weight = clampf(delta * lerp_speed, 0, 1)
	modificator = lerpf(self.current_modificator, modificator, lerp_weight)
	self.current_modificator = modificator
	_update_modificators_weight()

func set_joint_modification_extra(modificator: float, delta: = 0.01):
	if not is_node_ready():
		return

	var lerp_weight = clampf(delta * lerp_speed_extra, 0, 1)
	modificator = lerpf(self.current_modificator_extra, modificator, lerp_weight)
	current_modificator_extra = modificator
	_update_modificators_weight()

func _update_modificators_weight():
	_update_joint()
	var new_rotation: float = 0
	if blend_mode == BlendMode.ADD:
		new_rotation = target_rotation + current_modificator
	elif blend_mode == BlendMode.MUL:
		new_rotation = target_rotation * current_modificator

	if blend_mode_extra == BlendMode.ADD:
		new_rotation += current_modificator_extra
	elif blend_mode == BlendMode.MUL:
		new_rotation += target_rotation * current_modificator_extra
	if _parent.name == "body":
		print("new_rotation=", new_rotation)
	_joint.target_rotation = new_rotation
