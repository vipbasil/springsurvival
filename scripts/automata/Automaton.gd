extends Node2D

@export var id: String = "automaton1"
@export var status: String = "idle"
@export var acc: int = 0
@export var pointer: int = 0
@export var facing: String = "north"

@onready var spring_energy = $SpringEnergyComponent
@onready var tape_program = $TapeProgramComponent
@onready var grid_position = $GridPositionComponent
@onready var inventory = $InventoryComponent

func _ready():
    EventBus.tape_loaded.connect(_on_tape_loaded)
    update_from_gamestate()

func update_from_gamestate():
    acc = GameState.automaton_acc
    pointer = GameState.automaton_ptr
    facing = GameState.automaton_facing
    status = GameState.automaton_status
    if grid_position:
        grid_position.position = GameState.automaton_position
    if spring_energy:
        spring_energy.current_energy = GameState.automaton_energy
    if inventory:
        inventory.items = GameState.inventory

func _draw():
    draw_circle(Vector2(16,16), 10, Color.BLUE)
    var dir = AutomatonSystem.get_direction_vector(facing) * 10
    draw_line(Vector2(16,16), Vector2(16,16) + dir, Color.RED, 2)

func _on_tape_loaded(program: Array):
    if tape_program:
        tape_program.program = program
