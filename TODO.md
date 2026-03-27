# TODO

This backlog reflects the current implemented build. It is organized around the systems that are actually live now:

- workshop table card play
- drone missions
- journal research
- blueprint crafting
- storage
- bio-processing

Old vertical-slice items that are already implemented have been removed.

## Product Goal

Build a coherent shelter-table survival game where the player:

- programs drones with punch tape
- scouts and scavenges the outside world indirectly
- researches returned matter and places
- unlocks recipes through journal knowledge
- crafts consumables, media, storage, and bio structures
- stabilizes a low-tech survival economy around food, medicine, media, and salvage

## Current Build Summary

Already implemented:

- workshop tabletop card interaction
- bench, route, charge, journal, and trash machine cards
- spider and butterfly drones with different command sets
- tape loading and power loading
- route-table drone launch
- returned discoveries and returned salvage
- enemy cards and fight loop
- journal research with failure/success feedback
- blueprint creation from journal recipes
- blueprint crafting
- stackable material cards
- storage containers
- tank processing
- externalized recipe, enemy loot, and entity catalogs

## Highest Priority

### 1. Equipment System

The game already has:

- equipment definitions
- equipment journal pages
- equipment recipes
- visible universal equipment slots on operator and drones

Still missing:

- craft equipment into real equipment cards instead of generic crafted cards
- allow dropping equipment onto operator and drone slots
- support 3 universal slots for:
  - operator
  - spider
  - butterfly
- apply summed stat bonuses from equipped items
- support stacking the same equipment type:
  - `3x knife`
  - `3x hide cloak`
  - mixed builds
- make equipment removable and persistent

Required first stat model:

- `attack`
- `armor`
- `stealth`
- `utility`

### 2. Journal Recipe States

The journal now supports:

- locked pages
- discovered pages
- recipe propagation across related pages
- explicit `recipe_ids`

Still needed:

- explicit recipe completion states:
  - `locked`
  - `partial`
  - `complete`
- only allow blueprint copy from complete recipes
- partial recipes should reveal known ingredients and mask unknown ones
- base completion on researched/discovered subject coverage, not just “recipe seen once”
- make journal page sections clearer:
  - subject notes
  - loot
  - threats
  - recipes
- add proper cross-reference display so related recipes/pages are visible from all relevant subjects
- fix multi-page recipe UI bugs when a page has more than one recipe page worth of content
- add explicit drone capability sections:
  - allowed commands
  - mission role
  - hardware limits
- reserve dedicated space for per-drone programming notes instead of squeezing it into the general description block
- separate journal page structure into stable sections with fixed layout, not flowing mixed text

### 2A. Punch Tape UX And Identity

Current state:

- binary punch-tape programming exists
- decode preview exists
- execution commitment exists
- shared interpreter with machine-specific capability exists

Still needed:

- add a fast-forward / terminate / skip-to-outcome flow once failure is obvious
- make tape correction a real physical mechanic:
  - patching
  - splicing
  - possibly cutting / joining segments
- make tape scarcity and tape damage matter more than raw binary memorization
- let the typewriter start with no default program label and allow direct user naming / renaming from keyboard input
- keep asking the design question: what larger survival purpose does the tape system serve in the full game loop?
- make sure the punch-tape loop pays off in:
  - stealth / signature pressure
  - logistics / recovery
  - resource scarcity
  - machine capability differences

### 3. Enemy Research Through Cages

Current state:

- enemies exist
- `BROOD CAGE` exists
- research system exists

Still needed:

- enforce that enemy research requires a cage workflow
- define which enemies can be caged
- define how a caged enemy becomes a research subject
- define failure and escape risk
- define whether cages are single-use or persistent structures

### 4. Equipment And Salvage Consistency

Now that locations can directly return:

- `Knife`
- `Bow`
- `Plate Mail`
- `Tool Kit`

we need to clean up the type model:

- decide whether found gear and crafted gear use the same card class
- make sure salvage-found equipment enters the real equipment system cleanly
- avoid “crafted item but used as equipment” ambiguity

## Medium Priority

### 5. Biological Production Expansion

Current bio chain exists:

- `Growth Medium`
- `Mushrooms`
- `Algae`
- `Bacteria`
- `Mealworms`
- `Bone Meal`
- `Tank`

Still needed:

