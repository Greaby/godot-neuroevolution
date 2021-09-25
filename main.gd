extends Node2D

export (String, FILE) var car_ressource

var cars = []
var generation = 0

onready var checkpoint_container := $Checkpoints
onready var track_generator := $TrackGenerator
onready var track_map := $Track
onready var spawner := $CarSpawner


func _ready() -> void:
	randomize()
	track_generator.connect("generation_finished", self, "_on_track_generated")
	track_generator.generate()


func _on_track_generated(track: Array) -> void:
	reset_track()
	create_road(track)
	create_checkpoints(track)
	set_spawn(track)
	respawn()


func reset_track() -> void:
	track_map.clear()
	for checkpoint in checkpoint_container.get_children():
		checkpoint.queue_free()


func create_road(track: Array) -> void:
	for index in track.size():
		var position = track[index]
		
		var next_direction = position.direction_to(track[(index + 1) % track.size()])
		var prev_direction = position.direction_to(track[index - 1])

		match [index, prev_direction, next_direction]:
			[0, Vector2.UP, _], [0, Vector2.DOWN, _]:
				track_map.set_cellv(position, track_map.tile_set.find_tile_by_name("start_vertical"))
			[0, Vector2.RIGHT, _], [0, Vector2.LEFT, _]:
				track_map.set_cellv(position, track_map.tile_set.find_tile_by_name("start_horizontal"))
			[_, Vector2.UP, Vector2.RIGHT], [_, Vector2.RIGHT, Vector2.UP]:
				track_map.set_cellv(position, track_map.tile_set.find_tile_by_name("up_right"))
			[_, Vector2.UP, Vector2.DOWN], [_, Vector2.DOWN, Vector2.UP]:
				track_map.set_cellv(position, track_map.tile_set.find_tile_by_name("vertical"))
			[_, Vector2.UP, Vector2.LEFT], [_, Vector2.LEFT, Vector2.UP]:
				track_map.set_cellv(position, track_map.tile_set.find_tile_by_name("up_left"))
			[_, Vector2.RIGHT, Vector2.DOWN], [_, Vector2.DOWN, Vector2.RIGHT]:
				track_map.set_cellv(position, track_map.tile_set.find_tile_by_name("down_right"))
			[_, Vector2.RIGHT, Vector2.LEFT], [_, Vector2.LEFT, Vector2.RIGHT]:
				track_map.set_cellv(position, track_map.tile_set.find_tile_by_name("horizontal"))
			[_, Vector2.DOWN, Vector2.LEFT], [_, Vector2.LEFT, Vector2.DOWN]:
				track_map.set_cellv(position, track_map.tile_set.find_tile_by_name("down_left"))


func create_checkpoints(track: Array) -> void:
	var index = 0
	for position in track:
		var checkpoint_scene = load("res://track/checkpoint.tscn").instance()
		checkpoint_scene.position = position * track_map.cell_size * 2
		checkpoint_scene.order = index
		checkpoint_container.add_child(checkpoint_scene)
		
		index += 1


func set_spawn(track: Array) -> void:
	spawner.global_position = track[0] * track_map.cell_size * 2 + track_map.cell_size
	spawner.direction = track[1] - track[0]
	
	for i in range(20):
		spawn_car()


func reset_checkpoints():
	for checkpoint in $Checkpoints.get_children():
		checkpoint.reset()


func spawn_car(nn = null) -> void:
	var car = load(car_ressource).instance()
	
	car.connect("kill", self, "kill")
	car.rotation = spawner.direction.angle()
	spawner.add_child(car)
	if nn:
		car.nn = nn


func respawn():
	reset_checkpoints()
	if cars.size() == 0:
		return

	cars.sort_custom(self, "sort_best")
	
	var nns = [
		cars[0][1],
		cars[1][1],
		cars[2][1],
		cars[3][1],
		cars[4][1],
		cars[5][1],
		NeuralNetwork.new(8, 17, 3)
	]
	
	for i in range(nns.size() * 3):
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
	if spawner.get_child_count() == 0:
		generation += 1
		if generation >= 4:
			generation = 0
			track_generator.generate()
			return
		
		respawn()


func kill(car) -> void:
	cars.push_back([car.fitness, NeuralNetwork.copy(car.nn)])
	car.queue_free()


func sort_best(a, b) -> bool:
	return a[0] > b[0]
