extends Node

const START_POSITION := Vector2(5, 5)
const START_FACING := "north"

var automaton_position: Vector2 = START_POSITION
var automaton_facing: String = START_FACING
var automaton_energy: int = 100
var automaton_acc: int = 0
var automaton_ptr: int = 0
var automaton_status: String = "idle"
var tape_program: Array = []
var inventory: Array = []
var trail_positions: Array = [START_POSITION]
var grid_size: Vector2 = Vector2(11,11)
var max_energy: int = 100
var energy_per_move: int = 5
var energy_per_action: int = 2

func set_automaton_position(new_position: Vector2):
	automaton_position = new_position
	if trail_positions.is_empty() or trail_positions[-1] != new_position:
		trail_positions.append(new_position)

func reset_trail():
	trail_positions = [automaton_position]
