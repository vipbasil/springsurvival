# TODO

## Scrum Structure

### Product Goal
- Build a workshop-driven mechanical programming loop:
  - enter first through a cosmic station deployment layer
  - select the next user/operator to be deployed to Earth
  - maintain a persistent journal as the cross-run roguelite knowledge layer
  - create and store punch-tape cartridges
  - load them into mechanical drones
  - power and launch drones into the outside world
  - observe and expand world knowledge through the route table and larger map scenes
  - survive under orbital detection through low-signature, zero-waste systems
  - support the shelter with biological survival loops
  - preserve only accumulated knowledge and edited records between runs
  - express movable entities as cards and fixed stations as machinery

### Current Increment
- The project already has:
  - a workshop overview scene
  - a preserved full programming scene
  - a working punch-machine flow
  - visible cartridge shelves, drone cabinets, and route display
  - persistent programmed cartridges with labels
  - shelf selection and bot cartridge loading in the workshop
  - per-bot installed power-unit state
  - launchable outside bots with automatic route-table execution
  - a new architecture decision that movable entities should become cards
  - shelf-side tapes and power units beginning to shift from canister/cell visuals toward card stacks
  - drone preparation moving to composite drone-card visuals:
    - tape shown as a badge on the drone card
    - power added as stacked card charge on the drone card
  - power cards moving to a single large deck beside the route table, with only the top card draggable into drones

### Vertical Slice Goal
- Prove one complete playable deployment loop where:
  - the player selects an operator on the Ark
  - enters the workshop
  - prepares one bot with one cartridge and one power unit
  - launches that bot into the outside world
  - discovers at least one meaningful thing
  - records the result in the journal
  - ends the run and keeps only preserved knowledge

### Vertical Slice Acceptance Criteria
- A player can start from an Ark operator-selection scene.
- A player can enter the workshop and understand which bot is ready or not ready.
- A player can create or load one cartridge and load it into one bot.
- A player can install one physical power unit into that bot.
- A player can launch the bot and watch a live route on the route table.
- A mission can end in at least one clear outcome:
  - returned
  - halted
  - stranded
- At least one discovery becomes a persistent journal entry.
- Ending the run resets material state but preserves journal knowledge.

### Vertical Slice Backlog

#### VS1. Mission Completion Loop
- Add explicit mission outcomes:
  - active
  - returned
  - halted
  - stranded
- Define how a bot returns from the outside world
- Define what knowledge is kept if a bot returns vs strands
- Make mission resolution visible in the workshop and route table

#### VS2. Journal MVP
- Add a real journal scene or entity
- Persist route records, discoveries, and archived program records
- Add at least one player-editable note field
- Make discoveries visible as durable knowledge, not only transient route markers

#### VS3. Ark Operator Selection MVP
- Add a simple Ark scene before the workshop
- Offer a small operator set with different research biases
- Make operator choice affect starting knowledge or interpretation, not combat stats

#### VS4. Run Reset / Persistence Rule
- Add explicit end-of-run flow
- Reset workshop material state at the end of a run
- Preserve journal knowledge, operator notes, and archived records only
- Make the reset understandable to the player

#### VS5. Detection MVP
- Add one first-pass detection rule tied to low-signature survival
- Make at least one field or shelter action contribute to detection pressure
- Add one understandable consequence if detection rises too far

#### VS6. Vertical Slice Content Lock
- Limit the slice to:
  - one workshop
  - one small outside map
  - one shelter origin
  - one or two discoverable objects or places
  - one or two meaningful operator differences
- Defer broader system breadth until this loop is playable end to end
- Keep the slice consistent with the card/machinery rule:
  - movable entities = cards
  - fixed stations = machinery

### Ordered Product Backlog

#### PB1. Cartridge Workflow
- Put programmed tape cartridges on the shelf
- Add a label area on each cartridge so programmed tapes can be named and saved
- Turn cartridges into movable shelf cards with drag/drop assignment

