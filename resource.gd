extends RigidBody2D
class_name Resources

# Called when the node enters the scene tree for the first time.
func _ready():
	angular_velocity = 5.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
	


func _on_body_entered(body):
	if body.is_in_group("player"):
		get_tree().get_first_node_in_group("player").pickup_resource()
		queue_free()
