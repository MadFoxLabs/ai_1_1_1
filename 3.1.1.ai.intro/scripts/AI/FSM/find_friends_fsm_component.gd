class_name FindFriendsFSMComponent
extends Node

@export var actor: CharacterBody2D = null
var name_state = "FIND_FRIENDS"
var state_id = ActionSelectionComponent.actions.FIND_FRIENDS
@onready var npc_bot: NPCBot = $"../.."

func state_transition():
	if get_parent().state_result == FiniteStateMachine.state_result_type.started:
		get_parent().set_state_result(FiniteStateMachine.state_result_type.working)
	elif get_parent().state_result == FiniteStateMachine.state_result_type.working:
		get_parent().set_state_result(FiniteStateMachine.state_result_type.failed)


func action_state():
	var target_base_pos = npc_bot.get_nearest_friend()
	var target_pos = (target_base_pos - actor.position).normalized()
	actor.velocity = target_pos * actor.WANDERING_SPEED
	
	if actor.position.distance_to(target_base_pos) < 1:
		actor.velocity = Vector2()
