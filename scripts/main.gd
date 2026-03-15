extends Node2D

const CELL_SIZE := 32.0
const STEP_INTERVAL := 0.45

@onready var automaton = $World/Automata/Automaton
@onready var grid = $World/GridMap

var _step_cooldown := 0.0

func _ready():
	EventBus.step_executed.connect(_on_step_executed)
	EventBus.automaton_moved.connect(_on_automaton_moved)
	EventBus.energy_changed.connect(_on_energy_changed)
	EventBus.status_changed.connect(_on_status_changed)
	EventBus.acc_changed.connect(_on_acc_changed)
	EventBus.ptr_changed.connect(_on_ptr_changed)

	update_automaton()
	grid.queue_redraw()

func _process(delta: float):
	if not TapeExecutionSystem.is_executing:
		_step_cooldown = 0.0
		return

	_step_cooldown -= delta
	if _step_cooldown > 0.0:
		return

	_step_cooldown = STEP_INTERVAL
	TapeExecutionSystem.execute_next_instruction()

func _on_step_executed(_instruction: Dictionary, log_message: String):
	EventBus.log_message.emit(log_message)

func _on_automaton_moved(new_position: Vector2, new_facing: String):
	automaton.position = new_position * CELL_SIZE
	automaton.facing = new_facing
	automaton.queue_redraw()
	grid.queue_redraw()

func _on_energy_changed(new_energy: int):
	automaton.spring_energy.current_energy = new_energy

func _on_status_changed(new_status: String):
	automaton.status = new_status

func _on_acc_changed(new_acc: int):
	automaton.acc = new_acc

func _on_ptr_changed(new_ptr: int):
	automaton.pointer = new_ptr

func update_automaton():
	automaton.update_from_gamestate()
	automaton.position = GameState.automaton_position * CELL_SIZE
	automaton.queue_redraw()
	grid.queue_redraw()