#### PB2. Bot Preparation Workflow
- Load a chosen cartridge card into one of the bots
- Add a pre-wound mechanical energy-unit card to the bot
- Make bot preparation a card-to-machine interaction, not tiny-click widget logic
- Treat empty power cards as spent; loading should require another charged card
- Show tape on the drone as a label/symbol on the drone card rather than as a separate mounted object
- Allow multiple charged power cards to be added to one drone card with additive total power

#### PB3. Launch and Route Tracking
- Launch the bot into the outside world and watch its advancement on the route table map
- Add click interaction or hover feedback for the route table
- Decide what the route table should actually preview:
  - current trail only
  - predicted route
  - programmed route simulation
- Connect the workshop route display more directly to tape logic if needed
- Add the shelter as the map origin
- Show discovered objects on the route table map
- Add recovery / return states for halted and stranded bots
- Add persistent detection-relevant world signals where appropriate:
  - heat
  - CO2
  - noise
  - magnetic anomalies

#### PB4. Large Map Expansion
- Add a dedicated large map scene with the same visual language
- In the large map scene, allow drawing/selecting icons for places of interest
- Add support for shelter network, cryo-bank, and colony landmarks as later map entities
- Decide which map findings should also exist as journal/intel cards

#### PB5. Journal / Knowledge Progression
- Add a persistent journal entity as the main between-run progression layer
- Store Earth knowledge, discovered places, discovered objects, and route records
- Store programming-language knowledge and previously created programs
- Store biological / genetical knowledge and other research notes
- Store operator notes, deployment history, and cryo-bank / Ark records
- Allow the player to edit entries manually and add handwritten notes
- Make sure only journal knowledge persists between runs, not extra physical state
- Decide which archived knowledge objects should be represented as cards, slates, or dossiers

#### PB6. Detection / Zero-Waste Survival
- Add a detection model tied to visible survival signatures:
  - heat
  - CO2
  - noise
  - magnetic anomalies
- Define how shelter systems and field activity increase or reduce detection risk
- Connect zero-waste thinking to actual workshop and survival decisions
- Define orbital strike / exposure consequences without overcommitting the first prototype

#### PB7. Biological Survival Systems
- Add biological support loops to the shelter fiction and later mechanics
- Define algae, insect, mushroom, and bioluminescent systems as knowledge and production tracks
- Connect bio systems to food, oxygen, waste reduction, and stealth
- Leave the deeper genetics layer for later implementation, but preserve it in the progression plan

#### PB8. Programming Scene Polish
- Continue polishing the punch machine visuals and geometry
- Improve miniature and full-scale consistency between workshop bench and programming scene
- Review instruction labels and opcode assignments for clarity
- Decide whether tape rows should get more visible physical indexing

#### PB9. Workshop Visual Refinement
- Improve proportions and spacing across all four workshop regions
- Make the programming bench miniature closer to the real punch machine proportions
- Refine the flip-disk route display so it feels more mechanical and less abstract
- Improve the shelves so the cartridge stock feels physically arranged rather than icon-stacked
- Decide whether the workshop should become the hub for all future gameplay navigation
- Refactor the workshop so movable entities are visually cards and fixed entities remain machinery
- Refactor the drone area so drone cards are staged on the table rather than treated as mini cabinets
- finish replacing the remaining cabinet-slot interaction logic with whole-card drag/drop behavior

#### PB10. Drone Direction
- Refine the spider silhouette using the new design rules in `DRONE_DESIGN.md`
- Refine the butterfly silhouette further so it reads as a finished mechanical toy/instrument
- Add at least one more drone type for cabinet/world use:
  - rolling scout
  - tracked carrier
  - micro utility drone

#### PB11. Ark / Operator Progression
- Add the Ark as the canonical station layer above the workshop
- Define cryo-bank logic and operator deployment fiction
- Define what selecting a new operator changes in a run:
  - starting knowledge
  - biases or specialties
  - archived notes
  - access to prior records
- Connect long-term progression to a future colony-network or distributed knowledge system

### Suggested Vertical Slice Sprint 1
- VS1. Mission Completion Loop
- VS2. Journal MVP

