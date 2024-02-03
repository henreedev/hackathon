extends AnimatableBody2D
class_name Planet

var gravity := 0.0
var gravity_point_unit_distance := 0.0;

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	gravity = $Area2D.gravity
	gravity_point_unit_distance = $Area2D.gravity_point_unit_distance
	

func _on_area_2d_body_entered(body):
	if body.is_in_group("player") and body is Player:
		body.add_planet(self)

func _on_area_2d_body_exited(body):
	if body.is_in_group("player") and body is Player:
		body.remove_planet(self)
