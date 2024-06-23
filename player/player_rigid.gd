extends Node2D

enum State {
	IDLE,
	WALK,
	RUN,
}

const Anim = {
	IDLE = "idle",
	WALK = "walk",
}


@export var draw_skeleton: bool = false
@export var draw_collisions: bool = false
@export var draw_joints: bool = false
@export var draw_pos: bool = false

@onready var _physical_skeleton = get_node("physical_skeleton") as PhysicalSkeleton
@onready var _skeleton = get_node("skeleton") as Skeleton2D
@onready var _anim_ctl = $animation/anim_ctl as AnimCtl
@onready var _is_any_draw: bool = draw_skeleton or draw_collisions or draw_joints or draw_pos

var _cur_flip: bool = false
var _state: State = State.IDLE


func _draw():
	if draw_skeleton:
		DebugDraw.draw_skeleton(self)
	if draw_collisions:
		DebugDraw.draw_collisions(self)
	if draw_joints:
		DebugDraw.draw_joints(self)
	if draw_pos:
		DebugDraw.draw_cross(self.global_position, 80, 8, Color.WHITE, self)

func _ready():
	_physical_skeleton.move_force = 20000

func _process(delta):
	_skeleton.global_position = _physical_skeleton.get_hip_pos()
	if Input.is_action_just_pressed("move_left"):
		_flip_left()
		if _physical_skeleton.is_left_free():
			_anim_ctl.set_anim(Anim.WALK)
			_physical_skeleton.set_ground_adjust(false)
			_state = State.WALK
	elif Input.is_action_just_pressed("move_right"):
		_flip_right()
		if _physical_skeleton.is_right_free():
			_anim_ctl.set_anim(Anim.WALK)
			_physical_skeleton.set_ground_adjust(false)
			_state = State.WALK
	elif Input.is_action_just_released("move_left") or Input.is_action_just_released("move_right"):
		_anim_ctl.set_anim(Anim.IDLE)
		_physical_skeleton.set_ground_adjust(true)
		_state = State.IDLE
	else:
		if _is_any_draw:
			queue_redraw()
	if _state == State.WALK:
		if not _physical_skeleton.is_current_side_free():
			_anim_ctl.set_anim(Anim.IDLE)
			_physical_skeleton.set_ground_adjust(true)
			_state = State.IDLE

func _physics_process(delta):
	pass

func _flip_right():
	if !_cur_flip:
		return

	_skeleton.scale.x = 1
	_physical_skeleton.flip_right()
	_anim_ctl.set_flip(false)
	_cur_flip = !_cur_flip

func _flip_left():
	if _cur_flip:
		return

	_skeleton.scale.x = -1
	_physical_skeleton.flip_left()
	_anim_ctl.set_flip(true)
	_cur_flip = !_cur_flip
