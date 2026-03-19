extends Node

# Event bus for decoupling systems

signal tape_loaded(program: Array)
signal step_executed(instruction: Dictionary, log_message: String)
signal automaton_moved(new_position: Vector2, new_facing: String)
signal energy_changed(new_energy: int)
signal status_changed(new_status: String)
signal acc_changed(new_acc: int)
signal ptr_changed(new_ptr: int)
signal inventory_changed(new_inventory: Array)
signal log_message(message: String)
signal tape_row_punched(row_bits: String)
signal tape_cleared()
signal tape_loaded_to_automaton(program: Array, instruction_lines: Array)
signal decode_preview_generated(decoded_lines: Array, unknown_rows: Array)
signal machine_status_changed(status: String)
signal cartridges_changed(cartridges: Array)
signal cartridge_selected(cartridge_id: String)
signal bot_loadouts_changed(bot_loadouts: Array)
signal outside_world_changed()
signal operator_state_changed(operator_state: Dictionary)
