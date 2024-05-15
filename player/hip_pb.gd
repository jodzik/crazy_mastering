extends PhysicalBone2D

@onready var _base_rotation = self.rotation


func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _physics_process(delta):
	#var diff_angle = angle_difference(_base_rotation, self.rotation)
	#print("diff=", diff_angle)
	#if abs(diff_angle) > deg_to_rad(5):
		#self.rotate(-diff_angle / 10.0)
	pass
