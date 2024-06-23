extends JointBlend

class_name JointBlendLeg


@export var height_scanner: IkScanner
@export var snag_scanner: IkScanner
@export var min_height_for_correction: float = 30
@export_range(-2, 2) var correction_coef: float = 1
@export_range(1, 10) var max_correction: float = 2
@export var is_leading: bool = true

@onready var _update_period: float = height_scanner.update_period / 2
var _accum: float = 0


func _ready():
	self.blend_mode = BlendMode.MUL

func _physics_process(delta):
	_accum += delta
	if _accum >= _update_period:
		_update_rotation(_accum)
		_accum = 0

func _update_rotation(delta: float):
	var result: IkScanner.ScanResult 
	if is_leading:
		result = height_scanner.last_scan
	else:
		result = snag_scanner.last_scan
	if result:
		if result.distance > min_height_for_correction:
			var additional_height = result.distance - min_height_for_correction
			var additional_height_coef = additional_height / result.distance
			var modificator: float = 1 + additional_height_coef * correction_coef
			modificator = clampf(modificator, -max_correction, max_correction)
			set_joint_modification(modificator, delta)
		else:
			set_joint_modification(1, delta)
	else:
		set_joint_modification(1, delta)
