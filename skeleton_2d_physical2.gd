extends Skeleton2D

class_name Skeleton2DPhysical

enum FlipPos {
	RIGHT,
	LEFT,
}

const FLIP_RIGHT_SCALE = Vector2(1, 1)
const FLIP_LEFT_SCALE = Vector2(-1, 1)

class FlipBone:
	var _right_collision_area_x: Vector2
	var _right_joint_x: Vector2
	var _collision_area: Node2D
	var _joint: Node2D

	func _init(collision_area: CollisionPolygon2D, joint: PinJoint2D):
		_collision_area = collision_area
		_joint = joint
		_right_collision_area_x = collision_area.transform.x
		if joint:
			_right_joint_x = joint.transform.x
		#print("collision_area.transform.x=", collision_area.transform.x)

	func set_flip(flip_pos: FlipPos):
		if flip_pos == FlipPos.RIGHT:
			_collision_area.apply_scale(FLIP_RIGHT_SCALE)
			#_collision_area.transform.x = _right_collision_area_x
			#if _joint:
				#_joint.transform.x = _right_joint_x
		else:
			_collision_area.apply_scale(FLIP_LEFT_SCALE)
			#_collision_area.transform.x = -_right_collision_area_x
			#if _joint:
				#_joint.transform.x = -_right_joint_x

@export var right_leg: PhysicalBone2D
@export var left_leg: PhysicalBone2D

var _locked_bones: Array[PhysicalBone2D] = []
var _is_ragdoll: bool = false
var _flip_bones: Array[FlipBone] = []
var _is_debug_drawing: bool = false
var _flip_helper_hip: FlipHelper
var _flip_helper_body: FlipHelper
var _flip_helper_leg_l: FlipHelper
var _flip_helper_leg_r: FlipHelper

func _ready():
	_fill_locked_bones()
	_fill_flip_bones()
	_setup_collisions()
	_activate_modification()
	fix_skeleton()
	_flip_helper_hip = FlipHelper.new(get_node("hip"))
	_flip_helper_body = FlipHelper.new(get_node("hip/body"))
	_flip_helper_leg_l = FlipHelper.new(get_node("hip/leg_l"))
	_flip_helper_leg_r = FlipHelper.new(get_node("hip/leg_r"))

func _process(delta):
	pass
	var hip_bone = get_node("hip_bone") as Bone2D
	var hip = get_node("hip") as PhysicalBone2D
	#print("hip_bone.scale=", hip_bone.scale)
	#hip_bone.rotation_degrees = 180
	hip_bone.scale.x = -1
	#hip.scale.y = -1
	#self.scale.x = -1

func _draw_bone(bone: Bone2D, offset: Vector2):
	var from = bone.global_position - offset
	for child in bone.get_children():
		if child is Bone2D:
			var to = child.global_position - offset
			draw_line(from, to, Color.WHITE_SMOKE, 5.0)

func _draw_collision(polygon: CollisionPolygon2D, global_offset: Vector2):
	var size = polygon.polygon.size()
	for i: int in range(0, size):
		var offset = polygon.global_position - global_offset
		var from: Vector2 = polygon.polygon[i]
		var to: Vector2
		if i == size - 1:
			to = polygon.polygon[0]
		else:
			to = polygon.polygon[i+1]
		from = from.rotated(polygon.global_rotation) + offset
		to = to.rotated(polygon.global_rotation) + offset
		draw_line(from, to, Color.AQUA, 3)

func _draw():
	if not _is_debug_drawing:
		return
	var offset = get_parent().get_parent().position
	for bone in _get_nodes_of_type(self, "Bone2D"):
		_draw_bone(bone, offset)
	for polygon in _get_nodes_of_type(self, "CollisionPolygon2D"):
		print("draw collision..")
		_draw_collision(polygon, offset)

func draw_bones():
	_is_debug_drawing = true
	queue_redraw()

func _fill_locked_bones():
	for bone in _get_all_pysical_bones(self):
		if bone.lock_rotation:
			_locked_bones.push_back(bone)

