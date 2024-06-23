extends Node2D

const AnimState = {
	IDLE = "idle",
	WALK_RIGHT = "walk_right",
}

@onready var _anim_tree: AnimationTree = get_node("./AnimationTree")
@onready var _hip = get_node("skelet/Skeleton2DPhysical/hip") as PhysicalBone2D
@onready var _hip_bone = get_node("skelet/Skeleton2DPhysical/hip_bone") as Bone2D
@onready var _parts = get_node("skelet/parts") as Node2D
@onready var _skelet = get_node("skelet/Skeleton2DPhysical") as Skeleton2DPhysical
@onready var _skelet_base = get_node("skelet") as Node2D


func _ready():
	_set_anim(AnimState.IDLE)


func _process(delta):
	pass


func _set_anim(anim: StringName):
	_anim_tree["parameters/transition/transition_request"] = anim


func _input(event: InputEvent):
	if event.is_action_pressed("move_left"):
		#_parts.apply_scale(Vector2(-1, 1))
		_skelet.flip_left()
		#var foor_l = get_node("skelet/Skeleton2DPhysical/hip/leg_l/shin_l/foot_l")
		#_hip_bone.apply_scale(Vector2(-1, 1))
		#_hip.apply_scale(Vector2(-1, 1))
		#_parts.apply_scale(Vector2(-1, 1))
		#_skelet_base.scale.x = -1.0
		#_skelet.apply_scale(Vector2(-1.0, 1.0))
		pass
	if event.is_action_pressed("move_right"):
		_set_anim(AnimState.WALK_RIGHT)
		_hip.add_constant_central_force(Vector2.RIGHT * 10000.0)
	elif event.is_action_released("move_right"):
		_set_anim(AnimState.IDLE)
		_hip.constant_force = Vector2.ZERO
	elif event is InputEventKey and event.is_pressed():
		var keycode: String = event.as_text()
		if keycode == "R":
			_skelet.set_ragdoll(!_skelet.is_ragdoll())
		elif keycode == "T":
			var head_part = get_node("Skeleton2DPhysical/parts/head") as Polygon2D
			var texture = load("res://player/gbot/gBot_head_changed.png")
			head_part.texture = texture
		elif  keycode == "Y":
			_skelet.draw_bones()
		

