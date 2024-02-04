extends Node2D

class_name Main

@export var map_size : Vector2 = Vector2(4000, 4000) 
@export var earth_pos := Vector2(2000, 4000)
@export var spawn_pos := Vector2(2000, 3800)
@export var planet_scene : PackedScene
@export var resource : PackedScene
@export var lower_dev := 15.0
@export var upper_dev := 200.0 

var intro_finished = false

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().call_group("planet", "queue_free")
	get_tree().call_group("potion_icon", "queue_free")
	get_tree().call_group("potions", "queue_free")
	$ParallaxBackground.scroll_base_offset = get_viewport_rect().size * 0.5 * (Vector2.ONE / 0.15 - Vector2.ONE)
	_spawn_planets(450)
	_spawn_resources(12)
	await get_tree().create_timer(0.1).timeout
	get_tree().get_first_node_in_group("player").position = spawn_pos
	await get_tree().create_timer(3.0).timeout
	if not intro_finished:
		var tween = create_tween().set_parallel(true)
		#tween.tween_property($Label, "modulate", Color(1.0, 1.0, 1.0), 1.0).from(Color(0, 0, 0, 0))
		tween.tween_property($Label, "visible_ratio", 1.0, 1.0).from(0.0)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_update_labels()

func _update_labels():
	if get_tree().get_first_node_in_group("player").game_over:
		$Label.visible = false
		$Label2.visible = false
	else: 
		$Label.visible = true
		$Label2.visible = true
	if not intro_finished:
		if Input.is_action_just_pressed("jump"):
			var tween = create_tween()
			tween.set_parallel(true)
			tween.tween_property($Label, "modulate", Color(0, 0, 0, 0), 1.0)
			tween.tween_property($Label2, "modulate", Color(1.0, 1.0, 1.0, 1.0), 1.0).from(Color(0, 0, 0, 0))
			tween.tween_property($Label2, "position", $Label2.position + Vector2(0, -400), 4.0)
			tween.tween_property($Label2, "modulate", Color(1, 1, 1, 0), 2.0).set_delay(2.0)
			intro_finished = true

func _spawn_planets(count : int):
	# spawn earth
	var earth : Planet = planet_scene.instantiate()
	earth.position = earth_pos
	earth.make_earth()
	add_child(earth)
	# spawn other planets
	var count_along_dim = sqrt(count)
	for i in count:
		var planet : Planet = planet_scene.instantiate()
		var planet_x = map_size.x / count_along_dim * fmod(i, count_along_dim)
		var planet_y = (int) (map_size.y / count_along_dim * i / count_along_dim) - 500
		
		planet.position = Vector2(planet_x + randf_range(lower_dev, upper_dev), planet_y + randf_range(lower_dev, upper_dev))
		add_child(planet)
	pass

func _spawn_resources(count : int):
	var count_along_dim = sqrt(count)
	for i in count:
		var _resource : Resources = resource.instantiate()
		var resource_x = map_size.x / count_along_dim * fmod(i, count_along_dim)
		var resource_y = (int) ((map_size.y) / count_along_dim * i / count_along_dim) - 700
		_resource.position = Vector2(resource_x + randf_range(lower_dev, upper_dev), resource_y + randf_range(lower_dev, upper_dev))
		add_child(_resource)
