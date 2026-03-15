extends Node

# System for energy management

func consume_energy(amount: int) -> bool:
    if GameState.automaton_energy >= amount:
        GameState.automaton_energy -= amount
        EventBus.energy_changed.emit(GameState.automaton_energy)
        return true
    return false

func recharge(amount: int):
    GameState.automaton_energy = min(GameState.automaton_energy + amount, GameState.max_energy)
    EventBus.energy_changed.emit(GameState.automaton_energy)