# Location Model

This document describes the current implemented location system: how locations are generated, how they are discovered, what they can yield, and what can attack during scavenging.

## 1. Core Rule

Locations are world sites, not loot cards.

A location card means:

- a place exists
- that place has a type
- that place can be researched
- that place can be targeted by a drone mission
- that place has its own salvage and threat logic

## 2. Current Generated Location Types

The active generated location pool is:

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

`RUIN` is now in the live generation pool, not just in design data.

## 3. How Locations Enter Play

### Operator generation

The operator can generate random location cards through current workshop-side discovery logic.

### Drone scan generation

Drone scans can create pending location findings.

Important current behavior:

- butterfly scan queues findings first
- findings become real location cards when the drone returns

## 4. Location Mission Model

If a drone is dropped onto a location card:

- that location becomes the drone’s mission target
- the target position is stored on the drone
- `PCK` only works at that exact target

This makes location cards actionable mission objects, not just knowledge cards.

## 5. Scavenge Resolution Rules

Current scavenge logic:

- each location has its own loot table
- each location has its own base pickup chance
- repeated pickup attempts on one mission get worse through diminishing success chance
- salvage stays pending while the drone is outside
- salvage is only committed on return to shelter

Current supported loot kinds:

- `material`
- `power`
- direct `crafted/equipment-style` salvage

## 6. Current Live Loot By Location

### Pond

Loot:

- `Biomass`
- `Algae`
- `Mushrooms`

Threats:

- `Wolf Pack`
- `Stalker`
- `Grizzly`

### Crater

Loot:

- `Metal`
- `Bone`
- `Biomass`

Threats:

- `Stalker`
- `Wolf Pack`
- `Grizzly`

### Tower

Loot:

- `Metal`
- `Power Unit`
- `Knife`
- `Bow`
- `Plate Mail`

Threats:

- `Surveillance Drone`
- `Infantry Drone`
- `Stalker`

### Surveillance Zone

Loot:

- `Metal`
- `Power Unit`
- `Bow`

Threats:

- `Surveillance Drone`
- `Infantry Drone`
- rare `Stalker`

### Facility

Loot:

- `Metal`
- `Power Unit`
- `Dry Rations`
- `Mushrooms`
- `Algae`

Threats:

- `Infantry Drone`
- `Surveillance Drone`
- `Stalker`

### Bunker

Loot:

- `Paper`
- `Metal`
- `Power Unit`
- `Medicine`
- `Dry Rations`
- `Mushrooms`
- `Algae`
- `Knife`
- `Bow`
- `Plate Mail`
- `Tool Kit`

Threats:

- `Stalker`
- `Infantry Drone`
- `Surveillance Drone`
- rare `Wolf Pack`

### Field

Loot:

- `Biomass`
- `Fiber`
- `Hide`
- rare `Mushrooms`

Threats:

- `Wolf Pack`
- `Grizzly`
- `Stalker`

### Dump

Loot:

- `Metal`
- `Fiber`
- `Bone`
- `Power Unit`
- `Knife`
- `Plate Mail`
- `Tool Kit`

Threats:

- `Stalker`
- `Wolf Pack`
- `Grizzly`
- `Infantry Drone`

### Cache

Loot:

- `Medicine`
- `Dry Rations`
- `Paper`
- `Knife`
- `Bow`
- `Plate Mail`

Threats:

- `Stalker`
- `Wolf Pack`
- `Infantry Drone`

### Nest

Loot:

- `Biomass`
- `Bone`
- `Hide`
- `Bacteria`
- `Mealworms`
- rare `Mushrooms`

Threats:

- `Wolf Pack`
- `Grizzly`
- `Stalker`

### Ruin

Loot:

- `Metal`
- `Paper`
- `Bone`
- `Fiber`
- `Mushrooms`
- `Knife`

Threats:

- `Stalker`
- `Wolf Pack`
- `Grizzly`
- occasional `Infantry Drone`

## 7. Research Value Of Locations

Researching a location page currently gives:

- a durable journal page for that location type
- the current extract list
- the current scavenging risk list
- related recipes that reference that location

This means location cards are both:

- mission targets
- research subjects

## 8. Relationship To Other Systems

Locations feed the larger economy:

- `FIELD -> FIBER`
- `POND -> ALGAE / MUSHROOMS`
- `FACILITY -> TANK / TOOL CHEST / equipment-adjacent salvage`
- `NEST -> BROOD CAGE / BACTERIA / MEALWORMS`
- `RUIN -> ARCHIVE SHELF / mushrooms / mixed salvage`

## 9. Current Design Intent

Location types should feel distinct:

- `POND`, `FIELD`, `NEST` support the biological economy
- `FACILITY`, `TOWER`, `SURVEILLANCE ZONE` support machine and power economy
- `CACHE`, `BUNKER`, `DUMP`, `RUIN` are mixed-value salvage sites

## 10. Current Known Gaps

Still missing or partial:

- survey depth beyond the current card-level discovery model
- special one-off location modifiers
- unique instance traits per site
- non-loot location functions such as rescued operators or major map events

## 11. Documentation Rule

Whenever location loot or threats change, update:

- [GameState.gd](/Users/vasilibraga/springsurvival/scripts/core/GameState.gd)
- [LOCATION_MODEL.md](/Users/vasilibraga/springsurvival/LOCATION_MODEL.md)
- journal-facing descriptions indirectly through runtime if needed
