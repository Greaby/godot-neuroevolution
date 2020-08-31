extends Area2D

var order = 1

const BASE_REWARD = 200

var reward = 200

var registered_cars = []

func reset():
	reward = BASE_REWARD


func _on_Checkpoint_body_entered(body: Node) -> void:
	if body.checkpoints == order - 1:
		body.fitness += reward
		body.checkpoints += 1
		reward -= 5
		registered_cars.push_back(body)
			
	
