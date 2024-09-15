
class_name FiniteStateMachine
extends Node

@export var verbose_level = 1

var current_state = null

#var long_decision_timer: Timer
#var short_decision_timer: Timer

@export var actor: CharacterBody2D = null
enum state_result_type{
	failed,
	success,
	started,
	working,
}

var state_result = state_result_type.started
signal change_state_result(result_value)

var overide_next_action = null
var memory_target_location = null

func _ready():
	current_state = $WanderingFSMComponent


	#long_decision_timer = Timer.new()
	#short_decision_timer = Timer.new()
	#
	#long_decision_timer.wait_time = 60
	#short_decision_timer.wait_time = 5
	#
	#long_decision_timer.connect("timeout", long_decision)
	#short_decision_timer.connect("timeout", short_decision)
	#get_parent().add_child.call_deferred(long_decision_timer)
	#get_parent().add_child.call_deferred(short_decision_timer)
	#
	#
	#long_decision_timer.autostart = true
	#short_decision_timer.autostart = true
	#long_decision_timer.start()
	#short_decision_timer.start()
	
	if actor != null:
		self.connect("change_state_result", actor._on_state_result_changed)

func get_pretty_current_state():
	return current_state.name_state

func _physics_process(delta):
	
	if current_state != null:
		if current_state.has_method("action_state"):
			current_state.action_state()

func long_decision():

	pass

func short_decision():
	
	pass

func small_deviation(my_vector:Vector2):
	return my_vector.rotated(randf_range(PI/6, PI/6*3))
func set_state(new_state):
	if overide_next_action != null:
		new_state = overide_next_action
		overide_next_action = null
		
	match new_state:
		ActionSelectionComponent.actions.WANDERING:
			current_state = $WanderingFSMComponent
		ActionSelectionComponent.actions.ATTACK_PLAYER:
			current_state = $AttackPlayerFSMComponent
		ActionSelectionComponent.actions.FIND_FRIENDS:
			current_state = $FindFriendsFSMComponent
		ActionSelectionComponent.actions.RUNAWAY_PLAYER:
			current_state = $RunawayPlayerFSMComponent
		ActionSelectionComponent.actions.GO_HOME:
			current_state = $GoHomeFSMComponent

	set_state_result(state_result_type.started)
	#change_state_result.emit(state_result_type.started)
	if verbose_level > 0:
		print(ActionSelectionComponent.actions.keys()[new_state] )
	return current_state
	
func set_state_result(result_type):
	state_result = result_type
	change_state_result.emit(result_type)
