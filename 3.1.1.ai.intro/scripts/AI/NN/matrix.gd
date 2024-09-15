class_name Matrix

var rows: int
var cols: int 

var data = []

func _init(_rows: int, _cols: int, value: float = 0.0):
	
	randomize()
	
	rows = _rows
	cols = _cols
	
	for row in range(rows):
		data.insert(row, [])
		
		for col in range(cols):
			data[row].insert(col, value)

static func getClass():
	return load("res://scripts/AI/NN/matrix.gd")

static func generate_random_matrix(matrix: Matrix) -> Matrix:
	
	randomize()
	
	var result = getClass().new(matrix.rows, matrix.cols)
	
	for row in range(result.rows):
		for col in range(result.cols):
			result.data[row][col] = randf_range(-1, 1)
			
	return result 

static func build_matrix_from_array_rows_cols(input: Array, matrix: Matrix) -> Matrix:
	var result = getClass().new(matrix.rows, matrix.cols)
	
	var input_index = 0
	for row in range(result.rows):
		for col in range(result.cols):
			result.data[row][col] = input[input_index]
			input_index += 1
			
	return result 

static func build_matrix_from_array(input: Array) -> Matrix:
	
	var result = getClass().new(input.size(), 1)
	
	for row in range(result.rows):
		
		result.data[row][0] = input[row]
		
	return result 

static func multiply_matrices(firstMatrix: Matrix, secondMatrix: Matrix) -> Matrix:
	
	assert(firstMatrix.cols == secondMatrix.rows)
	
	var result = getClass().new(firstMatrix.rows, secondMatrix.cols)
	
	for row in range(result.rows):
		for col in range(result.cols):
			
			result.data[row][col] = 0.0
			
			for x in range(firstMatrix.cols):
				result.data[row][col] += firstMatrix.data[row][x] * secondMatrix.data[x][col]
			
	return result 	
	
static func add_matrices(firstMatrix: Matrix, secondMatrix: Matrix) -> Matrix:
	
	assert(firstMatrix.rows == secondMatrix.rows and firstMatrix.cols == secondMatrix.cols)
	
	var result = getClass().new(firstMatrix.rows, secondMatrix.cols)
	
	for row in range(result.rows):
		for col in range(result.cols):
			
			result.data[row][col] = firstMatrix.data[row][col] + secondMatrix.data[row][col]
			
	return result 	
		
static func apply_function_to_matrix(matrix: Matrix, callback: Callable) -> Matrix:
	
	var result = getClass().new(matrix.rows, matrix.cols)
	
	for row in range(result.rows):
		for col in range(result.cols):
			
			result.data[row][col] = callback.call(matrix.data[row][col], row, col)
			
	return result 
	
static func subtract_matrices(firstMatrix: Matrix, secondMatrix: Matrix) -> Matrix:
	
	assert(firstMatrix.rows == secondMatrix.rows and firstMatrix.cols == secondMatrix.cols)
	
	var result = getClass().new(firstMatrix.rows, secondMatrix.cols)
	
	for row in range(result.rows):
		for col in range(result.cols):
			
			result.data[row][col] = firstMatrix.data[row][col] - secondMatrix.data[row][col]
			
	return result 
	
static func multiply_matrices_element_wise(firstMatrix: Matrix, secondMatrix: Matrix) -> Matrix:
	
	assert(firstMatrix.rows == secondMatrix.rows and firstMatrix.cols == secondMatrix.cols)
	
	var result = getClass().new(firstMatrix.rows, secondMatrix.cols)
	
	for row in range(result.rows):
		for col in range(result.cols):
			
			result.data[row][col] = firstMatrix.data[row][col] * secondMatrix.data[row][col]
	
	return result 	
	
static func multiply_matrix_by_scalar(matrix: Matrix, value: float) -> Matrix:
	
	var result = getClass().new(matrix.rows, matrix.cols)
	
	for row in range(result.rows):
		for col in range(result.cols):			
	
			result.data[row][col] = matrix.data[row][col] * value 
			
	return result 

static func tranpose_matrix(matrix):
	
	var result = getClass().new(matrix.cols, matrix.rows)
	
	for row in range(result.rows):
		for col in range(result.cols):
			
			result.data[row][col] = matrix.data[col][row]
			
	return result 

static func convert_matrix_to_array(matrix):
	
	var result = []

	for row in range(matrix.rows):
		for col in range(matrix.cols):

			result.append(matrix.data[row][col])
	
	return result 
