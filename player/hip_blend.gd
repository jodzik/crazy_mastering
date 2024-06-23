extends Node

class_name HipBlend

@export var foot_l: PhysicalBoneCustom
@export var foot_r: PhysicalBoneCustom
@export_range(-180, 180, 0.1, "radians_as_degrees") var target_rotation: float = 0

@onready var _hip: PhysicalBoneCustom = get_parent()


func _physics_process(delta):
	var mean_foot_rot = (foot_l.global_rotation + foot_r.global_rotation) / 2
	_hip.global_rotation = lerpf(_hip.global_rotation, target_rotation + mean_foot_rot, delta)
