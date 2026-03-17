extends Node2D

const CELL_SIZE := 32.0
const STEP_INTERVAL := 0.45
const WORKSHOP_SCENE_PATH := "res://scenes/main/Main.tscn"

@onready var automaton = $World/Automata/Automaton
@onready var grid = $World/GridMap
@onready var back_button: Button = get_node_or_null("UI/BackToWorkshopButton")
@onready var punch_machine = get_node_or_null("UI/PunchMachine")
@onready var save_cartridge_dialog: ConfirmationDialog = get_node_or_null("UI/SaveCartridgeDialog")
@onready var cartridge_label_edit: LineEdit = get_node_or_null("UI/SaveCartridgeDialog/DialogVBox/CartridgeLabelEdit")

var _step_cooldown := 0.0

func _ready():
	EventBus.step_executed.connect(_on_step_executed)
	EventBus.automaton_moved.connect(_on_automaton_moved)
	EventBus.energy_changed.connect(_on_energy_changed)
	EventBus.status_changed.connect(_on_status_changed)
	EventBus.acc_changed.connect(_on_acc_changed)
	EventBus.ptr_changed.connect(_on_ptr_changed)
	if back_button:
		back_button.pressed.connect(_on_back_to_workshop_pressed)
	if save_cartridge_dialog:
		save_cartridge_dialog.confirmed.connect(_on_save_cartridge_confirmed)
		save_cartridge_dialog.close_requested.connect(_on_save_cartridge_canceled)

	update_automaton()
	grid.queue_redraw()

func _process(delta: float):
	if not TapeExecutionSystem.is_executing:
		_step_cooldown = 0.0
		return

	_step_cooldown -= delta
	if _step_cooldown > 0.0:
		return

	_step_cooldown = STEP_INTERVAL
	TapeExecutionSystem.execute_next_instruction()

func _on_step_executed(_instruction: Dictionary, log_message: String):
	EventBus.log_message.emit(log_message)

func _on_automaton_moved(new_position: Vector2, new_facing: String):
	automaton.position = new_position * CELL_SIZE
	automaton.facing = new_facing
	automaton.queue_redraw()
	grid.queue_redraw()

func _on_energy_changed(new_energy: int):
	automaton.spring_energy.current_energy = new_energy

func _on_status_changed(new_status: String):
	automaton.status = new_status

func _on_acc_changed(new_acc: int):
	automaton.acc = new_acc

func _on_ptr_changed(new_ptr: int):
	automaton.pointer = new_ptr

func update_automaton():
	automaton.update_from_gamestate()
	automaton.position = GameState.automaton_position * CELL_SIZE
	automaton.queue_redraw()
	grid.queue_redraw()

func _on_back_to_workshop_pressed():
	if punch_machine and punch_machine.has_method("has_punched_tape") and punch_machine.has_punched_tape():
		_open_save_cartridge_dialog()
		return
	get_tree().change_scene_to_file(WORKSHOP_SCENE_PATH)

func _open_save_cartridge_dialog():
	if save_cartridge_dialog == null or cartridge_label_edit == null:
		get_tree().change_scene_to_file(WORKSHOP_SCENE_PATH)
		return

	cartridge_label_edit.text = GameState.get_default_cartridge_label()
	save_cartridge_dialog.popup_centered()
	cartridge_label_edit.grab_focus()
	cartridge_label_edit.select_all()

func _on_save_cartridge_confirmed():
	if punch_machine == null or not punch_machine.has_method("get_tape_rows_copy"):
		get_tree().change_scene_to_file(WORKSHOP_SCENE_PATH)
		return

	var label := cartridge_label_edit.text if cartridge_label_edit else ""
	var rows: Array = punch_machine.get_tape_rows_copy()
	if not rows.is_empty():
		var cartridge := GameState.save_programmed_cartridge(label, rows)
		if cartridge.is_empty():
			EventBus.log_message.emit("Cannot save cartridge: no blank stock or no free programmed slot")
			if save_cartridge_dialog:
				save_cartridge_dialog.hide()
			return
		EventBus.log_message.emit("Cartridge saved: " + str(cartridge.get("label", "")))
	get_tree().change_scene_to_file(WORKSHOP_SCENE_PATH)

func _on_save_cartridge_canceled():
	if save_cartridge_dialog:
		save_cartridge_dialog.hide()
