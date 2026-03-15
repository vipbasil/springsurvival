extends Node

func decode_tape(tape_string: String) -> Array:
    var program: Array = []
    var lines = tape_string.split("\n")
    var line_num = 0
    for line in lines:
        line_num += 1
        line = line.strip_edges()
        if line == "":
            continue
        var parts = line.split(" ", false)
        if parts.size() == 0:
            continue
        var instr_name = parts[0].to_upper()
        if not InstructionLibrary.INSTRUCTIONS.has(instr_name):
            EventBus.log_message.emit("Invalid instruction: " + instr_name + " at line " + str(line_num))
            continue

        var instr: Dictionary = InstructionLibrary.INSTRUCTIONS[instr_name].duplicate(true)
        instr["name"] = instr_name
        instr["line"] = line_num
        if int(instr["args"]) > 0:
            if parts.size() < 2:
                EventBus.log_message.emit("Missing argument for " + instr_name + " at line " + str(line_num))
                continue
            instr["arg"] = parts[1].to_int()
        else:
            instr["arg"] = 0

        program.append(instr)
    return program
