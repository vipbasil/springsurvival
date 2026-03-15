extends Node

class_name SpringEnergyComponent

@export var current_energy: int = 100
@export var max_energy: int = 100
@export var energy_per_move: int = 5
@export var energy_per_action: int = 2

func set_energy(new_energy: int):
    current_energy = clamp(new_energy, 0, max_energy)
    EventBus.energy_changed.emit(current_energy)

func consume_energy(amount: int) -> bool:
    if current_energy >= amount:
        set_energy(current_energy - amount)
        return true
    return false

func recharge(amount: int):
    set_energy(current_energy + amount)