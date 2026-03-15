extends Control

# Automaton status panel

@onready var status_label: Label = $StatusLabel
@onready var acc_label: Label = $AccLabel
@onready var ptr_label: Label = $PtrLabel
@onready var facing_label: Label = $FacingLabel
@onready var energy_label: Label = $EnergyLabel
@onready var position_label: Label = $PositionLabel
@onready var inventory_label: Label = $InventoryLabel

func _ready():
    EventBus.status_changed.connect(_on_status_changed)
    EventBus.acc_changed.connect(_on_acc_changed)
    EventBus.ptr_changed.connect(_on_ptr_changed)
    EventBus.automaton_moved.connect(_on_automaton_moved)
    EventBus.energy_changed.connect(_on_energy_changed)
    EventBus.inventory_changed.connect(_on_inventory_changed)
    update_ui()

func _on_status_changed(new_status):
    status_label.text = "Status: " + new_status

func _on_acc_changed(new_acc):
    acc_label.text = "ACC: " + str(new_acc)

func _on_ptr_changed(new_ptr):
    ptr_label.text = "PTR: " + str(new_ptr)

func _on_automaton_moved(new_position, new_facing):
    facing_label.text = "Facing: " + new_facing
    position_label.text = "Position: (" + str(new_position.x) + "," + str(new_position.y) + ")"

func _on_energy_changed(new_energy):
    energy_label.text = "Energy: " + str(new_energy)

func _on_inventory_changed(new_inventory):
    inventory_label.text = "Inventory: " + str(new_inventory.size()) + " items"

func update_ui():
    status_label.text = "Status: " + GameState.automaton_status
    acc_label.text = "ACC: " + str(GameState.automaton_acc)
    ptr_label.text = "PTR: " + str(GameState.automaton_ptr)
    facing_label.text = "Facing: " + GameState.automaton_facing
    energy_label.text = "Energy: " + str(GameState.automaton_energy)
    position_label.text = "Position: (" + str(GameState.automaton_position.x) + "," + str(GameState.automaton_position.y) + ")"
    inventory_label.text = "Inventory: " + str(GameState.inventory.size()) + " items"