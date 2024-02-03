extends RigidBody2D
class_name Player

const SPEED = 300.0
const JUMP_VELOCITY = -300.0

var _planets = []
# Planet with highest gravity
var _target_planet : Planet

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _process(delta):
	pass
# Calculate actual gravity values from each planet, find largest
func _calc_gravity_vector():
	var largest_gravity = 0.0
	if !_planets:
		_target_planet = null
	for planet in _planets:
		var p_gravity = planet.gravity
		var p_dist = planet.position.distance_to(self.position)
		var p_unit_dist = planet.gravity_point_unit_distance
		var p_eff_grav = pow(p_dist / p_unit_dist, 2) * p_gravity
		if p_eff_grav > largest_gravity:
			largest_gravity = p_eff_grav
			_target_planet = planet 




func add_planet(planet : Planet):
	_planets.append(planet)

func remove_planet(planet : Planet):
	_planets.erase(planet)

func _physics_process(delta):
	_calc_gravity_vector()
	if _target_planet:
		var rotate_speed = 1.0
		rotation = lerp_angle(rotation, get_angle_to(_target_planet.position), delta * rotate_speed)
	else: 
		var rotate_speed = 1.0
		rotation = lerp_angle(rotation, 0, delta * rotate_speed)
	## Add the gravity.
	#if not is_on_floor():
		#velocity.y += gravity * 0.1 * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("jump") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var direction = Input.get_axis("move_left", "move_right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
#
	#move_and_slide()
