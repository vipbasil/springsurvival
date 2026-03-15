extends Node2D

# Grid world

func _draw():
    var size = GameState.grid_size
    for x in range(size.x + 1):
        draw_line(Vector2(x * 32, 0), Vector2(x * 32, size.y * 32), Color.WHITE, 1)
    for y in range(size.y + 1):
        draw_line(Vector2(0, y * 32), Vector2(size.x * 32, y * 32), Color.WHITE, 1)