# Last Spring

A Godot 4.x prototype for a knowledge-driven mechanical and biological survival game.

## Purpose

"Last Spring" is a systems-driven post-electronic survival prototype about physical programming, analog drones, low-signature survival, and persistent knowledge.

The current game direction is:

- select an operator from the Ark
- enter an Earth shelter workshop
- program drones through punch-tape cartridges
- install physical power units and launch drones
- observe routes and discoveries on mechanical map displays
- preserve knowledge in a journal that survives between runs

The long-term design is built on three equal progression pillars:

- mechanical / programming knowledge
- world / cartographic knowledge
- biological / genetic knowledge

One important current architecture rule:

- all movable entities are cards
- all fixed infrastructure is machinery

More specifically for the workshop:

- drones are composite cards
- one tape card becomes a visible tape label/badge on the drone card
- one or more charged power cards add up on the drone card
- launch and recovery stay machine actions

## Where To Look

If you are continuing development, use these files as the main entry points:

- `README.md`: quick project overview, active scene/script structure, and current prototype loop
- `TODO.md`: backlog, Scrum-style ordering, done vs next work, and feature priorities
- `LORE.md`: canonical setting, fiction, Ark/Earth relationship, journal meaning, and world rules
- `GAME_ARCHITECTURE.md`: top-level product/system decisions, run structure, persistence rules, and layer separation
- `ARTSTYLE.md`: visual language, materials, mood, and UI style rules
- `DRONE_DESIGN.md`: drone design rules, visual exemplars, and future drone direction

If you want the current playable scenes:

- `scenes/main/Main.tscn`: workshop hub
- `scenes/main/ProgrammingMain.tscn`: full programming / punch-machine scene

If you want the most important gameplay state and logic:

- `scripts/core/GameState.gd`: persistent state, cartridges, power units, bot loadouts, outside-world state
- `scripts/core/EventBus.gd`: cross-scene signals
- `scripts/workshop_main.gd`: workshop rendering and interaction logic
- `scripts/main.gd`: programming-scene flow, save-on-exit, and workshop return
- `scripts/machines/PunchMachine.gd`: punch-machine behavior and tape authoring

If you want instruction / language behavior:

- `scripts/data/InstructionLibrary.gd`: canonical instruction definitions
- `scripts/data/TapeDecoder.gd`: mnemonic parsing and decode path
- `scripts/data/PunchEncoding.gd`: 5-bit keyboard / opcode labeling model
- `scripts/systems/TapeExecutionSystem.gd`: execution logic used by the automaton scene

If you want world / route-table behavior:

- `scripts/core/GameState.gd`: outside bot execution and persistent discoveries
- `scripts/workshop_main.gd`: route-table display and cabinet/workshop presentation

## Scene Structure

- `scenes/main/Main.tscn`: Startup workshop scene with programming bench, cartridge stores, drone cabinets, and route table.
- `scenes/main/ProgrammingMain.tscn`: Full punch-machine programming scene.
- `scenes/world/`: World container and grid map.
- `scenes/automata/`: Automaton entity with components.
- `scenes/machines/`: Punch machine UI/mechanical programmer.
- `scenes/ui/`: Tape editor, automaton status, and log panels.

## Script Structure

- `scripts/core/`: EventBus (signals), GameState (persistent and run state), WorldObject (base).
- `scripts/components/`: SpringEnergyComponent, TapeProgramComponent, GridPositionComponent, InventoryComponent.
- `scripts/systems/`: TapeExecutionSystem (execution logic), AutomatonSystem (actions), EnergySystem (energy).
- `scripts/automata/`: Automaton.gd (entity script).
- `scripts/machines/`: PunchMachine.gd (visual 5-channel tape puncher).
- `scripts/ui/`: Panel scripts for UI interaction.
- `scripts/world/`: World.gd, GridMap.gd.
- `scripts/data/`: InstructionLibrary.gd (instruction definitions), TapeDecoder.gd (parsing), PunchEncoding.gd (5-bit row map).

## Tape Execution

Tape programs can be authored as mnemonics in the `TapeEditorPanel` or punched physically in `PunchMachine.tscn`.

The canonical tape model is:

- one 5-bit row = one physical symbol
- opcode rows identify actions such as `MOV`, `ROT`, `SET`, `JMP`, `JNZ`, `DIE`
- if an opcode needs an argument, the following row is read as numeric data
- `ROT` reads its argument as signed 5-bit data; other current argument-bearing instructions read unsigned values

`TapeDecoder.gd` parses mnemonic programs, while `PunchEncoding.gd` drives the 5-bit keyboard and row labeling model. `TapeExecutionSystem.gd` is the main interpreter used by the programming scene.

## Punch Machine

`PunchMachine.tscn` provides a visual 5-channel punch-tape composer alongside the text editor.

Current important rules:

- each punched row is a 5-bit slice such as `10100`
- tape capacity is currently `48` rows
- rows are stored physically and later saved as labeled cartridges
- cartridges are finite paper media and are intended to wear over time
- the punch machine is part of the workshop preparation loop, not the whole game

## Workshop Loop

The workshop is now the main preparation hub:

- blank cartridges and programmed cartridges are physical shelf items
- leaving the programming bench saves a new programmed cartridge into a fixed shelf slot and consumes one blank cartridge
- programmed cartridges can be selected from the shelf and loaded into drone cabinets
- physical power units are shelf stock and must be installed into a bot before launch
- launched bots leave the cabinet visually and execute their saved tape on the route table
- the route table shows the shelter origin, executed trails, predicted paths, and discovered outside objects

The intended interaction grammar for future workshop work is:

- cards for movable entities such as drones, cartridges, power units, and archived program objects
- machinery for fixed stations such as the programming bench, route table, large map, and shelter devices
- drone preparation should happen by composing cards onto drone cards, not by tiny slot widgets

This workshop is only one layer of the intended architecture:

- Ark layer: operator selection and long-term strategic progression
- Workshop layer: physical preparation, programming, loading, launching
- Route-table layer: live operational monitoring
- Large-map layer: strategic Earth planning
- Journal layer: cross-run preserved knowledge

## Persistence Rule

The current design rule is:

- physical state is run-based
- recorded knowledge is meta-progress

In practice, this means the long-term target is for the journal to preserve:

- Earth observations
- route history
- program knowledge
- archived programs as knowledge
- biological and genetic research
- operator and deployment records

while physical cartridges, power units, bot loadouts, and local shelf state are treated as run material.

## Next Steps

- Add recovery and return logic for halted or stranded bots.
- Add the journal as the main cross-run progression entity.
- Expand the large map and separate it cleanly from the live route table.
- Add detection / zero-waste survival systems.
- Add biological survival systems and later genetic progression.
- Add the Ark operator-selection layer above the workshop.
