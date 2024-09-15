extends Node2D

@onready var npc: CharacterBody2D = $NPCs/NPC
@onready var button: Button = $CanvasLayer/Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_button_up() -> void:
	npc.train()
	button.release_focus()
