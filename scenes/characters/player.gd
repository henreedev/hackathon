extends RigidBody2D
class_name Player

const SPEED = 135.0
const JUMP_VELOCITY = -300.0

var _speed_mod = 1.0
var _potion_weight = 1.12

var grounded = false
var game_over = false
var at_idle_speed = false
var is_mid_jump = true
var idle_speed = 10.0

var _planets = []
# Planet with highest gravity
var _target_planet : Planet
var _planet_normal := Vector2()
var _jumped_last_frame = false
var _jumped_2_frames_ago = false
var _num_resources = 0
var loss = false
var show_title = false
var in_black_hole = false
var black_hole_strength : float = 0.0

var _trailing_player = true
var _closest_potion : Resources
var _trail_guide : GPUParticles2D
var _should_spawn_trail_guide = false
const _trail_guide_speed = 300.0

@onready var _trail_guide_scene : PackedScene = preload("res://scenes/environment/trail_guide.tscn")
@onready var _earth = get_tree().get_first_node_in_group("earth")
@onready var potion_icon : PackedScene = preload("res://scenes/environment/potion_icon.tscn")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	await get_tree().create_timer(10.0).timeout
	_should_spawn_trail_guide = true
	

func _process(delta):
	if !_earth:
		_earth = get_tree().get_first_node_in_group("earth")
	if not game_over:
		_check_game_over()
	_lerp_zoom(delta)
	_update_closest_potion()
	_update_trail_guide(delta)
	_adjust_heat_rate_mod(delta)
	pass

func _adjust_heat_rate_mod(delta):
	if in_black_hole:
		_earth.heat_rate_mod = lerp(1.0, 4.0, black_hole_strength)
	else:
		_earth.heat_rate_mod = 1.0

func _update_closest_potion():
	_closest_potion = null 
	var _least_distance = 9999999.0
	for potion : Resources in get_tree().get_nodes_in_group("potions"):
		var dist = potion.position.distance_to(position)
		if dist < _least_distance:
			_least_distance = dist
			_closest_potion = potion

func _update_trail_guide(delta):
	if not game_over:
		if not _trail_guide and _should_spawn_trail_guide:
			_trail_guide = _trail_guide_scene.instantiate()
			$TrailGuide.add_child(_trail_guide) # transform is disconnected from player
			_trail_guide.position = _earth.position
		if _trail_guide:
			const close_distance = 10.0
			if _trailing_player:
				_trail_guide.position = _trail_guide.position.move_toward(position, _trail_guide_speed * delta)
				if _trail_guide.position.distance_to(position) < close_distance:
					_trailing_player = false
			else: 
				if _closest_potion:
					_trail_guide.position = _trail_guide.position.move_toward(_closest_potion.position, _trail_guide_speed * delta)
					if _trail_guide.position.distance_to(_closest_potion.position) < close_distance:
						_trail_guide.position = _earth.position
						_trailing_player = true
				elif _num_resources > 1:
					_trail_guide.position = _trail_guide.position.move_toward(_earth.position, _trail_guide_speed * delta)
					if _trail_guide.position.distance_to(_earth.position) < close_distance:
						_trailing_player = true
	

func _lerp_zoom(delta):
	if not game_over:
		var target_zoom = 4.0 if grounded else 2.0
		var change_strength = 1.0
		var new_zoom = lerp($Camera2D.zoom.x, target_zoom, change_strength * delta)
		$Camera2D.zoom = Vector2(new_zoom, new_zoom)

func _check_game_over():
	if _earth.heat == 100.0 or _earth.heat == 0.0 and _earth.heat_rate <= 0.0:
		game_over = true
		loss = _earth.heat == 100.0
		if _trail_guide:
			_trail_guide.queue_free()
		# commence ending sequence
		# stop camera
		var camera : Camera2D = $Camera2D
		camera.position = position
		camera.position_smoothing_enabled = true
		remove_child(camera)
		get_tree().root.add_child(camera)
		$EndingGong.play()
		var tween = get_tree().create_tween()
		tween.tween_property($BackgroundMusic, "volume_db", -50, 2.0)
		# center camera on earth
		await get_tree().create_timer(2.0).timeout
		camera.position = _earth.position
		tween = get_tree().create_tween()
		tween.tween_property(camera, "zoom", Vector2(1.5, 1.5), 0.5)
		if loss:
			$BurningSound.play()
			tween.tween_property($BurningSound, "volume_db", -17, 0.5)
		else:
			$Cheering.play()
			tween.tween_property($Cheering, "volume_db", -25, 3.0)
		# destroy earth
		await get_tree().create_timer(1.5).timeout
		tween = get_tree().create_tween() 
		if loss:
			tween.tween_property(_earth, "modulate", Color(5.0, 0.3, .05), 3.0)
			tween.tween_property(_earth, "modulate", Color(0, 0, 0), 1.0)
			tween.tween_callback(_earth.set_invisible)
			tween.tween_property($BurningSound, "volume_db", -60, 0.1)
		else:
			tween.tween_property(_earth, "modulate", Color(1.25, 1.25, 1.25), 3.0)
			tween.tween_property(_earth, "modulate", Color(1.0, 1.0, 1.0), 1.0)
			tween.tween_property($Cheering, "volume_db", -60, 5.0)
		await get_tree().create_timer(5.0).timeout
		show_title = true
		await get_tree().create_timer(4.0).timeout
		get_tree().root.remove_child(camera)
		camera.position = Vector2(0, 0)
		add_child(camera)
		show_title = false
		get_tree().reload_current_scene()
		

