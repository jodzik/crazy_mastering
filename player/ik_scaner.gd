extends Node2D

class_name IkScanner

class ScanResult:
	var distance: float
	var node: Node2D
	var normal: Vector2
	var collision_point: Vector2
	
	func _init(node: Node2D, distance: float, normal: Vector2, point: Vector2):
		self.distance = distance
		self.node = node
		self.normal = normal
		self.collision_point = point

enum DistanceBy {
	X,
	Y,
	XY,
}

enum ScanType {
	NEAREST,
	FARTHER,
	MEAN,
}


@export var distance_by: DistanceBy = DistanceBy.X
@export var scan_type: ScanType = ScanType.NEAREST
@export var update_period: float = -1
@export var distance_offset: float = 0
@export var fix_rotation: bool = true
var last_scan: ScanResult

@onready var _base_rotation: float = self.global_rotation
var _rays: Array[RayCast2D]
var _accum: float = 0


func _ready():
	_rays.assign(Find.nodes_of_type(self, "RayCast2D"))
	var parent = get_parent() as CollisionObject2D
	var bones: Array[CollisionObject2D]
	bones.assign(get_tree().current_scene.find_children("*", "PhysicalBoneCustom"))
	for ray in _rays:
		ray.add_exception(parent)
		for bone in bones:
			ray.add_exception(bone)

func _process(delta):
	_accum += delta
	if update_period > 0 and _accum > update_period:
		_accum = 0
		if fix_rotation:
			self.global_rotation = _base_rotation
		last_scan = scan()

func scan() -> ScanResult:
	if scan_type == ScanType.NEAREST or scan_type == ScanType.FARTHER:
		return _scan_nearest_farther()
	else:
		return _scan_mean()

func _scan_nearest_farther() -> ScanResult:
	var result_node: Node2D = null
	var result_distance: float = 0
	var result_normal: Vector2 = Vector2.ZERO
	var result_point: Vector2 = Vector2.ZERO
	for ray in _rays:
		if ray.is_colliding():
			var node = ray.get_collider() as Node2D
			var collision_point = ray.get_collision_point()
			var distance = _get_distance_to(collision_point)
			var is_needed: bool = result_node == null
			is_needed = is_needed or (scan_type == ScanType.NEAREST and distance < result_distance)
			is_needed = is_needed or (scan_type == ScanType.FARTHER and distance > result_distance)
			if is_needed:
				result_node = node
				result_distance = distance
				result_normal = ray.get_collision_normal()
				result_point = collision_point
	if result_node:
		return ScanResult.new(result_node, result_distance, result_normal, result_point)
	else:
		return null

func _scan_mean() -> ScanResult:
	var result_node: Node2D = null
	var result_distance: float = 0
	var result_normal: Vector2 = Vector2.ZERO
	var result_point: Vector2 = Vector2.ZERO
	var result_count: int = 0
	for ray in _rays:
		if ray.is_colliding():
			var node = ray.get_collider() as Node2D
			var collision_point = ray.get_collision_point()
			result_node = node
			result_distance += _get_distance_to(collision_point)
			result_normal += ray.get_collision_normal()
			result_point += collision_point
			result_count += 1
	if result_count > 0:
		return ScanResult.new(result_node, result_distance / result_count,
			result_normal / result_count, result_point / result_count)
	else:
		return null

func _get_distance_to(to: Vector2) -> float:
	var distance: float
	if distance_by == DistanceBy.X:
		distance = abs(self.global_position.x - to.x)
	elif distance_by == DistanceBy.Y:
		distance = abs(self.global_position.y - to.y)
	else:
		distance = self.global_position.distance_to(to)
	distance += distance_offset
	if distance < 0:
		distance = 0
	return distance
