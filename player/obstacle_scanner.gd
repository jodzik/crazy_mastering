extends Node

class_name ObstacleScanner

@export var height_scanner_l: IkScanner
@export var height_scanner_r: IkScanner
@export_range(10, 500, 1) var height_for_block: float = 100 

func is_left_free() -> bool:
	return _is_free(height_scanner_l)

func is_right_free() -> bool:
	return _is_free(height_scanner_r)

func _is_free(height_scanner: IkScanner) -> bool:
	var result = height_scanner.last_scan
	if result:
		return result.distance < height_for_block
	else:
		return true
