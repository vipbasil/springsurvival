extends Node

var is_executing: bool = false

func execute_next_instruction():
    if not is_executing:
        return

    if GameState.tape_program.size() == 0 or GameState.automaton_ptr >= GameState.tape_program.size():
        halt("End of tape")
        return

    var instruction: Dictionary = GameState.tape_program[GameState.automaton_ptr]
    GameState.automaton_ptr += 1
    EventBus.ptr_changed.emit(GameState.automaton_ptr)

    var instruction_name := str(instruction.get("name", "<?>"))
    var instruction_type := str(instruction.get("type", ""))
    var instruction_arg := int(instruction.get("arg", 0))
    var log_message = "Executing " + instruction_name

    match instruction_type:
        "nop":
            pass
        "mov":
            if AutomatonSystem.move_forward():
                log_message += " - moved forward"
            else:
                log_message += " - cannot move"
        "scn":
            AutomatonSystem.scan()
            log_message += " - scanned"
        "pck":
            AutomatonSystem.pick()
            log_message += " - picked"
        "drp":
            AutomatonSystem.drop()
            log_message += " - dropped"
        "chg":
            AutomatonSystem.charge()
            log_message += " - charged"
        "jmp":
            GameState.automaton_ptr = instruction_arg
            EventBus.ptr_changed.emit(GameState.automaton_ptr)
            log_message += " - jumped to " + str(instruction_arg)
        "jnz":
            if GameState.automaton_acc != 0:
                GameState.automaton_ptr = instruction_arg
                EventBus.ptr_changed.emit(GameState.automaton_ptr)
                log_message += " - jumped to " + str(instruction_arg)
            else:
                log_message += " - no jump"
        "dec":
            GameState.automaton_acc -= 1
            EventBus.acc_changed.emit(GameState.automaton_acc)
            log_message += " - ACC now " + str(GameState.automaton_acc)
        "inc":
            GameState.automaton_acc += 1
            EventBus.acc_changed.emit(GameState.automaton_acc)
            log_message += " - ACC now " + str(GameState.automaton_acc)
        "set":
            GameState.automaton_acc = instruction_arg
            EventBus.acc_changed.emit(GameState.automaton_acc)
            log_message += " - ACC set to " + str(GameState.automaton_acc)
        "out":
            log_message += " - ACC output: " + str(GameState.automaton_acc)
        "die":
            halt("DIE executed")
            log_message += " - died"
        "rot":
            AutomatonSystem.rotate(instruction_arg)
            log_message += " - rotated " + str(instruction_arg)
        _:
            halt("Unknown instruction: " + instruction_name)
            log_message += " - unknown"

    EventBus.step_executed.emit(instruction, log_message)

func start_execution():
    if GameState.tape_program.is_empty():
        EventBus.log_message.emit("No tape loaded")
        return
    is_executing = true
    GameState.automaton_status = "running"
    EventBus.status_changed.emit("running")

func halt(reason: String):
    is_executing = false
    GameState.automaton_status = "halted"
    EventBus.status_changed.emit("halted")
    EventBus.log_message.emit("Halted: " + reason)
