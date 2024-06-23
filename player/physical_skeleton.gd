extends Node2D

class_name PhysicalSkeleton


@export var max_velocity: float = 100
@export var move_k: float = 0
var move_force: float = 0

@onready var _hip: PhysicalBoneCustom = $hip
@onready var _leg_l: PhysicalBoneCustom = $leg_l
@onready var _shin_l: PhysicalBoneCustom = $leg_l/shin_l
@onready var _foot_l: PhysicalBoneCustom = $leg_l/shin_l/foot_l
@onready var _leg_r: PhysicalBoneCustom = $leg_r
@onready var _shin_r: PhysicalBoneCustom = $leg_r/shin_r
@onready var _foot_r: PhysicalBoneCustom = $leg_r/shin_r/foot_r
@onready var _ground_adjust: GroundAdjust = $ground_adjust
@onready var _leg_l_blend: JointBlendLeg = $leg_l/JointBlendLeg
@onready var _shin_l_blend: JointBlendLeg = $leg_l/shin_l/JointBlendLeg
@onready var _leg_r_blend: JointBlendLeg = $leg_r/JointBlendLeg
@onready var _shin_r_blend: JointBlendLeg = $leg_r/shin_r/JointBlendLeg
@onready var _height_scanner_l: IkScanner = $leg_l/shin_l/foot_l/height_scanner_l
@onready var _height_scanner_r: IkScanner = $leg_r/shin_r/foot_r/height_scanner_r
@onready var _obstacle_scanner: ObstacleScanner = $obstacle_scanner
var _is_flip: bool = false

func _ready():
	_setup_collisions_among_themselves(self.find_children("*", "PhysicalBoneCustom"))

func _physics_process(delta):
	var lin_v = _hip.linear_velocity.length()
	if lin_v > max_velocity:
		_hip.linear_velocity /= lin_v / max_velocity
	var move_dir: Vector2
	if _is_flip:
		move_dir = Vector2.LEFT.rotated(_foot_l.global_rotation)
	else:
		move_dir = Vector2.RIGHT.rotated(_foot_r.global_rotation)
	_hip.apply_central_force(move_dir * move_force * move_k)
	var hip_target_rot = (_foot_l.global_rotation + _foot_r.global_rotation) / 2
	_hip.global_rotation = lerp(_hip.global_rotation, hip_target_rot, delta) 

func set_lock_legs(is_lock: bool):
	_leg_l.lock_rotation = is_lock
	_shin_l.lock_rotation = is_lock
	_leg_r.lock_rotation = is_lock
	_shin_r.lock_rotation = is_lock

func set_ragdoll(is_ragdoll: bool):
	pass

func set_ground_adjust(is_enable: bool):
	_ground_adjust.is_enable = is_enable

func flip_right():
	_is_flip = false
	_leg_l_blend.is_leading = false
	_shin_l_blend.is_leading = false
	_leg_r_blend.is_leading = true
	_shin_r_blend.is_leading = true
	for child in self.get_children():
		if child is PhysicalBoneCustom:
			child.flip_right()

func flip_left():
	_is_flip = true
	_leg_l_blend.is_leading = true
	_shin_l_blend.is_leading = true
	_leg_r_blend.is_leading = false
	_shin_r_blend.is_leading = false
	for child in self.get_children():
		if child is PhysicalBoneCustom:
			child.flip_left()

func get_hip_pos() -> Vector2:
	return _hip.global_position

func is_left_free() -> bool:
	return _obstacle_scanner.is_left_free()

func is_right_free() -> bool:
	return _obstacle_scanner.is_right_free()

func is_current_side_free():
	if _is_flip:
		return _obstacle_scanner.is_left_free()
	else:
		return _obstacle_scanner.is_right_free()

func _setup_collisions_among_themselves(elements: Array[Node]):
	for i: RigidBody2D in elements:
		for j: RigidBody2D in elements:
			if i != j:
				i.add_collision_exception_with(j)
