# Last Spring

`Last Spring` is a Godot 4 prototype about surviving through indirect action, recorded knowledge, and low-tech systems. The player manages a shelter worktable, programs drones with punch tape, scavenges locations, researches what is found, and turns field matter into usable supplies.

This document is the current project overview for the implemented build. It intentionally describes what exists now, not older long-term design notes.

## Current Play Loop

1. Manage the workshop table.
2. Program a tape on the bench.
3. Load a drone with a tape and power.
4. Send the drone to scan or scavenge.
5. Let the drone return with pending discoveries and salvage.
6. Fight enemies with the operator or drones when needed.
7. Research cards in the journal to reveal recipes and subject knowledge.
8. Copy blueprints from discovered recipes.
9. Craft food, medicine, tape media, storage, and bio-processing structures.
10. Store cards in containers and keep the shelter economy stable.

## What Exists Right Now

### Workshop Machines

- `Programming Bench`
- `Route Table`
- `Charge Machine`
- `Journal`
- `Trash`

These are all represented as machine cards on the workshop table.

### Card Families

- `operator`
- `machine`
- `drone`
- `tape`
- `resource`
- `material`
- `location`
- `enemy`
- `blueprint`
- `crafted`

### Drones

- `Spider Drone`
  - role: ground salvage / combat drone
  - action commands: `MOV`, `ROT`, `SCN`, `PCK`, `DRP`, `ATK`
- `Butterfly Drone`
  - role: scout / passive survey drone
  - action commands: `MOV`, `ROT`, `SCN`

Shared control commands for both drones:

- `NOP`
- `JMP`
- `JNZ`
- `DEC`
- `INC`
- `SET`
- `DIE`

### Locations

Currently generated location cards:

- `CACHE`
- `CRATER`
- `TOWER`
- `SURVEILLANCE ZONE`
- `FACILITY`
- `POND`
- `BUNKER`
- `FIELD`
- `DUMP`
- `NEST`
- `RUIN`

### Enemies

- `Surveillance Drone`
- `Infantry Drone`
- `Stalker`
- `Wolf Pack`
- `Grizzly`

### Materials And Resources

Core material/resource economy:

- `Metal`
- `Paper`
- `Fiber`
- `Biomass`
- `Hide`
- `Bone`
- `Dry Rations`
- `Medicine`
- `Growth Medium`
- `Mushrooms`
- `Algae`
- `Bacteria`
- `Mealworms`
- `Bone Meal`
- `Power Unit`

### Crafted / Structure Outputs

Important crafted outputs currently in the active recipe catalog:

- `FRESH TAPE`
- `TOOL CHEST`
- `ARCHIVE SHELF`
- `BROOD CAGE`
- `TANK`
- `KNIFE`
- `BOW`
- `PLATE MAIL`
- `HIDE CLOAK`
- `TOOL KIT`

## Current Implemented Systems

### Tape Programming

- Blank tapes are real physical media on the table.
- Programmed tapes are saved and persist.
- A tape is loaded onto a drone by drag-and-drop.
- Every executed instruction spends power.

### Drone Missions

- Drones can be launched from the `Route Table`.
- `Butterfly` scan discovers pending location intel in a radius and reveals it only after return.
- `Spider` can scavenge with `PCK` only when it is physically at the assigned location.
- Salvage is kept pending until the drone returns to shelter.
- Drones halt on zero power.
- Drones keep an activity log with position, instruction, energy, and accumulator state.

### Combat

- Enemies are real cards on the table.
- The operator or a powered drone can be stacked onto an enemy card to start combat.
- Spider drone combat reads the loaded tape:
  - if the current combat instruction is `ATK`, the spider deals damage
  - otherwise it only takes damage

### Journal Research

- Research starts when the operator and a valid subject card are stacked on the `Journal`.
- Research consumes one quantity from the researched subject each attempt if that subject uses quantities.
- Research can succeed or fail.
- Success writes knowledge into the journal and may reveal a recipe.
- Failure costs operator energy and may also cost HP.
- The journal supports:
  - discovered pages
  - locked pages
  - partial / locked recipe visibility
  - unread markers
  - blueprint copying from discovered recipes

### Crafting

