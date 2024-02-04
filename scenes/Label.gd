extends Label

@onready var _earth = get_tree().get_first_node_in_group("earth")

const BASE_TEMP = 59.0
const MAX_TEMP = 212.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !_earth:
		_earth = get_tree().get_first_node_in_group("earth")
	var heat = _earth.heat
	var heat_rate = _earth.heat_rate
	var heat_percent = heat / 100.0
	var shadow_color = Color(lerp(100, 300, heat_percent) / 255.0, lerp(10, 100, heat_percent)/ 255.0 , lerp(250, 20, heat_percent) / 255.0)
	label_settings.shadow_color = shadow_color
	var shadow_size = (heat_percent + 1) * 3.0
	label_settings.shadow_size = shadow_size
	var font_size = ((heat_percent + 1) ** 2) * 36
	label_settings.font_size = font_size
	var danger : bool = heat > 75.0
	var fahrenheit = lerp(BASE_TEMP, MAX_TEMP, heat_percent)
	var celsius = (fahrenheit - 32) * 5.0 / 9.0
	var temp_label = str(int(fahrenheit)) + "°F (" + str(int(celsius)) + "°C)"
	if get_tree().get_first_node_in_group("player").show_title:
		create_tween().tween_property(label_settings, "font_size", 4 * 36, 1.0).set_ease(Tween.EASE_IN_OUT)
		temp_label += "\nBOILING POINT"
	text = temp_label
	
