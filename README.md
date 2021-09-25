# Neural Network: Neuroevolution - Godot Engine

In this example, cars are driving on a circuit. They have sensors and a neural network. At first the cars don't know how to drive. 
The cars that go the farthest are replicated together to create the next generation.

This is a form of evolutionary aglorithm used in machine learning which is useful when we don't have data at the beginning.

See also my projects :
- [godot-perceptron](https://github.com/Greaby/godot-perceptron)
- [godot-neural-network](https://github.com/Greaby/godot-neural-network)

# How to use

When we have chosen the best cars, we reproduce them to create a child.

```gdscript
var child = NeuralNetwork.reproduce(mother, father)
```

We can also create random mutations in the neural network.

```gdscript
var child = NeuralNetwork.mutate(car, funcref(self, "mutate"))
```