### Suggested Vertical Slice Sprint 2
- VS3. Ark Operator Selection MVP
- VS4. Run Reset / Persistence Rule

### Suggested Vertical Slice Sprint 3
- VS5. Detection MVP
- VS6. Vertical Slice Content Lock

### Suggested Post-Slice Sprint 1
- PB4. Large Map Expansion
- PB7. Biological Survival Systems
- PB8. Programming Scene Polish

### Suggested Post-Slice Sprint 2
- PB9. Workshop Visual Refinement
- PB10. Drone Direction
- PB11. Ark / Operator Progression

### Sprint Review Questions
- Can a player complete one full deployment loop from Ark selection to mission result?
- Does at least one mission create durable journal knowledge?
- Is it clear that knowledge survives while material state resets?
- Does the slice already express the game’s identity:
  - mechanical programming
  - indirect exploration
  - low-signature survival
  - journal-first progression

## Done

### Scene Structure
- Split the project into two main flows:
  - `res://scenes/main/Main.tscn` as the workshop scene
  - `res://scenes/main/ProgrammingMain.tscn` as the full programming/punch-machine scene
- Added workshop-to-programming navigation by clicking the programming bench
- Added programming-to-workshop navigation with the back button in the programming scene

### Workshop Scene
- Replaced the old startup layout with a workshop-style overview scene
- Added four visible workshop regions:
  - programming bench
  - cartridge stores
  - drone cabinets
  - outside route table
- Reworked the workshop drawing into the same dark steel / brass / paper-tape visual language as the punch machine
- Removed most explanatory text from the workshop and kept only the section titles
- Agreed on the new top-level rule:
  - movable entities should become cards
  - fixed infrastructure should remain machinery

### Programming Bench Preview
- Added a miniature version of the punch machine to the workshop
- Reworked the miniature tape path, punch block, rollers, side canisters, and keyboard deck
- Tightened the miniature keyboard geometry so it fits the reserved deck area

### Cartridge Visuals
- Reworked the main punch-machine cartridges to feel more like mechanical canisters
- Reworked the shelf cartridge icons to better match the canister language

### Cartridge Workflow
- Saving from the programming scene now prompts for a cartridge label when leaving the bench
- Programmed cartridges persist to disk and reload into the workshop shelf
- Programmed cartridges now live in fixed shelf slots instead of auto-reordering
- Programmed cartridges can be selected from the shelf directly in the workshop
- The selected cartridge is shown on the shelf readout and on the cartridge body
- Blank cartridges are now tracked as physical stock on the shelf
- Pre-wound power units are now tracked as physical stock on the shelf
- Opening the programming bench now requires blank stock and a free programmed slot
- Saving now consumes one blank cartridge and creates one programmed cartridge in a fixed slot
- Shelf-side tape visuals are now moving toward stacked-card representation rather than canister-only representation

### Bot Loadouts
- Drone cabinets now show an empty cartridge slot when no tape is loaded
- Clicking a cabinet body now selects that bot without changing its inventory
- Each bot keeps its own separate loaded cartridge reference
- Bot loadouts persist between runs
- Empty power units are now treated as spent; removing a depleted unit clears the slot instead of preserving a zero-charge unit
- New target rule:
  - drones should become composite cards
  - tape should appear as a card label/badge on the drone
  - power should be additive from multiple charged cards
- Loaded cartridge labels are visible in the cabinet plaque and the cartridge mount
- Loading a cartridge into a bot removes it from the shelf and places it in the bot
- Unloading or replacement returns the old cartridge to its original shelf slot
- Each bot now has persistent installed power stored separately from tape loadout
- Cabinets now include a power-unit slot and a visible charge gauge
- Installing power into a bot now consumes a real shelf power unit and removing it returns that physical unit to its slot
- Clicking a shelf power unit now installs that exact unit into the selected workshop bot
- The cabinet-side power control is now eject-only, so install and remove are visually separated
- Shelf power units can now be rewound to full while they remain on the shelf
- Shelf power-unit slots can now be refilled with fresh standard `10`-charge units in the workshop
- The shelf now has explicit workshop stock readouts for blank cartridges, free programmed slots, and stored power units
- Selected bot state is now shown explicitly in the cabinet area
- Selected shelf cartridges can now be recycled back into blank stock through an explicit shelf recycle control
- Legacy low-capacity power units are normalized to the current `10`-charge standard on load
- Cabinets now include a separate launch control
- Active bots leave the cabinet visually and cannot be reconfigured while outside
- Halted or stranded bots can now be recovered manually to the shelter

