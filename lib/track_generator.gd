## 2D Track generator
##
## Generates a 2D circuit procedurally. The circuit is returned as an array of 
## Vector2 positions.
class_name TrackGenerator
extends Node

signal generation_started
signal generation_canceled
signal generation_finished(track)

enum TileTypes {
	EMPTY = -1, 
	USED = 0,
	LOCKED = 1
}

export (Rect2) var area := Rect2(Vector2(0,0), Vector2(16, 9))
export (bool) var debug := false
export var debug_map := NodePath()
export (float, 0.0, 1.0) var debug_delay := 0.1
export (int, 0, 10) var line_priority := 0
export (int) var track_min_length := 15
export (int) var track_max_length := 80

var current_position :Vector2
var map :TileMap
var in_progress := false
var stop_generation := false
var track := []


func _ready() -> void:
	if debug and not debug_map.is_empty():
		map = get_node(debug_map)
	else:
		map = TileMap.new()


func generate() -> Array:
	emit_signal("generation_started")
	
	map.clear()
	track = []
	stop_generation = false
	in_progress = true
	
	# Generates the start and ensures that it is on a straight line
	current_position = Vector2(randi() % int(area.size.x - 2) + 1, randi() % int(area.size.y - 2) + 1)
	track.push_back(current_position)
	map.set_cellv(current_position, TileTypes.USED)
	
	var direction = get_random_direction()
	var end_position :Vector2 = current_position - direction
	
	current_position += direction
	track.push_back(current_position)
	map.set_cellv(current_position, TileTypes.USED)

	# generate track
	while current_position != end_position:
		direction = get_random_direction(direction)
		current_position += direction
		track.push_back(current_position)
		map.set_cellv(current_position, TileTypes.USED)
		
		if stop_generation:
			in_progress = false
			emit_signal("generation_canceled")
			return track
		
		if debug:
			yield(get_tree().create_timer(debug_delay), "timeout")

	if track.size() < track_min_length or track.size() > track_max_length:
		return generate()
	
	map.clear()
	in_progress = false
	emit_signal("generation_finished", track)
	return track


func get_random_direction(previous_direction: Vector2 = Vector2.ZERO) -> Vector2:
	var position = track.back()
	var directions := get_valid_directions(position, previous_direction)
	
	if directions.empty():
		current_position = rollback()
		return get_random_direction(previous_direction)
	
	return directions[randi() % directions.size()]


func get_valid_directions(position: Vector2, previous_direction: Vector2 = Vector2.ZERO) -> Array:
	var valid_directions := []

	# Test the 4 directions
	for direction in [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]:
		if is_direction_valid(position, direction):
			valid_directions.push_back(direction)
	
	# Test the previous direction for straight line priority
	if previous_direction != Vector2.ZERO and line_priority != 0:
		if is_direction_valid(position, previous_direction):
			for _i in line_priority:
				valid_directions.push_back(previous_direction)
	
	return valid_directions


func is_direction_valid(position: Vector2, direction: Vector2) -> bool:
	var test_position = position + direction
	return map.get_cellv(test_position) == TileTypes.EMPTY and area.has_point(test_position)


func rollback() -> Vector2:
	var position = track.pop_back()
	map.set_cellv(current_position, TileTypes.LOCKED)
	return track.back()


func stop() -> void:
	if in_progress:
		stop_generation = true
		yield(self, "generation_canceled")
