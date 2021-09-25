class_name Activation


static func sigmoid(value: float, row: int, col: int) -> float:
	return 1 / (1 + exp(-value))


static func dsigmoid(value: float, row: int, col: int) -> float:
	return value * (1 - value)
