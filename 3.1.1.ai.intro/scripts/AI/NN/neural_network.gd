class_name NeuralNetwork

var input_nodes: int
var hidden_nodes: int
var output_nodes: int 

var weights_input_hidden: Matrix
var weights_output_hidden: Matrix

var bias_hidden: Matrix
var bias_output: Matrix 

var learning_rate: float
var activation_function: Callable
var activation_dfunction: Callable

func set_learning_rate(_learning_rate: float = 0.1):
	
	learning_rate = _learning_rate

func set_activation_function(callback: Callable = Callable(Activation, "sigmoid"),
							dcallback: Callable = Callable(Activation, "dsigmoid")):
	activation_function = callback 
	activation_dfunction = dcallback

func _init(_input_nodes: int, _hidden_nodes: int, _output_nodes: int):
	
	randomize()
	
	input_nodes = _input_nodes
	hidden_nodes = _hidden_nodes
	output_nodes = _output_nodes
	
	weights_input_hidden = Matrix.generate_random_matrix(Matrix.new(hidden_nodes, input_nodes))
	weights_output_hidden = Matrix.generate_random_matrix(Matrix.new(output_nodes, hidden_nodes))
	
	bias_hidden = Matrix.generate_random_matrix(Matrix.new(hidden_nodes, 1))
	bias_output = Matrix.generate_random_matrix(Matrix.new(output_nodes, 1))
	
	set_learning_rate()
	set_activation_function()
	
func train(input_array: Array, target_array: Array):
	
	var inputs = Matrix.build_matrix_from_array(input_array)
	var targets = Matrix.build_matrix_from_array(target_array)
	
	var hidden = Matrix.multiply_matrices(weights_input_hidden, inputs)
	hidden = Matrix.add_matrices(hidden, bias_hidden)
	hidden = Matrix.apply_function_to_matrix(hidden, activation_function)
	
	var outputs = Matrix.multiply_matrices(weights_output_hidden, hidden)
	outputs = Matrix.add_matrices(outputs, bias_output)
	outputs = Matrix.apply_function_to_matrix(outputs, activation_function)
	
	var output_errors = Matrix.subtract_matrices(targets, outputs)
	
	var gradients = Matrix.apply_function_to_matrix(outputs, activation_dfunction)
	gradients = Matrix.multiply_matrices_element_wise(gradients, output_errors)
	gradients = Matrix.multiply_matrix_by_scalar(gradients, learning_rate)
	
	var hidden_layer_transposed = Matrix.tranpose_matrix(hidden)
	var weight_hidden_output_layer_deltas = Matrix.multiply_matrices(gradients, hidden_layer_transposed)
	
	weights_output_hidden = Matrix.add_matrices(weights_output_hidden, weight_hidden_output_layer_deltas)	
	
	bias_output = Matrix.add_matrices(bias_output, gradients)
	
	var weights_output_hidden_transposed = Matrix.tranpose_matrix(weights_output_hidden)
	var hidden_layer_errors = Matrix.multiply_matrices(weights_output_hidden_transposed, output_errors)
	
	var hidden_layer_gradient = Matrix.apply_function_to_matrix(hidden, activation_dfunction)	

	hidden_layer_gradient = Matrix.multiply_matrices_element_wise(hidden_layer_gradient, hidden_layer_errors)

	hidden_layer_gradient = Matrix.multiply_matrix_by_scalar(hidden_layer_gradient, learning_rate)
		
	var inputs_transposed = Matrix.tranpose_matrix(inputs)
	var weight_hidden_input_layer_deltas = Matrix.multiply_matrices(hidden_layer_gradient, inputs_transposed)	

	weights_input_hidden = Matrix.add_matrices(weights_input_hidden, weight_hidden_input_layer_deltas)

	bias_hidden = Matrix.add_matrices(bias_hidden, hidden_layer_gradient)

