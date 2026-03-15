extends Node

# System for automaton actions

func move_forward() -> bool:
    if not EnergySystem.consume_energy(GameState.energy_per_move):
        EventBus.log_message.emit("Not enough energy to move")
        return false

    var direction = get_direction_vector(GameState.automaton_facing)
    var new_pos = GameState.automaton_position + direction
    if new_pos.x >= 0 and new_pos.x < GameState.grid_size.x and new_pos.y >= 0 and new_pos.y < GameState.grid_size.y:
        GameState.set_automaton_position(new_pos)
        EventBus.automaton_moved.emit(GameState.automaton_position, GameState.automaton_facing)
        return true
    EventBus.log_message.emit("Movement blocked at the edge of the grid")
    return false

func rotate(amount: int):
    if not EnergySystem.consume_energy(GameState.energy_per_action):
        EventBus.log_message.emit("Not enough energy to rotate")
        return

    var facings = ["north", "northeast", "east", "southeast", "south", "southwest", "west", "northwest"]
    var current_index = facings.find(GameState.automaton_facing)
    if current_index == -1:
        current_index = 0
    current_index = posmod(current_index + amount, facings.size())
    GameState.automaton_facing = facings[current_index]
    EventBus.automaton_moved.emit(GameState.automaton_position, GameState.automaton_facing)

func scan():
    if not EnergySystem.consume_energy(GameState.energy_per_action):
        EventBus.log_message.emit("Not enough energy to scan")
        return
    # Placeholder: log scan info
    EventBus.log_message.emit("Scanned: nothing found")

func pick():
    if not EnergySystem.consume_energy(GameState.energy_per_action):
        EventBus.log_message.emit("Not enough energy to pick")
        return
    # Placeholder: add item
    GameState.inventory.append("item")
    EventBus.inventory_changed.emit(GameState.inventory)

func drop():
    if not EnergySystem.consume_energy(GameState.energy_per_action):
        EventBus.log_message.emit("Not enough energy to drop")
        return
    if GameState.inventory.size() > 0:
        GameState.inventory.pop_back()
        EventBus.inventory_changed.emit(GameState.inventory)

func charge():
    EnergySystem.recharge(20)

func get_direction_vector(facing: String) -> Vector2:
    match facing:
        "north":
            return Vector2(0, -1)
        "south":
            return Vector2(0, 1)
        "east":
            return Vector2(1, 0)
        "west":
            return Vector2(-1, 0)
        "northeast":
            return Vector2(1, -1)
        "southeast":
            return Vector2(1, 1)
        "southwest":
            return Vector2(-1, 1)
        "northwest":
            return Vector2(-1, -1)
    return Vector2(0,0)
