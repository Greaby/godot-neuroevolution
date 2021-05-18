extends Area2D

var order = 1
var reward = 200
var registered_cars = []

const REWARD_DECREASE = 5
const BASE_REWARD = 200

func reset():
	reward = BASE_REWARD

func is_at_step(body: Node) -> bool:
	return body.checkpoints == order - 1

func _on_Checkpoint_body_entered(body: Node) -> void:
	if is_at_step(body):
		body.fitness += reward
		body.checkpoints += 1
		reward -= REWARD_DECREASE
		registered_cars.push_back(body)
