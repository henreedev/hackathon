extends Node2D

@export var map_size : Vector2 = Vector2(4000, 4000) 
@export var earth_pos := Vector2(2000, 4000)
@export var spawn_pos := Vector2(2000, 3800)
@export var planet : PackedScene
@export var resource : PackedScene
@export var lower_dev := 15.0
@export var upper_dev := 200.0 
# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().call_group("planet", "queue_free")
	get_tree().call_group("potion_icon", "queue_free")
	get_tree().call_group("potions", "queue_free")
	$ParallaxBackground.scroll_base_offset = get_viewport_rect().size * 0.5 * (Vector2.ONE / 0.15 - Vector2.ONE)
	_spawn_planets(450)
	_spawn_resources(10)
	await get_tree().create_timer(0.2).timeout
	get_tree().get_first_node_in_group("player").position = spawn_pos

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _spawn_planets(count : int):
	# spawn earth
	var earth : Planet = planet.instantiate()
	earth.position = earth_pos
	earth.make_earth()
	add_child(earth)
	# spawn other planets
	var count_along_dim = sqrt(count)
	for i in count:
		var planet : Planet = planet.instantiate()
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