- Crafting starts when a blueprint, the operator, and the required ingredients are stacked correctly.
- Material cards only need to meet or exceed the required quantity.
- Only the required quantity is consumed.
- The blueprint is destroyed on successful craft.
- `FRESH TAPE` creates a real blank tape instead of a generic crafted card.
- Food and medicine craft into real stackable material cards.

### Storage

Current storage structures:

- `TOOL CHEST`
- `ARCHIVE SHELF`

They can store:

- material cards
- cage-type crafted cards

Stored cards persist and can be withdrawn later.

### Tank Processing

`TANK` is now a working processing station.

Current tank processes:

- `ALGAE -> FIBER x2`
- `BACTERIA + BONE MEAL -> MEDICINE x1`
- `MEALWORMS -> BIOMASS x2`

## Important Active Recipe Chain

The most coherent survival-production chain in the current build is:

- `FIELD -> FIBER`
- `FIBER -> PAPER`
- `BIOMASS + FIBER -> DRY RATIONS`
- `BIOMASS + FIBER + BONE -> MEDICINE`
- `BIOMASS + FIBER -> GROWTH MEDIUM`
- `POND + GROWTH MEDIUM -> ALGAE / MUSHROOMS`
- `BIOMASS + GROWTH MEDIUM -> BACTERIA`
- `BIOMASS + FIBER -> MEALWORMS`
- `BONE -> BONE MEAL`
- `ALGAE / BACTERIA / MEALWORMS -> TANK processing`
- `PAPER -> FRESH TAPE`

## Source Of Truth Files

### Runtime

- [GameState.gd](/Users/vasilibraga/springsurvival/scripts/core/GameState.gd)
  - persistent state
  - location generation
  - drone execution
  - enemy loot
  - research
  - crafting
  - tank processing
  - storage persistence
- [workshop_main.gd](/Users/vasilibraga/springsurvival/scripts/workshop_main.gd)
  - workshop orchestration
  - drag/drop interactions
  - progress bars
  - journal overlay
  - map display
- [WorkshopArt.gd](/Users/vasilibraga/springsurvival/scripts/ui/WorkshopArt.gd)
  - card drawing
  - SVG loading
  - card variants and layouts
- [InstructionLibrary.gd](/Users/vasilibraga/springsurvival/scripts/data/InstructionLibrary.gd)
  - instruction definitions
- [PunchEncoding.gd](/Users/vasilibraga/springsurvival/scripts/data/PunchEncoding.gd)
  - 5-bit punch encoding

### Design Data

- [recipes.json](/Users/vasilibraga/springsurvival/resources/instructions/recipes.json)
  - active recipe catalog
- [enemy_loot.json](/Users/vasilibraga/springsurvival/resources/instructions/enemy_loot.json)
  - enemy death loot tables
- [entities.json](/Users/vasilibraga/springsurvival/resources/instructions/entities.json)
  - current entity catalog for design/reference

## Persistence

Persistence authority is:

- [GameState.gd](/Users/vasilibraga/springsurvival/scripts/core/GameState.gd)

Main save file:

- `user://programmed_cartridges.json`

Saved state currently includes:

- operator state
- programmed tapes
- blank tapes
- power units
- drones and mission state
- discovered locations
- enemies
- materials
- blueprints
- crafted cards
- journal entries
- storage contents
- workshop layout

## Current Known Gaps

These systems are partially defined but not fully live yet:

- equipment cards can exist in recipes/journal, but real equipping/stat application is not finished
- enemy-in-cage research rules are not enforced yet
- the journal still needs stronger partial-vs-complete recipe gating
- the second-operator idea does not exist in runtime yet

## Other Docs

- [GAME_ARCHITECTURE.md](/Users/vasilibraga/springsurvival/GAME_ARCHITECTURE.md)
  - current system architecture and data ownership
- [DRONE_DESIGN.md](/Users/vasilibraga/springsurvival/DRONE_DESIGN.md)
  - current drone behavior model and command rules
- [LOCATION_MODEL.md](/Users/vasilibraga/springsurvival/LOCATION_MODEL.md)
  - current location generation, loot, threat, and mission model
- [ARTSTYLE.md](/Users/vasilibraga/springsurvival/ARTSTYLE.md)
  - visual language
- [CARD_UX.md](/Users/vasilibraga/springsurvival/CARD_UX.md)
  - card UI notes
