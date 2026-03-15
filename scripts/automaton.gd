extends Node2D

# Automaton

func _ready():
    position = GameState.automaton_position * 32

func _draw():
    draw_circle(Vector2(16,16), 10, Color.BLUE)
    # Facing arrow
    var dir = AutomatonSystem.get_direction_vector(GameState.automaton_facing) * 10
    draw_line(Vector2(16,16), Vector2(16,16) + dir, Color.RED, 2)