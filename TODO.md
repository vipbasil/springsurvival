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
  - express workshop interactables as cards, with machinery as a card class

### Current Increment
- The project already has:
  - a workshop overview scene
  - a preserved full programming scene
  - a working punch-machine flow
- persistent programmed tapes with labels
- persistent dynamic power-card stock and bot power state
  - launchable outside bots with automatic route-table execution
  - a first journal research loop:
    - operator + any researchable card on the journal starts a timed research attempt
    - research can fail or discover a recipe note
    - discovered recipes are written into journal pages
    - clicking a recipe copies out a blueprint card onto the table
  - a first blueprint crafting loop:
    - blueprint + machine/operator/resources can start a timed craft process
    - crafting consumes material quantities
    - successful crafting creates persistent result cards on the table
  - a new architecture decision that movable entities should become cards
  - a new workshop rule that the current workshop is one large table surface
  - bench and route table represented as machinery cards on that table
  - drones, tapes, blank tapes, power, and bucket represented as movable cards on the table
  - drone preparation moving to composite drone-card visuals:
    - tape shown as a badge/label on the drone card
    - power shown as an accumulated value on the drone card
  - drag-and-drop as the primary workshop interaction model
  - remaining technical debt under that UX:
    - workshop state code still uses partial shelf/cabinet terminology internally
    - card faces are now partially unified, but still need a stricter shared grammar pass
    - static workshop card/site rendering now lives mostly in `scripts/ui/WorkshopArt.gd`, but `scripts/workshop_main.gd` still owns state-driven overlays like route markers, process bars, floating combat numbers, and run-end feedback

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
- A player can enter the workshop and understand the tabletop card grammar.
- A player can create or load one tape card and attach it to one drone card.
- A player can add one physical power card to that drone card.
- A player can launch the drone by dragging it onto the route-table card.
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
  - workshop interactables = cards
  - machinery = a card class

### Ordered Product Backlog

#### PB1. Cartridge Workflow
- Keep programmed tape as persistent labeled cards
- Keep blank tape as separate physical cards
- Make tape cards readable and movable on the table
- Keep tape attachment to drones as a card-to-card composition step
- Preserve tape identity while simplifying the face to match `CARD_UX.md`

#### PB2. Bot Preparation Workflow
- Load a chosen tape card into one of the drone cards
- Add a pre-wound mechanical energy-unit card to the bot
- Keep bot preparation as card-to-card composition, not tiny widget logic
- Treat empty power cards as spent; loading should require another charged card
- Show tape on the drone as a label/symbol on the drone card rather than as a separate mounted object
- Allow multiple charged power cards to be added to one drone card with additive total power

#### PB3. Launch and Route Tracking
- Launch the bot into the outside world and watch its advancement on the route table map
- Keep launch and recovery route-card driven, not button-driven
- Refine how the route card should preview:
  - current trail
  - predicted route
  - programmed route simulation
- Add the shelter as the map origin
- Show discovered objects on the route table map
- Make `SCN` / `SKN` detect whether a site exists in scanned territory, not only direct-path contact
- Keep scan results as pending mission intel until the drone or operator returns
- Convert returned pending intel into persistent location cards
- Let direct operator scan reveal more than drone scan, but allow it to trigger immediate hostile / hazard card generation
- Keep direct operator scan as a random occurrence system:
  - no fixed finite site pool
  - new location cards can be generated repeatedly
  - forgetting a location card should remove it from current route-card map knowledge
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
- Add returned location cards with at least:
  - `id`
  - `type`
  - `position.x`
  - `position.y`
  - `survey_level`
- Keep location type separate from contents:
  - map card = site
  - journal / follow-up scan = contents
- Replace the current abstract procedural location glyphs with the fixed archetype sheet in `LOCATION_MODEL.md`
- Keep location art readable by using canonical site silhouettes first and only minor controlled variation second

#### PB5. Journal / Knowledge Progression
- Add a persistent journal entity as the main between-run progression layer
- Store Earth knowledge, discovered places, discovered objects, and route records
- Store returned location records separately from field-pending scan intel
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
- Keep the workshop as one large table surface
- Unify tape, power, drone, machine, and trash cards under one shared card grammar
- Refine machinery cards so they read as infrastructure while staying table cards
- Keep route-table and programming-bench cards recognizable while simplifying them for card scale
- Continue migrating any remaining static/fallback art from `workshop_main.gd` into `WorkshopArt.gd` and SVG assets where the art is canonical rather than generated
- Improve free card placement, stacking, overlap, draw order, and drag readability
- Keep the workshop aligned with `CARD_UX.md`

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
- Reworked the workshop drawing into the same dark steel / brass / paper-tape visual language as the punch machine
- Removed most explanatory text from the workshop
- Agreed on the new top-level rule:
  - movable entities should become cards
  - machinery should also be represented through cards on the table
