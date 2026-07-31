extends Node2D

const TILE_IDS := {
	"vertical": 0,
	"horizontal": 0,
	"down_right": 1,
	"down_left": 1,
	"up_right": 1,
	"up_left": 1,
	"start_vertical": 6,
	"start_horizontal": 6,
}
const TILE_ALTERNATIVES := {
	"horizontal": 5,
	"down_right": 0,
	"down_left": 5,
	"up_right": 6,
	"up_left": 3,
	"start_horizontal": 5,
}

const SELECTED_COUNT = 6

@export var car_ressource: PackedScene

var cars = []
var generation = 0
var total_checkpoints = 0

@onready var checkpoint_container := $Checkpoints
@onready var track_generator := $TrackGenerator
@onready var track_map := $Track
@onready var spawner := $CarSpawner
@onready var camera := $Camera2D


func _ready() -> void:
	randomize()
	track_generator.connect("generation_finished", Callable(self, "_on_track_generated"))
	track_generator.generate()


func _on_track_generated(track: Array) -> void:
	reset_track()
	create_road(track)
	create_checkpoints(track)
	set_spawn(track)
	center_camera(track)
	respawn()


func center_camera(track: Array) -> void:
	var min_position: Vector2 = track[0]
	var max_position: Vector2 = track[0]

	for track_position in track:
		min_position = min_position.min(track_position)
		max_position = max_position.max(track_position)

	var tile_size := Vector2(track_map.tile_set.tile_size) * 2
	camera.global_position = (min_position + max_position) / 2 * tile_size


func reset_track() -> void:
	track_map.clear()
	for checkpoint in checkpoint_container.get_children():
		checkpoint.queue_free()


func create_road(track: Array) -> void:
	for index in track.size():
		var track_position = track[index]

		var next_direction = track_position.direction_to(track[(index + 1) % track.size()])
		var prev_direction = track_position.direction_to(track[index - 1])

		match [index, prev_direction, next_direction]:
			[0, Vector2.UP, _], [0, Vector2.DOWN, _]:
				track_map.set_cell(0, Vector2i(track_position), TILE_IDS.start_vertical, Vector2i.ZERO)
			[0, Vector2.RIGHT, _], [0, Vector2.LEFT, _]:
				track_map.set_cell(0, Vector2i(track_position), TILE_IDS.start_horizontal, Vector2i.ZERO, TILE_ALTERNATIVES.start_horizontal)
			[_, Vector2.UP, Vector2.RIGHT], [_, Vector2.RIGHT, Vector2.UP]:
				track_map.set_cell(0, Vector2i(track_position), TILE_IDS.up_right, Vector2i.ZERO, TILE_ALTERNATIVES.up_right)
			[_, Vector2.UP, Vector2.DOWN], [_, Vector2.DOWN, Vector2.UP]:
				track_map.set_cell(0, Vector2i(track_position), TILE_IDS.vertical, Vector2i.ZERO)
			[_, Vector2.UP, Vector2.LEFT], [_, Vector2.LEFT, Vector2.UP]:
				track_map.set_cell(0, Vector2i(track_position), TILE_IDS.up_left, Vector2i.ZERO, TILE_ALTERNATIVES.up_left)
			[_, Vector2.RIGHT, Vector2.DOWN], [_, Vector2.DOWN, Vector2.RIGHT]:
				track_map.set_cell(0, Vector2i(track_position), TILE_IDS.down_right, Vector2i.ZERO, TILE_ALTERNATIVES.down_right)
			[_, Vector2.RIGHT, Vector2.LEFT], [_, Vector2.LEFT, Vector2.RIGHT]:
				track_map.set_cell(0, Vector2i(track_position), TILE_IDS.horizontal, Vector2i.ZERO, TILE_ALTERNATIVES.horizontal)
			[_, Vector2.DOWN, Vector2.LEFT], [_, Vector2.LEFT, Vector2.DOWN]:
				track_map.set_cell(0, Vector2i(track_position), TILE_IDS.down_left, Vector2i.ZERO, TILE_ALTERNATIVES.down_left)


func create_checkpoints(track: Array) -> void:
	var index = 0
	for position in track:
		var checkpoint_scene = load("res://track/checkpoint.tscn").instantiate()
		checkpoint_scene.position = position * Vector2(track_map.tile_set.tile_size) * 2
		checkpoint_scene.order = index
		checkpoint_container.add_child(checkpoint_scene)

		index += 1

	total_checkpoints = index


func set_spawn(track: Array) -> void:
	spawner.global_position = track[0] * Vector2(track_map.tile_set.tile_size) * 2 + Vector2(track_map.tile_set.tile_size)
	spawner.direction = track[1] - track[0]

	for i in range(20):
		spawn_car()


func reset_checkpoints():
	for checkpoint in $Checkpoints.get_children():
		checkpoint.reset()


func spawn_car(nn = null) -> void:
	var car = car_ressource.instantiate()

	car.connect("kill", Callable(self, "kill"))
	car.rotation = spawner.direction.angle()
	spawner.add_child(car)
	if nn:
		car.nn = nn


func respawn():
	reset_checkpoints()
	if cars.size() == 0:
		return

	cars.sort_custom(Callable(self, "sort_best"))

	var nns = []
	for i in range(min(SELECTED_COUNT, cars.size())):
		nns.push_back(cars[i][1])
	nns.push_back(NeuralNetwork.new(8, 17, 3))

	for i in range(nns.size() * 3):
		var mother = nns[randi() % nns.size()]
		var father = nns[randi() % nns.size()]

		nns.push_back(NeuralNetwork.reproduce(mother, father))

	for i in range(nns.size()):
		var nn = nns[randi() % nns.size()]
		nns.push_back(NeuralNetwork.mutate(nn, Callable(self, "mutate")))

	for nn in nns:
		spawn_car(nn)

	cars = []


func mutate(value, row, col):
	if randf_range(0, 1) < 0.1:
		value += randf_range(-0.5, 0.5)

	return value


func count_finished_cars() -> int:
	var count = 0
	for car in spawner.get_children():
		if car.checkpoints >= total_checkpoints:
			count += 1

	return count


func next_generation() -> void:
	generation += 1
	if generation >= 10:
		generation = 0
		track_generator.generate()
		return

	respawn()


func _process(delta: float) -> void:
	if spawner.get_child_count() == 0:
		next_generation()
		return

	if count_finished_cars() >= SELECTED_COUNT:
		for car in spawner.get_children():
			kill(car)

		next_generation()


func kill(car) -> void:
	cars.push_back([car.fitness, NeuralNetwork.copy(car.nn)])
	car.queue_free()


func sort_best(a, b) -> bool:
	return a[0] > b[0]
