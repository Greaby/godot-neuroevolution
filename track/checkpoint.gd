extends Area2D

var order = 0
var reward = 200
var registered_cars = []

const REWARD_DECREASE = 5
const BASE_REWARD = 200

func reset():
	reward = BASE_REWARD

func is_at_step(body: Node) -> bool:
	return body.checkpoints == order

func _on_Checkpoint_body_entered(body: Node) -> void:
	if not body.is_in_group("car"):
		return

	if is_at_step(body) and not registered_cars.has(body):

		body.fitness += reward
		body.checkpoints += 1
		reward -= REWARD_DECREASE
		registered_cars.push_back(body)
