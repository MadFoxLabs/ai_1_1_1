class_name AttackPlayerFSMComponent
extends Node

@export var actor: CharacterBody2D = null
var name_state = "ATTACK_PLAYER"
var state_id = ActionSelectionComponent.actions.ATTACK_PLAYER
@onready var npc_bot: NPCBot = $"../.."

func state_transition():
	if get_parent().state_result == FiniteStateMachine.state_result_type.started:
		get_parent().set_state_result(FiniteStateMachine.state_result_type.working)
	elif get_parent().state_result == FiniteStateMachine.state_result_type.working:
		get_parent().set_state_result(FiniteStateMachine.state_result_type.failed)


func action_state():
	var target_base_pos = npc_bot.get_player_position()
	var target_pos = (target_base_pos - actor.position).normalized()
	actor.velocity = target_pos * actor.ATTACK_SPEED
	print(str(actor.position.distance_to(target_base_pos)))
	if actor.position.distance_to(target_base_pos) < 190:
		actor.velocity = Vector2()
	
