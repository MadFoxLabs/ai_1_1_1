extends Node2D

@onready var npc: CharacterBody2D = $NPCs/NPC

@onready var npc_s: Node2D = $NPCs

#@onready var button: Button = $CanvasLayer/Button
@onready var button: Button = $CanvasLayer/MarginContainer/HBoxContainer/Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_button_up() -> void:
	for c in npc_s.get_children():
		c.train()
		
	button.release_focus()
