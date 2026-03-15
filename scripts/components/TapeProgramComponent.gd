extends Node

class_name TapeProgramComponent

var program: Array = []

func set_program(new_program: Array):
    program = new_program
    EventBus.tape_loaded.emit(program)