- Collapsed the workshop into one large table surface
- Moved active workshop interaction toward freely arranged tabletop cards
- Removed the old region-based scene structure from the visible workshop scene
- Introduced a shared base card shell across the main workshop card types
- Started normalizing card reading order so tape and power now share the same shell/art/info structure as the other table cards
- Red machinery cards now share the same draggable `*_card` interaction path instead of keeping trash as a special-case object
- Tightened tabletop card drawing and pickup so overlapping cards now follow a clearer topmost order
- Table card placement now persists between reloads for movable workshop cards
- Added a first movable operator card to the workshop table as a placeholder for future Ark selection

### Programming Bench Preview
- Added a miniature version of the punch machine to the workshop
- Reworked the miniature tape path, punch block, rollers, side canisters, and keyboard deck
- Tightened the miniature keyboard geometry so it fits the reserved deck area
- Simplified the bench machinery-card art so it reads faster at card scale

### Cartridge Visuals
- Reworked the main punch-machine cartridges to feel more like mechanical canisters
- Reworked the shelf cartridge icons to better match the canister language

### Cartridge Workflow
- Saving from the programming scene now prompts for a cartridge label when leaving the bench
- Programmed tapes persist to disk and reload into the workshop
- Backend storage still keeps fixed slot identity for programmed tapes and power units
- Blank tapes are tracked as physical stock
- Pre-wound power units are tracked as physical stock
- Opening the programming bench now requires blank stock and a free programmed slot
- Saving now consumes one blank tape and creates one programmed tape
- Tape visuals have shifted from canisters/shelves toward card representation

### Bot Loadouts
- Each bot keeps its own separate loaded cartridge reference
- Bot loadouts persist between runs
- Empty power units are now treated as spent; removing a depleted unit clears the slot instead of preserving a zero-charge unit
- New target rule:
  - drones should become composite cards
  - tape should appear as a card label/badge on the drone
  - power should be additive from multiple charged cards
- Drone attachments have started shifting away from embedded slot widgets:
  - tape now reads as an attached paper tag
  - power now reads as a compact suit + value seal
- Loading a tape into a drone removes it from loose table stock and places it in the drone state
- Unloading or replacement returns the old tape to loose table presence
- Each bot now has persistent installed power stored separately from tape loadout
- Power into a drone now consumes a real table power card and adds to drone total
- Power creation and recharge now happen through a real red charge-machine card on the table
- When the operator card is placed on the charge-machine card, it now produces fresh power cards over time
- Long-running tabletop processes now have a card-top progress-bar pattern; the charge machine uses it first
- New power cards are no longer prefilled at workshop load; they only appear through actual production
- The operator now has persistent energy/HP; charge-machine work consumes energy first, then HP on deficit, and the run ends at 0 HP
- Table cards can now be recycled or discarded through the trash card
- Legacy low-capacity power units are normalized to the current `10`-charge standard on load
- Active bots leave the table as available tabletop agents and cannot be reconfigured while outside
- Halted or stranded bots can now be recovered manually to the shelter

### Outside World / Route Table
- Bots can now launch only when they have both a loaded cartridge and installed power
- Launched bots execute their saved tape automatically on the workshop route table
- Route progression is persistent between runs
- The shelter is now the route-table origin
- Placing the operator card on the route-table card now starts a scan process with a card-top progress bar
- Completed operator scans now generate persistent location cards or hostile cards onto the table
- Location cards now carry stable `image_seed` data and use seeded procedural vector silhouettes instead of only fixed glyphs
- Location cards can now be forgotten by dropping them onto the trash card
- Stacking the operator or a powered drone card onto a hostile card now starts a simple Stacklands-style fight loop with a card-top progress bar
- Combat now has first-pass card feedback:
  - attackers lunge forward and back
  - damaged cards shake briefly
  - floating numbers show attack and damage amounts
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

