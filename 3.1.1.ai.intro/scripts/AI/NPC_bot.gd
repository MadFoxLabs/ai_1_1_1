class_name NPCBot

extends Node
@onready var action_selection_component: ActionSelectionComponent = $ActionSelectionComponent


var player_is_in_visible = false
@export var player:PhysicsBody2D = null

func _ready() -> void:
	pass

func init():
	action_selection_component.init()

func get_player_health():
	if player == null:
		return 50
	if not player_is_in_visible:
		return 50
	
	return player.health
	
func get_player_defense():
	if player == null:
		return 1.5
	if not player_is_in_visible:
		return 1.5
		
	return player.defense


func get_player_attack():
	if player == null:
		return 10
	if not player_is_in_visible:
		return 10
		
	return player.melee_attack
	
func get_player_position():
	if player == null:
		return get_parent().my_home_location
	if not player_is_in_visible:
		return get_parent().my_home_location
		
	return player.position
	
func get_nearest_friend():
	
	return Vector2()
	
func train_ai():
	action_selection_component.train()
