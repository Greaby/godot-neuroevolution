extends CharacterBody2D

signal kill

@export var max_speed: float = 400.0
@export var acceleration_force: int = 15
@export var friction_force: float = .1
@export var rotation_speed: float = 90

var input_nodes = 8
var hidden_nodes = 17
var output_nodes = 3

var checkpoints = 0

var fitness: float = 0
var last_fitness: float = 0

var nn: NeuralNetwork


func _ready() -> void:
	nn = NeuralNetwork.new(input_nodes, hidden_nodes, output_nodes)


func _process(delta: float) -> void:
	check_idle()

	fitness += delta

	var inputs = nn.predict([
		get_distance($Raycasts/Left),
		get_distance($Raycasts/UpLeft),
		get_distance($Raycasts/UpLeft2),
		get_distance($Raycasts/Up),
		get_distance($Raycasts/UpRight),
		get_distance($Raycasts/UpRight2),
		get_distance($Raycasts/Right),
		velocity.length() / max_speed
	])

	var left_pressed: bool = inputs[0] > 0.5
	var up_pressed: bool = inputs[1] > 0.5
	var right_pressed: bool = inputs[2] > 0.5

	# move
	if not up_pressed:
		velocity = velocity.lerp(Vector2(), friction_force)

	velocity += Vector2(acceleration_force * inputs[1], 0).rotated(rotation)

	# turn
	var wheels = inputs[2] - inputs[0]
	velocity += Vector2(0, wheels).rotated(rotation) * rotation_speed

	set_velocity(velocity.limit_length(max_speed))
	move_and_slide()

	if get_slide_collision_count() > 0:
		fitness -= 50
		emit_signal("kill", self)

	rotation = velocity.angle()


func check_idle():
	if fitness - last_fitness > 1 :
		$IdleTimer.start()

	last_fitness = fitness


func _on_IdleTimer_timeout() -> void:
	emit_signal("kill", self)


func get_distance(raycast: RayCast2D) -> float:
	var distance: float = 1.0
	if raycast.is_colliding():
		var raycast_length: float = raycast.target_position.y
		var origin: Vector2 = raycast.global_transform.get_origin()
		var collision: Vector2 = raycast.get_collision_point()
		distance = origin.distance_to(collision) / raycast_length

	return distance