### Outside World / Route Table
- Bots can now launch only when they have both a loaded cartridge and installed power
- Launched bots execute their saved tape automatically on the workshop route table
- Route progression is persistent between runs
- The shelter is now the route-table origin
- Bots now resolve into explicit mission states:
  - active
  - returned
  - halted
  - stranded
- Bots that complete a mission back at the shelter now enter a returned state and become configurable again in the workshop
- Discoveries are now held with the bot during a mission and only committed to world knowledge when the bot physically returns
- The route table now shows executed trails and predicted future routes with different visuals
- Discovered outside objects are tracked persistently and shown with different signs by category
- Bots can strand outside when movement runs out of installed power

### Drone Cabinet Visuals
- Replaced the first placeholder cabinet drone with a darker mechanical spider
- Reworked the spider to feel more like an industrial repair walker and less like a toy
- Added a second cabinet drone as a wind-up butterfly
- Reworked the butterfly silhouette to use paper-like wings and a visible central wind-up mechanism

### Map / Route Display
- Simplified the bottom region into a single mechanical map housing
- Removed extra furniture and side widgets from the map area
- Changed the map display from a simple grid screen to a flip-disk style display
- Kept route trail, active position, and facing indication

### Punch Machine / Programming
- Preserved the full punch-machine programming scene instead of overwriting it
- Switched the punch input model to a 32-key keyboard
- Changed the 5-bit language mapping so opcodes and numeric argument rows are separate
- Updated `ROT` argument handling to use signed 5-bit values
- Set tape capacity to 48 rows and stop punching when full

### Documentation
- Added `ARTSTYLE.md`
- Added `DRONE_DESIGN.md`

---

## Next

### 1. Vertical Slice: Mission Completion Loop
- Surface the recovery action and danger more clearly in the cabinets and route table
- Decide whether failed recovery should become part of the slice or remain future work
- Decide whether returned missions should auto-unload, stay mounted, or require player acknowledgment
- Connect returned-mission summaries to the future journal MVP
- Fix cabinet interaction ambiguity:
  - loading tape, unloading tape, installing power, removing power, launch, and recovery need separate affordances
  - selected bot / selected cartridge / selected power flow still needs stronger static feedback before click
  - shelf refill / recycle / rewind interactions still need clearer iconography

### 2. Vertical Slice: Journal MVP
- Add a real journal scene or entity
- Persist route records, discoveries, and archived program records
- Add at least one editable note path
- Make the journal the visible proof that knowledge survives between runs

### 3. Vertical Slice: Ark Operator Selection
- Add a simple Ark scene before the workshop
- Offer a small set of operators with different research biases
- Make operator choice affect starting knowledge and interpretation, not combat strength

### 4. Vertical Slice: Run Reset / Persistence
- Add explicit end-of-run flow
- Reset workshop material state at run end
- Preserve journal knowledge and archived records only
- Make the reset understandable in fiction and UI

### 5. Vertical Slice: Detection MVP
- Add one first-pass detection rule tied to low-signature survival
- Make at least one field or shelter action contribute to detection
- Add one clear detection consequence in the slice

### 6. Bot Preparation Workflow
- Add cartridge wear/decay:
  - cartridges are paper-based physical media
  - repeated use should degrade them over time
  - worn cartridges should begin to fail or break down visibly/mechanically
- Add explicit cartridge rename/edit while the cartridge is back on the shelf
- Add cartridge destruction/recycling flow so a new cartridge can be created when programmed slots are full or blank stock runs out
- Decide how power units are replenished or manufactured later
- Replace the current ad hoc shelf refill with a real in-world replenishment or manufacturing process for power units

