class_name MainMenu
extends Control
@onready var start_button = $MarginContainer/HBoxContainer/VBoxContainer/Button
@onready var exit_button = $MarginContainer/HBoxContainer/VBoxContainer/Button2
# Called when the node enters the scene tree for the first time.

@onready var start_level = preload("res://scenes/main.tscn") as PackedScene
func _ready():
	start_button.button_down.connect(on_start_pressed)
	exit_button.button_down.connect(on_exit_pressed)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
func on_start_pressed() -> void:
	get_tree().change_scene_to_packed(start_level)
	
func on_exit_pressed() -> void:
	get_tree().quit()
	
