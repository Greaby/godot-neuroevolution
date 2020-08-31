extends Node2D

export (String, FILE) var car_ressource


var cars = [
	
]


func _ready() -> void:
	set_checkpoints()
	init_gerenation()
	
func set_checkpoints():
	var i = 1
	for checkpoint in $Checkpoints.get_children():
		checkpoint.order = i
		checkpoint.reset()
		i += 1

func init_gerenation() -> void:
	for i in range(20):
		var car = load(car_ressource).instance()
		car.connect("kill", self, "kill")
		$CarSpawner.add_child(car)

func spawn_car(nn) -> void:
	var car = load(car_ressource).instance()
	
	car.connect("kill", self, "kill")
	$CarSpawner.add_child(car)
	car.nn = nn

func respawn():
	print_stray_nodes()
	set_checkpoints()
	
	cars.sort_custom(self, "sort_best")
	
	
	var nns = [
		cars[0][1],
		cars[1][1],
		cars[2][1],
		cars[3][1],
		NeuralNetwork.new(15, 31, 3)
	]
	
	for i in range(nns.size() * 2):
		var mother = nns[randi() % nns.size()]
		var father = nns[randi() % nns.size()]
		
		nns.push_back(NeuralNetwork.reproduce(mother, father))

	for i in range(nns.size()):
		var nn = nns[randi() % nns.size()]
		nns.push_back(NeuralNetwork.mutate(nn, funcref(self, "mutate")))
		
	for nn in nns:
		spawn_car(nn)

	cars = []

func mutate(value, row, col):
	if rand_range(0, 1) < 0.1:
		value += rand_range(-0.5, 0.5)
		
	return value
	
func _process(delta: float) -> void:
	if $CarSpawner.get_child_count() == 0:
		respawn()

func kill(car) -> void:
	cars.push_back([car.fitness, NeuralNetwork.copy(car.nn)])
	car.queue_free()

func sort_best(a, b) -> bool:
	return a[0] > b[0]
	
