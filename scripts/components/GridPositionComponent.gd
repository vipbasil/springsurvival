extends Node

class_name GridPositionComponent

@export var position: Vector2 = Vector2(0,0)

func set_position(new_position: Vector2):
    position = new_position
    EventBus.automaton_moved.emit(position, GameState.automaton_facing)