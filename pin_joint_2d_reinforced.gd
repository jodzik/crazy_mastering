extends PinJoint2D

class_name PinJoint2DReinforced

const VELOCITY_K_BASE: float = 100.0

@export_category("Reinforce")
@export_range(-180.0, 180.0, 0.1, "radians_as_degrees") var target_rotation: float = 0.0
@export_range(0.0, 360.0, 0.1, "radians_as_degrees") var dead_zone: float = 0.0
@export_range(10.0, 2000.0) var velocity_max: float = 500.0
@export_range(1.0, 200.0) var velocity_k: float = 20.0
@export_range(0, 500.0) var velocity_b: float = 0.0
@export var debug: bool = false
@export var reverse_brake: bool = false
@export var nested: bool = false
@export var auto_motor: bool = true
@export_range(0, 10) var to_lock_lerp_speed: float = 1
@export_group("Only for reverse brake")
@export_range(1.0, 10.0) var brake_k: float = 2
@export_range(0.1, 10.0) var brake_velocity: float = 2
@export_range(1, 100, 1) var frame_per_cycle_for_brake: int = 3
@export_group("")

@onready var _node_a: RigidBody2D = get_node(node_a)
@onready var _node_b: RigidBody2D = get_node(node_b)
@onready var _parent: Node2D = get_parent()
@onready var base_rotation: float = get_rotation_ab()
@onready var base_a_rotation: float = _node_a.global_rotation
@onready var base_b_rotation: float = _node_b.global_rotation

var _prev_diff_angle: float = 0
var _cycle_frame_cnt: int = 0
var _to_lock_lerp_state: float = 1


static func from(joint: PinJoint2DReinforced) -> PinJoint2DReinforced:
	var new = PinJoint2DReinforced.new()
	new.name = joint.name
	new.softness = joint.softness
	new.bias = joint.bias
	new.target_rotation = joint.target_rotation
	new.dead_zone = joint.dead_zone
	new.velocity_max = joint.velocity_max
	new.velocity_k = joint.velocity_k
	new.velocity_b = joint.velocity_b
	new.debug = joint.debug
	new.reverse_brake = joint.reverse_brake
	new.nested = joint.nested
	new.brake_k = joint.brake_k
	new.brake_velocity = joint.brake_velocity
	new.frame_per_cycle_for_brake = joint.frame_per_cycle_for_brake
	new.transform = joint.transform
	new.rotation = joint.rotation
	new.position = joint.position
	new.node_a = joint.node_a
	new.node_b = joint.node_b
	new.motor_enabled = joint.motor_enabled
	return new

func get_rotation_ab():
	var angle: float = 0
	if nested:
		angle = -_node_b.global_rotation
	else:
		angle = _node_a.rotation - _node_b.rotation
	
	if angle < -PI:
		return -PI
	elif angle > PI:
		return PI
	return angle


func _ready():
	if nested:
		base_a_rotation = _node_a.rotation
		base_b_rotation = _node_b.rotation

func _process(delta):
	pass

func _physics_process(delta: float):
	if _node_b.lock_rotation:
		if self.auto_motor and self.motor_enabled:
			self.motor_enabled = false
		_apply_rotation(delta)
		if _to_lock_lerp_state < 1:
			_to_lock_lerp_state += delta * to_lock_lerp_speed
			if _to_lock_lerp_state > 1:
				_to_lock_lerp_state = 1
	else:
		if self.auto_motor and !self.motor_enabled:
			self.motor_enabled = true
		_to_lock_lerp_state = 0
		_apply_motor(delta)

# Положительная дельта - ушел по часовой
# Отрицательная дельта - ушел против часовой
func _angle_delta(new_diff_angle: float):
	return angle_difference(_prev_diff_angle, new_diff_angle)

func _is_mid_pos_pass(diff_angle):
	return sign(diff_angle) != sign(_prev_diff_angle)

# Положительная скорость - по часовой
# Отрицательная скорость - против часовой
func _is_brake_needed(rm_v: float, diff_angle: float):
	if _is_mid_pos_pass(diff_angle) and _cycle_frame_cnt <= frame_per_cycle_for_brake:
		return true

	# Если мы справа - то применяется отрицательная скорость
	if diff_angle > 0 and rm_v < -brake_velocity:
		return true
	# Если мы слева - то применяется положительная скорость
	elif diff_angle < 0 and rm_v > brake_velocity:
		return true

	return false

func _update_cycle_frame_cnt(diff_angle: float):
	if _is_mid_pos_pass(diff_angle):
		_cycle_frame_cnt = 0
	else:
		_cycle_frame_cnt += 1

# Положительная motor_velocity - против часовой стрелки
# Положительный diff_angle - справа 
func _apply_motor(delta: float):
	var current_to_base_angle: float = base_rotation - get_rotation_ab()
	var diff_angle: float = target_rotation - current_to_base_angle
	var sign: float = sign(diff_angle)
	var angle_delta: float = _angle_delta(diff_angle)
	var rm_v: float = angle_delta / delta
	
	_update_cycle_frame_cnt(diff_angle)

	#if abs(diff_angle) <= dead_zone:
		#_diff_remove_time = 0
		#return

	var velocity: float = VELOCITY_K_BASE * velocity_k * diff_angle + sign + velocity_b
	
	if reverse_brake and _is_brake_needed(rm_v, diff_angle):
		velocity /= brake_k
		if debug:
			print("brake")

	if velocity > velocity_max:
		velocity = velocity_max
	elif velocity < -velocity_max:
		velocity = -velocity_max

	if debug:
		print(_parent.name, ": target=", target_rotation, " diff=", diff_angle, " angle_d=", angle_delta, " rm_v=", rm_v, " velocity=", velocity)

	motor_target_velocity = velocity

	_prev_diff_angle = diff_angle

func _apply_rotation(delta: float):
	var new_rot = base_b_rotation + target_rotation
	if nested:
		_node_b.rotation = lerpf(_node_b.rotation, new_rot, _to_lock_lerp_state)
	else:
		_node_b.global_rotation = lerpf(_node_b.global_rotation, new_rot, _to_lock_lerp_state)

func update():
	self.global_position = self.global_position
