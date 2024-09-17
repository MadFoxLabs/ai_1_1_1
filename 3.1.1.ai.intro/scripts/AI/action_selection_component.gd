class_name ActionSelectionComponent
extends Node

@export var actor:PhysicsBody2D = null

var model_action_selection: NeuralNetwork
const EPOCHS = 400



@export var verbose_level = 0

enum actions{
	WANDERING,
	ATTACK_PLAYER,
	FIND_FRIENDS,
	RUNAWAY_PLAYER,
	GO_HOME
}

func get_action_input(action):
	if action == null:
		return [0.5, 0.5, 0.5, 0.5, 0.5]
	var one_hot = [0, 0, 0, 0, 0]
	one_hot[action] = 1
	
	return one_hot

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func init():
	create_nn()
	#model_action_selection.load("res://data/nn_action_selection.json")
	
	#train()
	#model_action_selection.store("res://data/nn_action_selection.json")
	
	
func create_nn():
	####Inputs 13
	## current_action 5 inputs -> 0 - 1.0 each
	## player_visible 	0 - 1		-> 0 - 1.0
	## health 			0 - 100 	-> 0 - 1.0
	## player_health  	0 - 100 	-> 0 - 1.0
	## friends_nearby 	0 - 10  	-> 0 - 1.0
	## my_defense		1.0 - 2.0  	-> 0 - 1.0
	## my_attack		0 - 100  	-> 0 - 1.0
	## player_defense	1.0 - 2.0  	-> 0 - 1.0
	## player_attack	0 - 100  	-> 0 - 1.0
	
	####Outputs 5 - number of actions
	
	# 13 Inputs, 30 neurons on hidden layer, 5 Outputs
	model_action_selection = NeuralNetwork.new(13, 30, 5)

func load_tranning_data():
	var file = "res://data/action_selection_data.json"
	var json_as_text = FileAccess.get_file_as_string(file)
	var json_as_dict = JSON.parse_string(json_as_text)
	if json_as_dict:
		#print(json_as_dict)
		return json_as_dict["data"]

func train():
	var inputs = load_tranning_data()
	for i in range(EPOCHS):
		var input = inputs[randi() % inputs.size()]
		model_action_selection.train(input[0], input[1])
		
func get_next_action(current_action=null, current_success=false, temperature=0):
	
	#Input Vector
	var current_input = []
	var vector = []
	
	## current_action 5 inputs -> 0 - 1.0 each
	vector = get_action_input(current_action)
	if verbose_level > 2:
		print("current action: {vector}".format({"vector": vector}))
	for i in vector:
		current_input.append(i)
	
	## player_visible 	0 - 1		-> 0 - 1.0
	current_input.append(1 if get_parent().player_is_in_visible else 0)
	
	## health 			0 - 100 	-> 0 - 1.0
	current_input.append(mapping_value_linear(actor.health, 
	0, 100, 0, 1))  
	
	## player_health  	0 <-> 100 		-> 0 <-> 1.0
	current_input.append(mapping_value_linear(get_parent().get_player_health(),
	0, 100, 0, 1))
	
	## friends_nearby 	0 <-> 10  		-> 0 <-> 1.0
	current_input.append(0)
	
	## my_defense		1.0 <-> 2.0  	-> 0 <-> 1.0
	current_input.append(mapping_value_linear(actor.defense, 
	0, 2.0, 0, 1))
	
	## my_attack		0 <-> 100  		-> 0 <-> 1.0
	current_input.append(mapping_value_linear(actor.melee_attack, 
	0, 100, 0, 1))
	
	## player_defense	1.0 <-> 2.0  	-> 0 <-> 1.0
	current_input.append(mapping_value_linear(get_parent().get_player_defense(), 
	0, 2.0, 0, 1))
	
	## player_attack	0 <-> 100  		-> 0 <-> 1.0
	current_input.append(mapping_value_linear(get_parent().get_player_attack(), 
	0, 100, 0, 1))
	
	var result = model_action_selection.predict(current_input)
	if verbose_level > 2:
		var out_actions = ""
		var index_r = 0
		for a in actions.keys():
			out_actions += a + ": " + "%0.2f" % result[index_r] + ", "
			index_r += 1
		print(out_actions)
	elif verbose_level > 1:
		var result_print = ""
		for r in result:
			result_print += "%0.2f" % r +", "
		print("All outputs: {result}".format({'result': result_print}))
	var result_action = get_action_temperature(temperature, result)
	if verbose_level > 1:
		print(actions.keys()[result_action])
	return result_action

func get_action_temperature(temperature, action_vector):
	var list_actions = action_vector.filter(func(proba): return proba > temperature)
	if len(list_actions) > 0:
		var select = action_vector.find(list_actions[randi() % list_actions.size()])
		return select
	else:
		var max_index = action_vector.find(action_vector.max())
		return max_index

func mapping_value_linear(input:float, min_input:float, max_input:float, min_value:float, max_value:float):
	return (input - min_value) / (max_input - min_input) * (max_value - min_value) + min_value
