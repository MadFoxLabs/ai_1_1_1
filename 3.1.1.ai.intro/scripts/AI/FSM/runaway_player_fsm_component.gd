class_name RunawayPlayerFSMComponent
extends Node

@export var actor: CharacterBody2D = null
var name_state = "RUNAWAY_PLAYER"
var state_id = ActionSelectionComponent.actions.RUNAWAY_PLAYER
@onready var npc_bot: NPCBot = $"../.."

func state_transition():
	if get_parent().state_result == FiniteStateMachine.state_result_type.started:
		get_parent().set_state_result(FiniteStateMachine.state_result_type.working)
	elif get_parent().state_result == FiniteStateMachine.state_result_type.working:
		get_parent().set_state_result(FiniteStateMachine.state_result_type.failed)


func action_state():
	var target_base_pos = npc_bot.get_player_position()
	var target_pos = (target_base_pos - actor.position).normalized()
	actor.velocity = -target_pos * actor.ATTACK_SPEED
	
	if actor.position.distance_to(target_base_pos) < 1:
		actor.velocity = Vector2()
	
