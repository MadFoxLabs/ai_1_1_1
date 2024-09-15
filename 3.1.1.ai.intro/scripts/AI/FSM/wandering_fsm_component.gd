extends Node

class_name WanderingFSMComponent

var name_state = "WANDERING"
var state_id = ActionSelectionComponent.actions.WANDERING
@export var actor: CharacterBody2D = null

var current_direction = null
var steps = 0
var max_steps = 700

func state_transition():
	if get_parent().state_result == FiniteStateMachine.state_result_type.started:
		get_parent().set_state_result(FiniteStateMachine.state_result_type.working)
	elif get_parent().state_result == FiniteStateMachine.state_result_type.working:
		get_parent().set_state_result(FiniteStateMachine.state_result_type.success)
		
func action_state():
	if actor == null:
		return
	if current_direction == null:
		current_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * actor.WANDERING_SPEED
	
	steps += 1
	if steps > max_steps:
		print()
		steps = 0
		
		current_direction = current_direction.rotated(3*PI/4 + deg_to_rad(randi_range(-5,5)))
		
		
	actor.velocity = current_direction