func _add_nodes_of_type_recursive(node: Node2D, stack: Array[Node2D], type: String):
	for child in node.get_children():
		if child.is_class(type):
			stack.push_back(child)
		_add_nodes_of_type_recursive(child, stack, type)

func _get_nodes_of_type(node: Node2D, type: String) -> Array[Node2D]:
	var stack: Array[Node2D] = []
	if node.is_class(type):
		stack.push_back(node)
	_add_nodes_of_type_recursive(node, stack, type)
	return stack

func _get_all_pysical_bones(node: Node2D) -> Array[PhysicalBone2D]:
	var array: Array[PhysicalBone2D] = []
	array.assign(_get_nodes_of_type(node, "PhysicalBone2D"))
	return array

func _setup_collisions_among_themselves(elements: Array[PhysicalBone2D]):
	for i in elements:
		for j in elements:
			if i != j:
				i.add_collision_exception_with(j)

func _setup_collisions():
	var hip: PhysicalBone2D = get_node("hip")
	var body: PhysicalBone2D = get_node("hip/body")
	var jaw: PhysicalBone2D = get_node("hip/body/head/jaw")
	body.add_collision_exception_with(jaw)
	var right_bones: Array[PhysicalBone2D] = _get_all_pysical_bones(right_leg)
	#right_bones.push_back(get_node("./foot_r"))
	var left_bones: Array[PhysicalBone2D] = _get_all_pysical_bones(left_leg)
	#left_bones.push_back(get_node("./foot_l"))
	for right in right_bones:
		right.add_collision_exception_with(hip)
	for left in left_bones:
		left.add_collision_exception_with(hip)
	_setup_collisions_among_themselves(right_bones)
	_setup_collisions_among_themselves(left_bones)
	for right in right_bones:
		for left in left_bones:
			right.add_collision_exception_with(left)

func _activate_modification():
	var modification_stack: SkeletonModificationStack2D = self.get_modification_stack()
	# Better to enable it at runtime as it makes it harder to interact with in the editor when on
	modification_stack.enabled = true
	
	for i: int in range(0, modification_stack.modification_count):
		var modification: SkeletonModification2D = modification_stack.get_modification(i)
		if modification is SkeletonModification2DPhysicalBones:
			modification.enabled = true

func _fix_bone(bone: PhysicalBone2D):
	# this will undo the cpp constructor
	bone.follow_bone_when_simulating = false
	bone.simulate_physics = true
	bone.freeze = true
	bone.freeze = false
	print("fix: ", bone.name)

func fix_skeleton():
	for bone in _get_all_pysical_bones(self):
		_fix_bone(bone)

func set_ragdoll(state: bool):
	_is_ragdoll = state
	var lock_bones = !state
	for bone in _locked_bones:
		bone.lock_rotation = lock_bones

func is_ragdoll() -> bool:
	return _is_ragdoll

func _fill_flip_bones():
	for bone in _get_all_pysical_bones(self):
		var collision_area
		var joint
		for child in bone.get_children():
			if child is CollisionPolygon2D:
				collision_area = child
			if child is Joint2D:
				joint = child
		_flip_bones.push_back(FlipBone.new(collision_area, joint))

func flip_right():
	for flip_bone in _flip_bones:
		flip_bone.set_flip(FlipPos.RIGHT)

func flip_left():
	pass
	#var hip_bone = get_node("hip_bone") as Bone2D
	#hip_bone.apply_scale(Vector2(1, -1))
	#var hip = get_node("hip") as PhysicalBone2D
	#var body = get_node("hip/body") as PhysicalBone2D
	#body.apply_scale(Vector2(1, -1))
	#hip.transform.x = Vector2(1, 23)
	#for bone in hip.get_children():
	#var body_collision = get_node("hip/body/CollisionPolygon2D") as CollisionPolygon2D
	#body_collision.scale.x = -1
	#body_collision.rotation_degrees = 180
	_flip_helper_hip.set_flip_h(true)
	_flip_helper_body.set_flip_h(true)