- make `Mushrooms` useful downstream
- decide whether `Mushrooms` can become `Dry Rations` directly or through a tank/process
- decide whether `Algae` and `Mealworms` should have more than one output
- define if `Bacteria` can fail/contaminate
- add a second biological structure only if needed after tank proves insufficient

### 6. Operator Supplies And Survival Flow

Current consumables:

- `Dry Rations`
- `Medicine`

Still needed:

- clearer card feedback when consumed
- clearer stock visibility on the table
- decide whether `Growth Medium` is operator-usable or process-only
- decide whether operator death / incapacity should block research and crafting differently

### 7. Drone Mission UX

Current mission systems exist, but the UX still needs tightening:

- make mission state more readable directly on the drone card
- improve return / halted / stranded readability
- make pending salvage and pending discoveries readable before return
- improve bot log readability:
  - maybe show pointer too
  - maybe filter mission summary vs tick log
- surface when a tape is unsuitable for a mission:
  - butterfly with no scan loop
  - spider with no pickup loop
  - spider combat tape with no `ATK`

### 8. Route Table And Map UX

Current route feedback exists:

- active marker pulse
- mission marker highlight
- mission progress bar

Still needed:

- make multiple simultaneous missions clearer
- make threat/encounter outcomes clearer on the map
- show returned-vs-pending intel more cleanly
- decide whether the route table should also show salvage expectation / mission type

### 9. Storage UX

Current storage works, but still needs usability work:

- show stored contents more clearly on chest/shelf cards
- add small content preview strip or count breakdown
- allow sorting or grouping in the storage overlay
- decide whether storage capacity should stay unlimited

## Lower Priority But Important

### 10. Persistence Cleanup

Persistence is still too centralized in [GameState.gd](/Users/vasilibraga/springsurvival/scripts/core/GameState.gd).

Still needed:

- split save/load into a dedicated persistence layer
- normalize all saved card families through one schema pass
- make recipe/page save format less ad hoc
- reduce one-off compatibility branches where possible

### 11. Card Model Cleanup

A lot of card behavior has been unified, but the project still lacks one fully explicit card model.

Still needed:

- define a clearer shared runtime shape for all table cards
- reduce custom per-kind drag/drop behavior further
- unify card ids / layout keys / display labels / kind typing
- keep art and runtime cleanly separated

### 12. Design Data Ownership

The project now has:

- [recipes.json](/Users/vasilibraga/springsurvival/resources/instructions/recipes.json)
- [enemy_loot.json](/Users/vasilibraga/springsurvival/resources/instructions/enemy_loot.json)
- [entities.json](/Users/vasilibraga/springsurvival/resources/instructions/entities.json)

Still needed:

- decide which design relationships should also move into JSON:
  - page-to-recipe relations
  - equipment stats
  - location loot
  - location threat tables
- keep docs and JSON catalogs synchronized when systems change

## Deferred / Future

These are valid future directions but are not immediate blockers:

### Ark Layer

- real pre-workshop operator selection
- deployment framing
- long-term meta progression

### Run Reset Rule

- explicit end-of-run reset flow
- durable vs non-durable knowledge separation across runs

### Detection / Zero-Waste Layer

- heat
- noise
- CO2
- magnetic anomaly pressure
- orbital detection consequences

### Additional Drone Types

- rolling scout
- tracked carrier
- other specialized field platforms

### Additional Bio Structures

- only if the tank and cage systems prove too narrow

## Immediate Recommended Order

1. Finish real equipment cards and slot behavior.
2. Finish journal recipe completion logic.
3. Make cage-based enemy research real.
4. Clean up found gear vs crafted gear type behavior.
5. Deepen mushroom/algae/bacteria/mealworm usefulness.
6. Improve mission and storage UX.

## Maintenance Rule

When behavior changes, update:

- [README.md](/Users/vasilibraga/springsurvival/README.md)
- [GAME_ARCHITECTURE.md](/Users/vasilibraga/springsurvival/GAME_ARCHITECTURE.md)
- [DRONE_DESIGN.md](/Users/vasilibraga/springsurvival/DRONE_DESIGN.md)
- [LOCATION_MODEL.md](/Users/vasilibraga/springsurvival/LOCATION_MODEL.md)
- relevant JSON catalogs under [resources/instructions](/Users/vasilibraga/springsurvival/resources/instructions)
