## Neural network
##
## It is a basic neural network with three layers (input, hidden and output).
## The network is randomly initialized, and evolves through reproduction and
## mutation rather than backpropagation.
class_name NeuralNetwork

var input_nodes: int
var hidden_nodes: int
var output_nodes: int

var weights_input_hidden: Matrix
var weights_hidden_output: Matrix

var bias_hidden: Matrix
var bias_output: Matrix

var learning_rate: float

var activation_function: Callable

func _init(_input_nodes: int, _hidden_nodes: int, _output_nodes: int, _randomize := true) -> void:
	input_nodes = _input_nodes;
	hidden_nodes = _hidden_nodes;
	output_nodes = _output_nodes;

	set_learning_rate()
	set_activation_function()

	if not _randomize:
		return

	weights_input_hidden = Matrix.rand(Matrix.new(hidden_nodes, input_nodes))
	weights_hidden_output = Matrix.rand(Matrix.new(output_nodes, hidden_nodes));

	bias_hidden = Matrix.rand(Matrix.new(hidden_nodes, 1));
	bias_output = Matrix.rand(Matrix.new(output_nodes, 1));


func set_learning_rate(_learning_rate: float = 0.1) -> void:
	learning_rate = _learning_rate

func set_activation_function(callback: Callable = Callable(Activation, "sigmoid")) -> void:
	activation_function = callback

func predict(input_array: Array) -> Array:
	var inputs = Matrix.from_array(input_array)

	var hidden = Matrix.product(weights_input_hidden, inputs)
	hidden = Matrix.add(hidden, bias_hidden)
	hidden = Matrix.map(hidden, activation_function)

	var output = Matrix.product(weights_hidden_output, hidden)
	output = Matrix.add(output, bias_output)
	output = Matrix.map(output, activation_function)

	return Matrix.to_array(output)


static func reproduce(a: NeuralNetwork, b: NeuralNetwork) -> NeuralNetwork:
	var result = NeuralNetwork.new(a.input_nodes, a.hidden_nodes, a.output_nodes, false)

	result.weights_input_hidden = Matrix.random(a.weights_input_hidden, b.weights_input_hidden)
	result.weights_hidden_output = Matrix.random(a.weights_hidden_output, b.weights_hidden_output)
	result.bias_hidden = Matrix.random(a.bias_hidden, b.bias_hidden)
	result.bias_output = Matrix.random(a.bias_output, b.bias_output)

	return result


static func mutate(neural_network: NeuralNetwork, callback: Callable) -> NeuralNetwork:
	var result = NeuralNetwork.new(neural_network.input_nodes, neural_network.hidden_nodes, neural_network.output_nodes, false)
	result.weights_input_hidden = Matrix.map(neural_network.weights_input_hidden, callback)
	result.weights_hidden_output = Matrix.map(neural_network.weights_hidden_output, callback)
	result.bias_hidden = Matrix.map(neural_network.bias_hidden, callback)
	result.bias_output = Matrix.map(neural_network.bias_output, callback)
	return result


static func copy(neural_network : NeuralNetwork) -> NeuralNetwork:
	var result = NeuralNetwork.new(neural_network.input_nodes, neural_network.hidden_nodes, neural_network.output_nodes, false)
	result.weights_input_hidden = Matrix.copy(neural_network.weights_input_hidden)
	result.weights_hidden_output = Matrix.copy(neural_network.weights_hidden_output)
	result.bias_hidden = Matrix.copy(neural_network.bias_hidden)
	result.bias_output = Matrix.copy(neural_network.bias_output)
	return result
