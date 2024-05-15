extends Skeleton2D

class_name Skeleton2DPhysical

@export var right_leg: PhysicalBone2D
@export var left_leg: PhysicalBone2D

var _locked_bones: Array[PhysicalBone2D] = []
var _is_ragdoll: bool = false


func _ready():
	_fill_locked_bones()
	_setup_collisions()
	_activate_modification()
	fix_skeleton()


func _fill_locked_bones():
	for bone in _get_all_pysical_bones(self):
		if bone.lock_rotation:
			_locked_bones.push_back(bone)


func _add_physical_bones_recursive(node: Node2D, stack: Array[PhysicalBone2D]):
	for child in node.get_children():
		if child is PhysicalBone2D:
			stack.push_back(child)
			_add_physical_bones_recursive(child, stack)


func _get_all_pysical_bones(node: Node2D) -> Array[PhysicalBone2D]:
	var stack: Array[PhysicalBone2D]
	if node is PhysicalBone2D:
		stack.push_back(node as PhysicalBone2D)
	_add_physical_bones_recursive(node, stack)
	return stack


func _setup_collisions_among_themselves(elements: Array[PhysicalBone2D]):
	for i in elements:
		for j in elements:
			if i != j:
				i.add_collision_exception_with(j)


func _setup_collisions():
	var hip: PhysicalBone2D = get_node("./hip_pb")
	var body: PhysicalBone2D = get_node("./hip_pb/body")
	var jaw: PhysicalBone2D = get_node("./hip_pb/body/head/jaw")
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
