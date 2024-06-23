extends JointBlend

class_name JointBlendFoot


@export var ik_scanner: IkScanner

@onready var _update_period: float = ik_scanner.update_period + 0.01
@onready var _foot: PhysicalBoneCustom = get_parent()
var _accum: float = 0


func _physics_process(delta):
	_accum += delta
	if _accum >= _update_period:
		_update_rotation(_accum)
		_accum = 0

func _update_rotation(delta: float):
	var result = ik_scanner.last_scan
	var normal_angle: float = 0
	if result:
		normal_angle = -result.normal.angle_to(Vector2.UP)
	else:
		normal_angle = 0
	set_joint_modification(normal_angle, delta)