### Drone Visual Direction
- Replaced the first placeholder cabinet drone with a darker mechanical spider
- Reworked the spider to feel more like an industrial repair walker and less like a toy
- Added a second cabinet drone as a wind-up butterfly
- Reworked the butterfly silhouette to use paper-like wings and a visible central wind-up mechanism

### Map / Route Display
- Simplified the bottom region into a single mechanical map housing
- Removed extra furniture and side widgets from the map area
- Changed the map display from a simple grid screen to a flip-disk style display
- Kept route trail, active position, and facing indication
- Moved the route table toward a movable machinery card on the table
- Simplified the route-table machinery-card art so it reads more clearly at card scale

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

### Extra Urgent: Workshop Architecture Cleanup
- Remove lingering shelf/cabinet assumptions from workshop-facing code paths where practical
- Keep tightening the one-table interaction model so all workshop logic reads as tabletop card play
- Decide whether movable machinery cards are a permanent tabletop rule or only a vertical-slice device
- Keep `TODO.md`, `README.md`, and the codebase aligned while this cleanup happens

### 1. Vertical Slice: Mission Completion Loop
- Surface the recovery action and danger more clearly on the table and route card
- Decide whether failed recovery should become part of the slice or remain future work
- Decide whether returned missions should auto-unload, stay mounted, or require player acknowledgment
- Connect returned-mission summaries to the future journal MVP
- Fix current tabletop drag/drop ambiguity:
  - tape attachment
  - power attachment
  - drone launch on the route card
  - recycle/delete on the trash card
  - free placement vs action drop

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
- Add explicit cartridge rename/edit while the tape card is back on the table
- Add cartridge destruction/recycling flow so a new tape can be created when programmed capacity is full or blank stock runs out
- Decide how the charge-machine card should be limited, fueled, or upgraded later
- Replace unlimited power-card creation with a real in-world replenishment or manufacturing process

### 7. Launch and Route Tracking
- Improve drag/drop feedback for the route card
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
- Replace the current workshop placeholder operator card with real selected-operator state
- Define how the selected user/operator affects the workshop/run state
- Define cryo-bank and replacement logic in the fiction and progression structure

### 13. Programming Scene
- Continue polishing the punch machine visuals and geometry
- Improve miniature and full-scale consistency between workshop bench and programming scene
- Review instruction labels and opcode assignments for clarity
- Decide whether tape rows should get more visible physical indexing

### 14. Workshop Visual Refinement
- Refine the shared card grammar across machines, drones, tapes, power, and trash
- Finish tightening all card faces to one shared shell/layout budget from `CARD_UX.md`
- Keep tuning the programming bench card so it matches the real punch machine without regaining clutter
- Keep tuning the route-table card so it stays mechanical while remaining readable at card scale
- Improve tabletop spacing, stacking, overlap behavior, and topmost selection feel
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
- Add cleaner tabletop ownership / composition logic beyond the current two-drone loadout model
- Refactor backend naming and ownership rules so tabletop card play is not still expressed as shelf/cabinet logic internally

### World / Gameplay
- Continue expanding the workshop into a real hub scene
- Add zero-waste survival systems
- Add stealth / detection systems
- Add biological production systems
- Add operator replacement / cryo-bank progression consequences
- Add long-term colony-network progression and distributed knowledge sharing
- Add repair / maintenance loops for drones and machines

### Presentation
- Add subtle mechanical animations in the workshop:
  - bench-card idle motion
  - route-card disk changes
  - card lift / shadow response
- Add ambient industrial props:
  - belts
  - tubes
  - gauges
  - tools

---

## Open Questions

- Should all workshop preparation remain on the one large table, or should some subsystems still open dedicated management scenes?
- Should the outside route table be passive display or actual planning interface?
- What exact opcode mapping should remain reserved as human-memorable keys?
- How quickly should drone scan versus direct operator scan increase `survey_level`?
- Which operator scan outcomes should immediately create hostile cards, and which should stay pending until return?

---

## Notes

- `Main.tscn` is now the workshop scene.
- `ProgrammingMain.tscn` is the preserved full programming scene.
- The workshop currently relies heavily on custom drawing in `res://scripts/workshop_main.gd`.
- The punch machine remains the primary detailed interaction scene.
- The workshop is now transitioning from region/shelf/cabinet language to one-table card play.
- The workshop frontend is now tabletop-card based, but backend/state terminology still partially uses shelf/cabinet language.
- The programming bench and route table currently exist as machinery cards on the table as part of the current workshop card model.
