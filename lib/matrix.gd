## Matrix calculations.
##
## This class allows to perform all the basic operations with matrices.
## (add, sub, multiply, scalar, dot product)
## It is also possible to import and export matrices from an array.
class_name Matrix

var rows: int
var cols: int

var data = []


func _init(_rows: int, _cols: int, value: float = 0.0) -> void:
	randomize()
	rows = _rows
	cols = _cols
	for row in range(rows):
		data.insert(row , [])
		for col in range(cols):
			data[row].insert(col, value)


# workaround issue #21461
static func getClass():
	return load("res://lib/matrix.gd")


static func from_array(arr: Array) -> Matrix:
	var result = getClass().new(arr.size(), 1)
	for row in range(result.rows):
		result.data[row][0] = arr[row]

	return result


static func to_array(matrix: Matrix) -> Array:
	var result = []
	for row in range(matrix.rows):
		for col in range(matrix.cols):
			result.append(matrix.data[row][col])
	  
	return result


static func rand(matrix: Matrix) -> Matrix:
	randomize()
	
	var result = getClass().new(matrix.rows, matrix.cols)
	
	for row in range(result.rows):
		for col in range(result.cols):
			result.data[row][col] = rand_range(-1, 1)
	
	return result


static func add(a: Matrix, b: Matrix) -> Matrix:
	assert(a.rows == b.rows and a.cols == b.cols)
	
	var result = getClass().new(a.rows, a.cols)

	for row in range(result.rows):
		for col in range(result.cols):
			result.data[row][col] = a.data[row][col] + b.data[row][col]

	return result


static func subtract(a: Matrix, b: Matrix) -> Matrix:
	assert(a.rows == b.rows and a.cols == b.cols)

	var result = getClass().new(a.rows, a.cols)

	for row in range(result.rows):
		for col in range(result.cols):
			result.data[row][col] = a.data[row][col] - b.data[row][col]

	return result


static func scalar(matrix: Matrix, value: float) -> Matrix:
	var result = getClass().new(matrix.rows, matrix.cols)
	
	for row in range(result.rows):
		for col in range(result.cols):
			result.data[row][col] = matrix.data[row][col] * value
	
	return result


static func product(a: Matrix, b: Matrix) -> Matrix:
	assert(a.cols == b.rows)

	var result = getClass().new(a.rows, b.cols)

	for row in range(result.rows):
		for col in range(result.cols):
			result.data[row][col] = 0.0
			for k in range(a.cols):
				result.data[row][col] += a.data[row][k] * b.data[k][col]

	return result


static func multiply(a: Matrix, b: Matrix) -> Matrix:
	assert(a.rows == b.rows and a.cols == b.cols)
	
	var result = getClass().new(a.rows, a.cols)
	
	for row in range(result.rows):
		for col in range(result.cols):
			result.data[row][col] = a.data[row][col] * b.data[row][col]
	
	return result


static func random(a: Matrix, b: Matrix) -> Matrix:
	var result = getClass().new(a.rows, a.cols)
	for row in range(result.rows):
		for col in range(result.cols):
			var random = rand_range(0, 1)
			result.data[row][col] = a.data[row][col] if random > 0.5 else b.data[row][col]
	
	return result


static func transpose(matrix: Matrix) -> Matrix:
	var result = getClass().new(matrix.cols, matrix.rows)

	for row in range(result.rows):
		for col in range(result.cols):
			result.data[row][col] = matrix.data[col][row]

	return result


static func copy(matrix: Matrix) -> Matrix:
	var result = getClass().new(matrix.rows, matrix.cols)
	for row in range(result.rows):
		for col in range(result.cols):
			result.data[row][col] = matrix.data[row][col]
	return result


static func map(matrix: Matrix, callback) -> Matrix:
	var result = getClass().new(matrix.rows, matrix.cols)
	
	for row in range(result.rows):
		for col in range(result.cols):
			result.data[row][col] = callback.call_func(matrix.data[row][col], row, col)

	return result