func predict(input_array): 
	
	var inputs = Matrix.build_matrix_from_array(input_array)
	
	var hidden_layer = Matrix.multiply_matrices(weights_input_hidden, inputs)
	hidden_layer = Matrix.add_matrices(hidden_layer, bias_hidden)
	hidden_layer = Matrix.apply_function_to_matrix(hidden_layer, activation_function)
	
	var output_layer = Matrix.multiply_matrices(weights_output_hidden, hidden_layer)
	output_layer = Matrix.add_matrices(output_layer, bias_output)
	output_layer = Matrix.apply_function_to_matrix(output_layer, activation_function)
	
	var result = Matrix.convert_matrix_to_array(output_layer)
	
	return result 
	
func store(filename:String ="res://nn.json"):
	#structure of the NN
	var my_json = {}
	my_json["structure"] = {"input_nodes": input_nodes, 
	"hidden_nodes": hidden_nodes, "output_nodes": output_nodes}
	
	my_json["weights_input_hidden"] = {"matrix_n_rows": weights_input_hidden.rows,
	"matrix_n_cols": weights_input_hidden.cols,
	"matrix_values": weights_input_hidden.convert_matrix_to_array(weights_input_hidden)
	}
	my_json["weights_output_hidden"] = {"matrix_n_rows": weights_output_hidden.rows,
	"matrix_n_cols": weights_output_hidden.cols,
	"matrix_values": weights_output_hidden.convert_matrix_to_array(weights_output_hidden)
	}
	my_json["bias_hidden"] = {"matrix_n_rows": bias_hidden.rows,
	"matrix_n_cols": bias_hidden.cols,
	"matrix_values": bias_hidden.convert_matrix_to_array(bias_hidden)
	}
	my_json["bias_output"] = {"matrix_n_rows": bias_output.rows,
	"matrix_n_cols": bias_output.cols,
	"matrix_values": bias_output.convert_matrix_to_array(bias_output)
	}
	var file = FileAccess.open(filename, FileAccess.WRITE)
	var json_string = JSON.stringify(my_json, "\t")
	file.store_string(json_string)
	file.close()
	pass

func load(filename:String ="res://nn.json"):
	var file = FileAccess.open(filename, FileAccess.READ)
	var json_string = file.get_as_text()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	if error == OK:
		var my_json = json.data
		input_nodes = my_json["structure"]["input_nodes"]
		hidden_nodes = my_json["structure"]["hidden_nodes"]
		output_nodes = my_json["structure"]["output_nodes"]
		
		weights_input_hidden.cols = my_json["weights_input_hidden"]["matrix_n_cols"]
		weights_input_hidden.rows = my_json["weights_input_hidden"]["matrix_n_rows"]
		weights_input_hidden = weights_input_hidden.build_matrix_from_array_rows_cols(
			my_json["weights_input_hidden"]["matrix_values"], 
			Matrix.new(weights_input_hidden.rows, weights_input_hidden.cols)
		)
		
		weights_output_hidden.cols = my_json["weights_output_hidden"]["matrix_n_cols"]
		weights_output_hidden.rows = my_json["weights_output_hidden"]["matrix_n_rows"]
		weights_output_hidden = weights_output_hidden.build_matrix_from_array_rows_cols(
			my_json["weights_output_hidden"]["matrix_values"],
			Matrix.new(weights_output_hidden.rows, weights_output_hidden.cols)
		)
		
		bias_hidden.cols = my_json["bias_hidden"]["matrix_n_cols"]
		bias_hidden.rows = my_json["bias_hidden"]["matrix_n_rows"]
		bias_hidden.build_matrix_from_array_rows_cols(
			my_json["bias_hidden"]["matrix_values"],
			Matrix.new(bias_hidden.rows, bias_hidden.cols)
		)
		
		bias_output.cols = my_json["bias_output"]["matrix_n_cols"]
		bias_output.rows = my_json["bias_output"]["matrix_n_rows"]
		bias_output.build_matrix_from_array_rows_cols(
			my_json["bias_output"]["matrix_values"],
			Matrix.new(bias_output.rows, bias_output.cols)
		)
		
		file.close()
		
		pass
