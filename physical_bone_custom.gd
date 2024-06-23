extends RigidBody2D

class_name PhysicalBoneCustom

enum FlipScaleType {
	NONE,
	X,
	Y,
}


@export var bone: Bone2D
@export var flip_to: Node2D = null
@export var flip_collision_scale: FlipScaleType = FlipScaleType.NONE

@onready var _base_self_rotation = self.global_rotation
@onready var _base_bone_rotation = bone.global_rotation
@onready var _collision: CollisionPolygon2D = Find.child_of_type(self, "CollisionPolygon2D")
@onready var _sprite: Sprite2D = Find.child_of_type(self, "Sprite2D")

var _flip_bone_rot: float = 0.0


func _ready():
	pass

func _process(delta):
	bone.global_position = global_position
	var self_rot = self.global_rotation - _base_self_rotation
	bone.global_rotation = _base_bone_rotation + self_rot + _flip_bone_rot

func update_joints():
	for child in self.get_children():
		if child is PinJoint2DReinforced:
			var new = PinJoint2DReinforced.from(child)
			child.replace_by(new)
			child.free()
			

func flip_right():
	if _sprite:
		_sprite.scale.x = 1
	if flip_collision_scale == FlipScaleType.X:
		_collision.scale.x = 1
	elif flip_collision_scale == FlipScaleType.Y:
		_collision.scale.y = 1
	_flip_bone_rot = 0

func flip_left():
	if _sprite:
		_sprite.scale.x = -1
	if flip_collision_scale == FlipScaleType.X:
		_collision.scale.x = -1
		_flip_bone_rot = PI - _base_bone_rotation * 2.0
	elif flip_collision_scale == FlipScaleType.Y:
		_collision.scale.y = -1

func get_joint() -> PinJoint2DReinforced:
	return Find.child_of_type(self, "PinJoint2D")

func get_base_rotation() -> float:
	return _base_self_rotation

func set_rest_rotation():
	self.global_rotation = _base_self_rotation
	var joint: PinJoint2DReinforced = get_joint()
	if joint:
		joint.target_rotation = 0