### 7. Launch and Route Tracking
- Add click interaction or hover feedback for the route table
- Add stronger visual differentiation between multiple simultaneous active bots on the route table
- Decide how halted vs stranded bots should be recovered from the outside world
- Expand discovered objects beyond the current fixed prototype set
- Add more direct interaction with the route table if it should become a planning surface
- Add clearer detection-relevant world objects and signatures to discovery

### 8. Large Map Expansion
- Add a dedicated large map scene with the same visual language
- In the large map scene, allow drawing/selecting icons for places of interest

### 9. Journal / Knowledge Progression
- Add a persistent journal entity as the main roguelite progression layer
- Store knowledge about Earth, discovered places, discovered objects, and route records
- Store programming-language knowledge and the programs already created
- Store biological / genetical information and later research categories
- Store operator notes, deployment history, and Ark / cryo-bank records
- Allow manual editing and handwritten note-style additions
- Define exactly what persists between runs through the journal and what resets

### 10. Detection / Zero-Waste Survival
- Add a first-pass detection model:
  - heat
  - CO2
  - noise
  - magnetic anomalies
- Define how workshop systems and field actions increase or reduce those signals
- Define how low-signature survival changes player decisions

### 11. Biological Survival Systems
- Add algae, insect, mushroom, and bioluminescent systems to the long-term shelter plan
- Connect them to food, oxygen, waste reduction, and stealth
- Preserve the genetics layer as future progression even if it is not implemented yet

### 12. Ark / Operator Layer
- Add a new main entry scene above the workshop
- Present the Ark as the deployment-selection layer
- Let the player select the next user/operator to be deployed to Earth
- Define how the selected user/operator affects the workshop/run state
- Define cryo-bank and replacement logic in the fiction and progression structure

### 13. Programming Scene
- Continue polishing the punch machine visuals and geometry
- Improve miniature and full-scale consistency between workshop bench and programming scene
- Review instruction labels and opcode assignments for clarity
- Decide whether tape rows should get more visible physical indexing

### 14. Workshop Visual Refinement
- Improve proportions and spacing across all four workshop regions
- Make the programming bench miniature closer to the real punch machine proportions
- Refine the flip-disk route display so it feels more mechanical and less abstract
- Improve the shelves so the cartridge stock feels physically arranged rather than icon-stacked
- Decide whether the workshop should become the hub for all future gameplay navigation

### 15. Drone Direction
- Refine the spider silhouette using the new design rules in `DRONE_DESIGN.md`
- Refine the butterfly silhouette further so it reads as a finished mechanical toy/instrument
- Add at least one more drone type for cabinet/world use:
  - rolling scout
  - tracked carrier
  - micro utility drone

---

## Later

### Systems
- Add real cartridge inventory logic:
  - blank cartridges
  - programmed cartridges
  - loading/unloading state beyond the current single-reference model
- Add cabinet inventory / drone ownership logic beyond the current two-bot loadout model

### World / Gameplay
- Expand the workshop into a real hub scene
- Add zero-waste survival systems
- Add stealth / detection systems
- Add biological production systems
- Add operator replacement / cryo-bank progression consequences
- Add long-term colony-network progression and distributed knowledge sharing
- Add repair / maintenance loops for drones and machines

### Presentation
- Add subtle mechanical animations in the workshop:
  - cabinet lights or shutters
  - bench idle motion
  - route table disk changes
- Add ambient industrial props:
  - belts
  - tubes
  - gauges
  - tools

---

## Open Questions

- Should the workshop stay mostly illustrative, or become fully interactable?
- Should cartridge shelves reflect actual saved tape programs?
- Should each drone cabinet open into a dedicated drone management scene?
- Should the outside route table be passive display or actual planning interface?
- What exact opcode mapping should remain reserved as human-memorable keys?

---

## Notes

- `Main.tscn` is now the workshop scene.
- `ProgrammingMain.tscn` is the preserved full programming scene.
- The workshop currently relies heavily on custom drawing in `res://scripts/workshop_main.gd`.
- The punch machine remains the primary detailed interaction scene.
