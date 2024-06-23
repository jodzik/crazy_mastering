extends Node

class_name  GroundAdjust


const LEG_L_BASE: float = deg_to_rad(8)
const SHIN_L_BASE: float = deg_to_rad(-8)
const FOOT_L_BASE: float = deg_to_rad(0)
const LEG_R_BASE: float = deg_to_rad(-8)
const SHIN_R_BASE: float = deg_to_rad(8)
const FOOT_R_BASE: float = deg_to_rad(0)

@export_range(-1, 1) var correction_coef: float = 0.087
@export_range(0, 20) var lerp_speed: float = 10
@export var on_ground_inaccuracy: float = 20
var is_on_ground: bool = false
var is_enable: bool = true

@onready var _leg_l: JointBlend = $"../leg_l/JointBlendLeg"
@onready var _shin_l: JointBlend = $"../leg_l/shin_l/JointBlendLeg"
@onready var _foot_l: JointBlend = $"../leg_l/shin_l/foot_l/JointBlendFoot"
@onready var _leg_r: JointBlend = $"../leg_r/JointBlendLeg"
@onready var _shin_r: JointBlend = $"../leg_r/shin_r/JointBlendLeg"
@onready var _foot_r: JointBlend = $"../leg_r/shin_r/foot_r/JointBlendFoot"
@onready var _foot_l_scanner: IkScanner = $"../leg_l/shin_l/foot_l/IkScanner"
@onready var _foot_r_scanner: IkScanner = $"../leg_r/shin_r/foot_r/IkScanner"

@onready var _update_period: float = minf(_foot_l_scanner.update_period, _foot_r_scanner.update_period) / 2
var _accum: float = 0

func _ready():
	_leg_l.lerp_speed_extra = lerp_speed
	_shin_l.lerp_speed_extra = lerp_speed
	_foot_l.lerp_speed_extra = lerp_speed
	_leg_r.lerp_speed_extra = lerp_speed
	_shin_r.lerp_speed_extra = lerp_speed
	_foot_r.lerp_speed_extra = lerp_speed

func _process(delta):
	_accum += delta
	if _accum > _update_period:
		_update_rotation(_accum)
		_accum = 0

func _update_rotation(delta: float):
	var scan_l = _foot_l_scanner.last_scan
	var scan_r = _foot_r_scanner.last_scan
	if scan_l and scan_r and is_enable:
		if scan_l.distance <= on_ground_inaccuracy or scan_r.distance <= on_ground_inaccuracy:
			is_on_ground = true
		else:
			#print("scan_l.distance=", scan_l.distance, " scan_r.distance=", scan_r.distance)
			is_on_ground = false
			return
		var y_diff = scan_l.collision_point.y - scan_r.collision_point.y
		#print("y_diff=", y_diff, " point_l=", scan_l.collision_point, " point_r=", scan_r.collision_point)
		if y_diff < 0:
			# Bend left
			y_diff = -y_diff
			var leg_l = LEG_L_BASE * y_diff * correction_coef
			var shin_l = SHIN_L_BASE * y_diff * correction_coef
			var foot_l = FOOT_L_BASE * y_diff * correction_coef
			#print("node_l=", scan_l.node.name, " leg_l_base=", LEG_L_BASE, " leg_l=", rad_to_deg(leg_l), " shin_l=", rad_to_deg(shin_l), " foot_l=", rad_to_deg(foot_l))
			_leg_l.set_joint_modification_extra(leg_l)
			_shin_l.set_joint_modification_extra(shin_l)
			_foot_l.set_joint_modification_extra(foot_l)
			_leg_r.set_joint_modification_extra(0)
			_shin_r.set_joint_modification_extra(0)
			_foot_r.set_joint_modification_extra(0)
		else:
			var leg_r = LEG_R_BASE * y_diff * correction_coef
			var shin_r = SHIN_R_BASE * y_diff * correction_coef
			var foot_r = FOOT_R_BASE * y_diff * correction_coef
			#print("leg_r=", rad_to_deg(leg_r), " shin_r=", rad_to_deg(shin_r), " foot_r=", rad_to_deg(foot_r))
			_leg_l.set_joint_modification_extra(0)
			_shin_l.set_joint_modification_extra(0)
			_foot_l.set_joint_modification_extra(0)
			_leg_r.set_joint_modification_extra(leg_r)
			_shin_r.set_joint_modification_extra(shin_r)
			_foot_r.set_joint_modification_extra(foot_r)
	else:
		_leg_l.set_joint_modification_extra(0)
		_shin_l.set_joint_modification_extra(0)
		_foot_l.set_joint_modification_extra(0)
		_leg_r.set_joint_modification_extra(0)
		_shin_r.set_joint_modification_extra(0)
		_foot_r.set_joint_modification_extra(0)
