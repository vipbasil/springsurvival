extends Control

@onready var text_edit: TextEdit = $TextEdit
@onready var load_button: Button = $LoadButton
@onready var run_button: Button = $RunButton
@onready var stop_button: Button = $StopButton
@onready var example_button: Button = $ExampleButton

func _ready():
	load_button.connect("pressed", Callable(self, "_on_load_pressed"))
	run_button.connect("pressed", Callable(self, "_on_run_pressed"))
	stop_button.connect("pressed", Callable(self, "_on_stop_pressed"))
	example_button.connect("pressed", Callable(self, "_on_example_pressed"))
	EventBus.decode_preview_generated.connect(_on_decode_preview_generated)

func _on_load_pressed():
	TapeExecutionSystem.is_executing = false
	var tape_string = text_edit.text
	var program = TapeDecoder.decode_tape(tape_string)
	GameState.tape_program = program
	GameState.automaton_ptr = 0
	GameState.automaton_status = "idle"
	EventBus.tape_loaded.emit(program)
	EventBus.ptr_changed.emit(GameState.automaton_ptr)
	EventBus.status_changed.emit(GameState.automaton_status)
	EventBus.log_message.emit("Tape loaded: " + str(program.size()) + " instructions")

func _on_run_pressed():
	if GameState.tape_program.is_empty():
		EventBus.log_message.emit("No tape loaded")
		return
	TapeExecutionSystem.start_execution()
	EventBus.log_message.emit("Execution started")

func _on_stop_pressed():
	TapeExecutionSystem.halt("Stopped by user")

func _on_example_pressed():
	text_edit.text = "SET 3\nOUT\nDEC\nJNZ 1\nDIE"

func _on_decode_preview_generated(decoded_lines: Array, unknown_rows: Array):
	if decoded_lines.is_empty() or not unknown_rows.is_empty():
		return

	var lines := PackedStringArray()
	for line in decoded_lines:
		lines.append(str(line))
	text_edit.text = "\n".join(lines)
