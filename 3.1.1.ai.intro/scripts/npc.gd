extends CharacterBody2D

var brake_mod = 0.08


var health = 100
var defense = 1.0
var melee_attack = 20

var ready_to_heal = false

const WANDERING_SPEED := 200.0
const ATTACK_SPEED := 250.0
const RUNAWAY_SPEED := 300.0

var moving_modifier:float = 1.0

var player_last_known_position = Vector2()

@onready var finite_state_machine: FiniteStateMachine = $NPCBot/FiniteStateMachine
@onready var action_selection_component: ActionSelectionComponent = $NPCBot/ActionSelectionComponent

@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar

@onready var t_heal_ready: Timer = $THealReady
@onready var t_attack: Timer = $TAttack
@onready var t_change_action: Timer = $TChangeAction
@onready var npc_bot: NPCBot = $NPCBot
var my_home_location = Vector2()

var is_attacking = false
var is_ready_to_attack = true
var stress_change_action = false

func _ready():
	health = 100
	npc_bot.init()
	
	my_home_location = position
	
	
func _physics_process(delta):
	$LMyState.set_text(finite_state_machine.current_state.name_state)
	
	velocity = velocity.normalized() * velocity.length() * moving_modifier

	move_and_slide()
	if is_attacking and is_ready_to_attack:
		attack_player()
	texture_progress_bar.value = health
	
	if health <= 0:
		get_parent().remove_child(self)
		queue_free()
	elif health <= 25:
		select_new_action()
	
	if health < 80 and ready_to_heal:
		health += delta
	
	if health < 30 and not stress_change_action:
		stress_change_action = true
		select_new_action()
		

func suffer_attack(damage):
	
	health -= damage * (1/defense)
	t_heal_ready.start(12)
	

func attack_player():
	npc_bot.player.suffer_attack(melee_attack)
	is_ready_to_attack = false
	t_attack.start(0.7)
	
func select_new_action() -> void:
	var next_action = action_selection_component.get_next_action(
		finite_state_machine.current_state.state_id, true, 0.6)
	finite_state_machine.set_state(next_action)
	
	t_change_action.start(randi_range(7, 14))
func _on_t_change_action_timeout() -> void:
	select_new_action()
	
func _on_state_result_changed(state_result):
	if state_result == FiniteStateMachine.state_result_type.started:
		return
	#print(finite_state_machine.current_state.state_id)
	#var next_action = action_selection_component.get_next_action(
		#finite_state_machine.current_state.state_id,
		 #1 if state_result == FiniteStateMachine.state_result_type.success else 0, 
		#0.9)
	#finite_state_machine.set_state(next_action)


func _on_my_vision_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		npc_bot.player_is_in_visible = true
		var next_action = action_selection_component.get_next_action(
		finite_state_machine.current_state.state_id, true, 0.8)
		finite_state_machine.set_state(next_action)
	
		t_change_action.start(randi_range(7, 14))


func _on_my_vision_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		npc_bot.player_is_in_visible = false
		player_last_known_position = body.position


func _on_my_attack_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		is_attacking = true


func _on_t_attack_timeout() -> void:
	is_ready_to_attack = true


func _on_my_attack_body_exited(body: Node2D) -> void:
	is_attacking = false


func _on_t_heal_ready_timeout() -> void:
	ready_to_heal = true
	stress_change_action = false
	
func train():
	action_selection_component.train()