func pickup_resource():
	$ResourcePickup.pitch_scale = randf_range(0.9, 1.2)
	$ResourcePickup.play()
	_num_resources += 1
	_speed_mod /= _potion_weight
	var icon = potion_icon.instantiate()
	add_child(icon)
	icon.position = Vector2(randi_range(-10, 10), randi_range(-20, -40))

func deposit_resources():
	if _num_resources:
		$ResourceDeposit.pitch_scale = randf_range(0.9, 1.2)
		$ResourceDeposit.play()
		get_tree().call_group("potion_icon", "set_invisible")
		_earth.heat -= 20 * _num_resources
		_earth.heat_rate -= 0.16 * _num_resources
		_num_resources = 0
		_speed_mod = 1.0

# Calculate actual gravity values from each planet, find largest
func _calc_gravity_vector():
	var largest_gravity = 0.0
	if !_planets:
		_target_planet = null
		_planet_normal = Vector2(0, -1)
	for planet in _planets:
		var p_gravity = planet.gravity
		var p_dist = planet.position.distance_to(self.position)
		var p_unit_dist = planet.gravity_point_unit_distance
		var p_sqr_str = pow(p_unit_dist / p_dist, 2)
		var p_eff_grav = p_sqr_str * p_gravity
		if planet._type == Planet.Type.BLACK_HOLE:
			black_hole_strength = p_sqr_str
			in_black_hole = true
		if p_eff_grav > largest_gravity:
			largest_gravity = p_eff_grav
			_target_planet = planet 
			_planet_normal = planet.position.direction_to(self.position)

func add_planet(planet : Planet):
	_planets.append(planet)

func remove_planet(planet : Planet):
	_planets.erase(planet)

func _integrate_forces(state):
	if _target_planet:
		if grounded:
			var rotation_weight = 10
			state.transform = Transform2D(lerp_angle(rotation, position.angle_to_point(_target_planet.position) - PI/2, rotation_weight * state.step), position)
			#state.transform = Transform2D(position.angle_to_point(_target_planet.position) - PI/2, position)
		else:
			var rotation_weight = 1.0
			state.transform = Transform2D(lerp_angle(rotation, position.angle_to_point(_target_planet.position) - PI/2, rotation_weight * state.step), position)
	else: 
		var rotation_weight = 7.0
		state.transform = Transform2D(lerp_angle(rotation, 0, rotation_weight * state.step), position)


func _physics_process(delta):
	_calc_gravity_vector()
	at_idle_speed = linear_velocity.length() < idle_speed

	# Handle jump.
	if Input.is_action_just_pressed("jump") and grounded:
		set_axis_velocity(_planet_normal * -JUMP_VELOCITY)
		grounded = false
		is_mid_jump = true
		$AnimatedSprite2D.animation = "jump"
		$AnimatedSprite2D.frame = 3

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		var right_dir = _planet_normal.rotated(PI/2)
		if not grounded: right_dir = Vector2(1, 0)
		var speed_diff = max(SPEED * _speed_mod - linear_velocity.project(right_dir).length(), 0)
		var change_rate = 5.0
		apply_central_force(direction * right_dir * speed_diff * change_rate)
	var vert_direction = Input.get_axis("move_down", "move_up")
	if vert_direction:
		var up_dir = _planet_normal
		if not grounded: up_dir = Vector2(0, -1)
		var speed_diff = max(SPEED * _speed_mod - linear_velocity.project(up_dir).length(), 0)
		var change_rate = 5.0
		apply_central_force(vert_direction * up_dir * speed_diff * change_rate)
	_set_animation()
	_jumped_2_frames_ago = _jumped_last_frame
	_jumped_last_frame = false
	if _target_planet:
		var buffer = 10.0
		if position.distance_to(_target_planet.position) - buffer > _target_planet.gravity_point_unit_distance:
			grounded = false
			is_mid_jump = true


func _set_animation():
	$AnimatedSprite2D.play()
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		$AnimatedSprite2D.flip_h = direction < 0
	if is_mid_jump:
		$AnimatedSprite2D.animation = "jump"
		if $AnimatedSprite2D.frame == 6:
			$AnimatedSprite2D.pause()
	elif grounded and at_idle_speed:
		$AnimatedSprite2D.animation = "idle"
	elif grounded:
		$AnimatedSprite2D.animation = "run"
	

func _on_body_entered(body):
	if body.is_in_group("planet") and !_jumped_last_frame and !_jumped_2_frames_ago:
		grounded = true
		is_mid_jump = false

