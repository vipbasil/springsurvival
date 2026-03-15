# Last Spring

A Godot 4.x 2D prototype for a mechanical programming survival game.

## Purpose

"Last Spring" is a systems-driven post-electronic survival prototype about mechanical programming. Players program a wind-up automaton using punch-tape instructions to navigate a grid world, manage spring energy, and perform tasks in a zero-waste shelter simulation.

## Scene Structure

- `scenes/main/Main.tscn`: Startup scene with world, automaton, systems, and UI.
- `scenes/world/`: World container and grid map.
- `scenes/automata/`: Automaton entity with components.
- `scenes/machines/`: Punch machine UI/mechanical programmer.
- `scenes/ui/`: Tape editor, automaton status, and log panels.

## Script Structure

- `scripts/core/`: EventBus (signals), GameState (global data), WorldObject (base).
- `scripts/components/`: SpringEnergyComponent, TapeProgramComponent, GridPositionComponent, InventoryComponent.
- `scripts/systems/`: TapeExecutionSystem (execution logic), AutomatonSystem (actions), EnergySystem (energy).
- `scripts/automata/`: Automaton.gd (entity script).
- `scripts/machines/`: PunchMachine.gd (visual 5-channel tape puncher).
- `scripts/ui/`: Panel scripts for UI interaction.
- `scripts/world/`: World.gd, GridMap.gd.
- `scripts/data/`: InstructionLibrary.gd (instruction definitions), TapeDecoder.gd (parsing), PunchEncoding.gd (5-bit row map).

## Tape Execution

Tape programs are entered as mnemonics (e.g., "MOV", "JMP 5") in the TapeEditorPanel. The TapeDecoder parses them into structured instructions. TapeExecutionSystem executes one instruction per step, advancing the pointer, consuming energy, and emitting logs. Execution halts on DIE or end of tape.

## Punch Machine

`PunchMachine.tscn` provides a visual 5-channel punch-tape composer alongside the text editor. Each punched tape row is a 5-bit slice such as `10100`, rendered across the tape width and fed longitudinally through a simple mechanical viewport. The machine uses `PunchEncoding.gd` to map 5-bit rows to prototype instructions such as `MOV`, `ROT 1`, `ROT -1`, `CMP 3`, `JNZ 1`, and `DIE`, then routes the decoded program through the existing `TapeDecoder` and automaton loading path.

## Next Steps

- Expand grid with obstacles and resources.
- Introduce stealth/detection mechanics.
- Develop zero-waste production chains.
