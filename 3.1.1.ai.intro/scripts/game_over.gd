extends Control
@onready var label: Label = $CenterContainer/VBoxContainer/Label

func _physics_process(delta: float) -> void:
	if Input.is_key_pressed(KEY_R):
		label.set_text("Loading")
		get_tree().change_scene_to_file("res://scenes/world.tscn")
		
		
#func _process(delta: float) -> void:
	
	
