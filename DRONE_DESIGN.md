# Drone Design

This file documents the current drone model as it exists in the game now: command set, mission role, energy logic, and current constraints.

It is not only an art note. It is the gameplay behavior reference for drones.

## 1. Current Drone Types

There are currently two drones:

- `Spider Drone`
- `Butterfly Drone`

Both are physical tabletop cards that can carry:

- one programmed tape
- accumulated power
- three future equipment slots

## 2. Shared Drone State

Both drones track:

- `outside_status`
- `outside_position`
- `outside_facing`
- `outside_ptr`
- `outside_acc`
- `power_charge`
- `outside_trail`
- `pending discoveries`
- `pending salvage`
- `mission location`
- `activity log`
- `combat_ptr`

The persistent source of truth is [GameState.gd](/Users/vasilibraga/springsurvival/scripts/core/GameState.gd).

## 3. Shared Control Commands

Both drones support these non-role-specific commands:

- `NOP`
- `JMP`
- `JNZ`
- `DEC`
- `INC`
- `SET`
- `DIE`

These are control-flow and accumulator operations.

## 4. Butterfly Drone

### Role

The butterfly is the low-risk scout.

It is intended for:

- route discovery
- remote survey
- pending location detection
- non-aggressive observation

### Action Commands

- `MOV`
- `ROT`
- `SCN`

### Scan Behavior

Butterfly `SCN`:

- scans a radius of `4`
- rolls discovery per cell
- queues pending location findings
- does not immediately materialize those findings
- does not trigger aggressive mobs through scanning

The findings only appear as real location cards when the butterfly returns.

### What It Does Not Do

- no `PCK`
- no `DRP`
- no `ATK`

It is not the salvage/combat platform.

## 5. Spider Drone

### Role

The spider is the work drone.

It is intended for:

- targeted salvage
- rough terrain operation
- location pickup
- direct combat participation

### Action Commands

- `MOV`
- `ROT`
- `SCN`
- `PCK`
- `DRP`
- `ATK`

### Pickup Behavior

`PCK` only matters if:

- the spider is on a location mission
- and it is physically standing at the exact mission location

Then it can:

- roll location-specific salvage
- roll location-specific encounters
- add salvage to pending return inventory

Salvage is committed only on return to shelter.

### Combat Behavior

Spider combat reads the loaded tape.

During a fight cycle:

- if the current combat instruction is `ATK`, the spider deals damage
- otherwise it does not attack and only receives damage

So spider tapes can be:

- combat-capable
- or effectively non-combat tapes

depending on whether `ATK` is actually present in the loop.

## 6. Power Rules

All executed instructions cost power.

This includes:

- movement
- scan
- pickup
- attack
- control flow

If the drone starts a tick at zero power:

- it halts immediately

If it reaches zero after an instruction:

- it halts after that instruction

The current capacity baseline is:

- `50` per power unit scale

## 7. Tape Rules

Drone behavior is determined by loaded programmed tape.

Important runtime rules:

- unsupported action commands halt the drone
- control commands are shared
- mission outcome depends heavily on tape structure

This means the tape is not flavor. It is the real drone brain.

## 8. Mission Return Rule

Drones can carry pending world effects while outside:

- pending discoveries
- pending salvage

Those only become real tabletop state when the drone returns to shelter.

Return currently commits:

- discovered locations
- pending salvage
- mission summary
- cleared mission state

## 9. Activity Log

Each bot keeps a persistent activity log.

Log lines include:

- tick index
- position
- current energy
- accumulator value
- action result

This is currently the main debugging and interpretation surface for field behavior.

## 10. Current Programming Language Reference

### Shared control

- `NOP`
- `JMP`
- `JNZ`
- `DEC`
- `INC`
- `SET`
- `DIE`

### Butterfly action language

- `MOV`
- `ROT`
- `SCN`

### Spider action language

- `MOV`
- `ROT`
- `SCN`
- `PCK`
- `DRP`
- `ATK`

The punch/binary opcode view is exposed in the journal for researched drone pages.

## 11. Current Role Split

This is the intended gameplay split right now:

- `Butterfly`
  - scout first
  - safer
  - information-heavy
  - low direct interaction

- `Spider`
  - salvage first
  - more dangerous
  - combat-capable
  - mission-output drone

## 12. Current Design Limits

Not implemented yet:

- different equipment affecting drone stats
- drone-specific repair/build modifiers from equipment
- field-side `DRP` logic with real world consequences
- advanced combat behaviors beyond tape-driven `ATK`

## 13. Art Direction Constraint

The visual rule remains:

- drones are readable mechanical devices
- not clean futuristic robots
- SVG/icon readability matters more than high detail

Current visual anchors:

- spider: grounded mechanical worker
- butterfly: lightweight scout / instrument hybrid
