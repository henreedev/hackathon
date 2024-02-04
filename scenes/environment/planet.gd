extends AnimatableBody2D
class_name Planet

enum Type {MOON, BLACK_HOLE, ICE, LAVA, EARTH}
var _type : Type 

var gravity := 0.0
var gravity_point_unit_distance := 0.0;
var heat := 0.0
var heat_rate := 1.0
var heat_rate_mod := 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	if _type != Type.EARTH:
		_type = randi() % 4
		$AnimatedSprite2D.frame = _type
		var _scale = randf_range(0.8, 1.0)
		scale = Vector2(_scale, _scale)
		$Area2D.gravity_point_unit_distance *= _scale
	if _type == Type.BLACK_HOLE:
		$Area2D.gravity *= 2
		$Area2D.gravity_point_unit_distance *= 1.3
		physics_material_override.friction = 0.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	gravity = $Area2D.gravity
	gravity_point_unit_distance = $Area2D.gravity_point_unit_distance
	if _type == Type.EARTH:
		heat += heat_rate * heat_rate_mod * delta
		heat = clamp(heat, 0, 100)
		var heat_percent = (heat / 100.0) * 10 + 1.0
		modulate = Color(1.0 * heat_percent, 1.0, 1.0)
	

func set_invisible():
	visible = false

func make_earth():
	_type = Type.EARTH
	$AnimatedSprite2D.frame = _type
	var earth_scale = 10
	scale = Vector2(earth_scale, earth_scale)
	$Area2D.gravity_point_unit_distance *= earth_scale
	var gravity_zone_scale = 0.19
	$Area2D.scale = Vector2(gravity_zone_scale, gravity_zone_scale)
	var gravity_scale = 0.5
	$Area2D.gravity *= gravity_scale
	add_to_group("earth")

func _on_area_2d_body_entered(body):
	if body.is_in_group("player") and body is Player:
		body.add_planet(self)
		if _type == Type.BLACK_HOLE:
			$TickingSound.play()
			$BlackHoleSound.play()
			body.in_black_hole = true

func _on_area_2d_body_exited(body):
	if body.is_in_group("player") and body is Player:
		body.remove_planet(self)
		if _type == Type.BLACK_HOLE:
			$TickingSound.stop()
			$BlackHoleSound.stop()
			body.in_black_hole = true

func _set_heat_rate_mod(value):
	heat_rate_mod = value

func _on_grounded_area_2d_body_entered(body):
	if _type == Type.EARTH and body.is_in_group("player"):
		body.deposit_resources()
	elif _type == Type.BLACK_HOLE and body.is_in_group("player"):
		get_tree().create_tween().tween_property($TickingSound, "pitch_scale", 1.2, 1.5)
		

func _on_grounded_area_2d_body_exited(body):
	if _type == Type.BLACK_HOLE and body.is_in_group("player"):
		body.in_black_hole = false
		get_tree().create_tween().tween_property($TickingSound, "pitch_scale", 1.0, 0.5)
