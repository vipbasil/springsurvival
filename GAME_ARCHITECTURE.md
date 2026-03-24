# Game Architecture

This file describes the current implemented architecture of `Last Spring`. It is not a long-term speculative design document. If the code and this file disagree, the code wins, and this file should be updated.

## 1. Product Shape

The current game is a single-workshop management prototype built around:

- a table of cards
- fixed machine cards
- indirect field action through drones
- a persistent journal and recipe system
- survival production based on scavenged matter

The player does not directly walk the world. The world is acted on through:

- drone tape programs
- route-table launches
- returned discoveries
- returned salvage

## 2. Main Runtime Authority

The main gameplay authority is [GameState.gd](/Users/vasilibraga/springsurvival/scripts/core/GameState.gd).

It owns:

- operator state
- tapes
- power units
- drones and their field state
- location cards
- enemy cards
- material cards
- blueprint cards
- crafted cards
- journal entries
- storage contents
- workshop layout persistence

The workshop scene mostly orchestrates UI and drag/drop around that state.

## 3. Source Of Truth Split

### Runtime Code

- [GameState.gd](/Users/vasilibraga/springsurvival/scripts/core/GameState.gd)
- [workshop_main.gd](/Users/vasilibraga/springsurvival/scripts/workshop_main.gd)
- [WorkshopArt.gd](/Users/vasilibraga/springsurvival/scripts/ui/WorkshopArt.gd)
- [WorkshopCardRuntime.gd](/Users/vasilibraga/springsurvival/scripts/ui/WorkshopCardRuntime.gd)
- [WorkshopTableController.gd](/Users/vasilibraga/springsurvival/scripts/ui/WorkshopTableController.gd)

### Data Files

- [recipes.json](/Users/vasilibraga/springsurvival/resources/instructions/recipes.json)
- [enemy_loot.json](/Users/vasilibraga/springsurvival/resources/instructions/enemy_loot.json)
- [entities.json](/Users/vasilibraga/springsurvival/resources/instructions/entities.json)

The intention is:

- code owns behavior
- JSON owns design-facing catalogs

## 4. Tabletop Entity Rule

The project uses one consistent tabletop interaction model:

- movable things are cards
- fixed workstations are machine cards

### Current movable card families

- operator
- drone
- tape
- resource
- material
- location
- enemy
- blueprint
- crafted

### Current fixed workstations

- bench
- route
- charge
- journal
- trash

## 5. Scene Responsibility

### [workshop_main.gd](/Users/vasilibraga/springsurvival/scripts/workshop_main.gd)

Responsible for:

- collecting visual cards from state
- drag/drop handling
- process start detection
- active progress overlays
- journal modal
- bot log modal
- map rendering and marker feedback
- combat/research/crafting/tank process feedback

### [WorkshopArt.gd](/Users/vasilibraga/springsurvival/scripts/ui/WorkshopArt.gd)

Responsible for:

- card shells
- card art layout
- text slot layout
- SVG/image loading
- visual fallback handling

It should not own gameplay state transitions.

### [GameState.gd](/Users/vasilibraga/springsurvival/scripts/core/GameState.gd)

Responsible for:

- persistence
- mission simulation
- tape execution
- salvage resolution
- encounter generation
- research
- blueprint crafting resolution
- storage operations
- tank resolution

## 6. Persistence Model

Persistence currently lives in:

- [GameState.gd](/Users/vasilibraga/springsurvival/scripts/core/GameState.gd)

Main save file:

- `user://programmed_cartridges.json`

Saved state includes:

- operator
- drone cabinet / loadouts / field state
- tapes
- blank tapes
- power units
- discovered locations
- enemies
- material cards
- blueprint cards
- crafted cards
- journal pages
- storage contents
- workshop card positions

## 7. Drone Execution Model

Drone execution is tape-driven and stateful.

Each bot tracks:

- position
- facing
- accumulator
- program pointer
- power charge
- trail
- mission location
- pending discoveries
- pending salvage
- activity log

### Energy rule

Every executed instruction costs `1` power.

If power reaches zero:

- the bot halts
- it does not continue executing

### Shared and per-drone commands

Shared control:

- `NOP`
- `JMP`
- `JNZ`
- `DEC`
- `INC`
- `SET`
- `DIE`

Butterfly actions:

- `MOV`
- `ROT`
- `SCN`

Spider actions:

- `MOV`
- `ROT`
- `SCN`
- `PCK`
- `DRP`
- `ATK`

## 8. Mission Flow

### Scan flow

Butterfly scan:

- scans a radius
- can queue location finds
- does not create immediate hostile encounters from scan
- discoveries materialize when the drone returns

Spider scan:

- forward-facing scan
- can queue pending discoveries

### Location mission flow

If a drone is dropped onto a location card:

- the bot stores that location as the mission target
- `PCK` only works when the bot is physically at that target position
- salvage is stored as pending mission salvage
- encounter rolls can generate real enemy cards
- pending salvage is committed only on return to shelter

### Return rule

When a bot reaches shelter in a terminal or completed mission state:

- pending discoveries are committed
- pending salvage is committed
- mission state is cleared
- bot status becomes `returned`

## 9. Combat Model

Enemies are represented as cards. Combat can be initiated through card stacking.

Important current drone combat rule:

- spider drone attack output depends on tape
- only `ATK` instructions cause drone damage output during the fight loop
- non-`ATK` instructions mean the drone takes damage but does not deal it

## 10. Research Model

The journal is a live gameplay system, not just flavor text.

Research:

- starts from `operator + subject + journal`
- consumes one quantity from researchable quantity-bearing cards
- can succeed or fail
- can create a new subject page
- can reveal recipes
- stores unread state

The journal currently supports:

- discovered pages
- locked pages
- partial locked recipes
- discovered recipes on related pages
- blueprint spawning from discovered recipes

## 11. Crafting Model

Blueprint crafting is stack-based.

Required participants can include:

- blueprint
- operator
- machine
- location subject
- material cards

Rules:

- ingredient quantity can exceed the recipe requirement
- only the required amount is consumed
- the blueprint is destroyed on success

Current craft outputs resolve into:

- real blank tape
- stackable material cards
- crafted structure/equipment cards

## 12. Storage Model

Storage is currently implemented through crafted storage cards:

- `TOOL CHEST`
- `ARCHIVE SHELF`

They can persist stored entries and later return them to the table.

## 13. Tank Model

`TANK` is the current bio-processing structure.

Implemented processes:

- `ALGAE -> FIBER x2`
- `BACTERIA + BONE MEAL -> MEDICINE`
- `MEALWORMS -> BIOMASS x2`

This is the start of the biological production chain.

## 14. Current Architectural Strengths

The current build already has a coherent spine:

- card/table interaction
- drone mission loop
- returned knowledge
- journal research
- blueprint crafting
- consumable survival economy
- storage
- tank processing

## 15. Current Architectural Gaps

These are still partial or missing:

- real equipment card behavior and stat application
- second operator / rescued operator systems
- cage-specific enemy research gating
- stronger recipe completion rules in the journal
- broader biological structure network beyond the tank

## 16. Documentation Rule

When changing behavior, update at least:

- [README.md](/Users/vasilibraga/springsurvival/README.md)
- [GAME_ARCHITECTURE.md](/Users/vasilibraga/springsurvival/GAME_ARCHITECTURE.md)
- relevant JSON catalogs in [resources/instructions](/Users/vasilibraga/springsurvival/resources/instructions)

This keeps the design documentation tied to the live runtime. 
