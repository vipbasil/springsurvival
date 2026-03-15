extends Node2D

const CELL_SIZE := 32.0
const BACKGROUND_COLOR := Color(0.10, 0.11, 0.13)
const GRID_COLOR := Color(0.42, 0.44, 0.48, 0.9)
const TRAIL_COLOR := Color(0.78, 0.62, 0.24, 0.8)

func _ready():
    queue_redraw()

func _draw():
    var size = GameState.grid_size
    draw_rect(Rect2(Vector2.ZERO, size * CELL_SIZE), BACKGROUND_COLOR)
    _draw_trail()

    for x in range(int(size.x) + 1):
        draw_line(Vector2(x * CELL_SIZE, 0), Vector2(x * CELL_SIZE, size.y * CELL_SIZE), GRID_COLOR, 1.0)
    for y in range(int(size.y) + 1):
        draw_line(Vector2(0, y * CELL_SIZE), Vector2(size.x * CELL_SIZE, y * CELL_SIZE), GRID_COLOR, 1.0)

func _draw_trail():
    if GameState.trail_positions.is_empty():
        return

    var cell_center = Vector2.ONE * (CELL_SIZE * 0.5)
    for trail_position in GameState.trail_positions:
        draw_rect(
            Rect2(trail_position * CELL_SIZE + Vector2(10, 10), Vector2(12, 12)),
            TRAIL_COLOR
        )

    for index in range(GameState.trail_positions.size() - 1):
        var from_position = GameState.trail_positions[index] * CELL_SIZE + cell_center
        var to_position = GameState.trail_positions[index + 1] * CELL_SIZE + cell_center
        draw_line(from_position, to_position, TRAIL_COLOR, 3.0)
