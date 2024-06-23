extends Node

class_name Seq


enum DelayType {
	FRAME,
	TIME,
}

class Operation:
	var _callback: Callable
	var _delay: float
	var _delay_type: DelayType
	var _arg: Variant = null
	
	func _init(_callback: Callable, arg: Variant, delay, delay_type: DelayType):
		self._callback = _callback
		self._delay = delay
		self._delay_type = delay_type
		self._arg = arg
	
	func is_time_has_come(delta: float, frame: int) -> bool:
		if self._delay_type == DelayType.FRAME:
			return frame >= self._delay
		else:
			return delta >= self._delay
	
	func operate():
		if self._arg != null:
			#print(_callback, "(", _arg, ")")
			_callback.call(self._arg)
		else:
			#print(_callback, "()")
			_callback.call()

var _start: bool = false
var _operations: Array[Operation] = []
var _cur_frame: int = 0
var _cur_time: float = 0
var _cur_operation: int = 0
var _previous_frame: int = 0
var _previous_time: float = 0


func start():
	_cur_frame= 0
	_cur_time = 0
	_cur_operation = 0
	_previous_frame = 0
	_previous_time = 0
	_start = true

func push(callback: Callable, delay: float = 1.0, type: DelayType = DelayType.FRAME):
	_operations.push_back(Operation.new(callback, null, delay, type))

func push_with(callback: Callable, arg: Variant, delay: float = 1.0, type: DelayType = DelayType.FRAME):
	_operations.push_back(Operation.new(callback, arg, delay, type))

func process(delta: float) -> int:
	if !_start || _operations.size() == 0 || _cur_operation == _operations.size():
		return -1

	_cur_frame += 1
	_cur_time += delta
	var time_delta = _cur_time - _previous_time
	var frame_delta = _cur_frame - _previous_frame
	if _operations[_cur_operation].is_time_has_come(time_delta, frame_delta):
		_operations[_cur_operation].operate()
		_cur_operation += 1
		_previous_frame = _cur_frame
		_previous_time = _cur_time
	return _cur_operation
