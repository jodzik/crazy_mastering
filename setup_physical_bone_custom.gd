@tool
extends EditorScript


func _run():
	var physical_skeleton: PhysicalSkeleton = get_scene().find_child("physical_skeleton")
	var bones: Array[PhysicalBoneCustom]
	bones.assign(physical_skeleton.find_children("*", "PhysicalBoneCustom"))
	for bone in bones:
		bone.bone.global_position = bone.global_position
		print("update: name=", bone.name, " to=", bone.global_position)
