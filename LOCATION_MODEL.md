# Location And Scan Model

This file defines how map locations, scanning, and returned field knowledge should work.

It exists to keep three things separate:

- a place on the map
- what is known about that place
- when that knowledge becomes a real card

## Core Rule

**Map detects sites. Exploration reveals contents. Return creates cards.**

That means:

- scans detect whether a site exists in a scanned territory
- scans do not immediately create permanent knowledge cards
- detected knowledge stays attached to the current field mission first
- only a successful return materializes that knowledge as cards

## Location Versus Contents

A location is not the resource itself.

A location is a **site on the map** that may contain:

- resources
- infrastructure
- biological potential
- threats
- anomalies
- knowledge value

Examples:

- `pond` may contain water, algae, insects
- `facility` may contain machinery, archive fragments, danger
- `nest` may contain biomass and hostile life
- `dump` may contain scrap, contamination, chemical waste
- `tower` may contain visibility, signal risk, and salvage

## Detectable Location Types

These are the first recommended map-detectable site types:

- shelter
- ruin
- facility
- tower
- bunker
- settlement
- mine
- dump
- pond
- field
- forest_patch
- cavern
- road_node
- bridge
- nest
- crater
- anomaly_zone

These are map site categories, not direct loot categories.

## Minimum Internal Location Model

Every location should have at least:

- `id`
- `type`
- `position`

Recommended structure:

```json
{
  "id": "loc_old_tower_01",
  "type": "tower",
  "position": { "x": 8, "y": 2 }
}
```

Recommended extended structure:

```json
{
  "id": "loc_old_tower_01",
  "type": "tower",
  "position": { "x": 8, "y": 2 },
  "detected": true,
  "identified": false,
  "survey_level": 1,
  "known_contents": [],
  "threat_level": "unknown",
  "source": "drone_scan",
  "pending": true
}
```

## Survey Levels

Scanning should reveal knowledge in stages.

- `survey_level 0`
  - unknown
- `survey_level 1`
  - something is there
- `survey_level 2`
  - rough category is known
  - example: structure, biological cluster, hazard zone
- `survey_level 3`
  - exact site type is known
  - example: tower, pond, facility, nest
- `survey_level 4+`
  - deeper contents, risks, and special properties become known

This keeps scanning valuable without making it omniscient.

## Remote Drone Scan

Drone scan is the safe, indirect survey method.

For the current command language:

- `SCN` or `SKN` should scan an area, not only the tile directly on the path
- the result should answer:
  - is there a site here
  - what rough kind of site might it be
  - how certain is that information

Drone scan rules:

- safer than direct operator fieldwork
- lower fidelity than direct operator fieldwork
- produces **pending mission intel**
- does not create permanent cards until return

So:

- drone scan discovers
- drone return records

## Direct Operator Scan

The operator may also scan directly in the field.

Direct operator scan rules:

- higher fidelity
- richer results faster
- higher personal risk

Direct operator scan may:

- increase survey level faster
- reveal contents earlier
- trigger hazards
- trigger immediate hostile encounters
- create new location occurrences directly, without relying on a fixed finite site pool

That means direct operator scan can generate:

- location knowledge on successful return
- immediate encounter state while the operator is exposed
- hostile creature cards or hazard cards when contact actually happens

For the current tabletop prototype, operator scan on the route card behaves as current knowledge generation:

- each completed scan can generate either a new location card or a hostile card
- location cards represent the currently known scan occurrences
- if a location card is forgotten or trashed, it disappears from current route-card map knowledge
- later scans can generate new location cards again

## Pending Intel Rule

Detected locations should first live in mission state, not in durable world knowledge.

Recommended flow:

1. a scan checks the scanned area
2. if a site exists, add a pending location record to the current mission
3. if the drone or operator is lost before return, that pending intel may be lost
4. if the mission returns, convert pending intel into persistent knowledge

This supports the main game rule:

**knowledge is fragile until recovered**

## Card Materialization Rule

Location cards should be created only when the drone or operator returns with the information.

So:

- field scan = temporary mission intel
- return = permanent card creation

On successful return, the game may create:

- a `Location` card
- a journal entry
- map knowledge updates

Example returned card payload:

```json
{
  "id": "loc_old_tower_01",
  "type": "tower",
  "position": { "x": 8, "y": 2 },
  "survey_level": 2,
  "known_contents": [],
  "source_mission": "mission_12",
  "pending": false
}
```

## Immediate Encounter Exception

There is one deliberate exception:

If a direct operator scan triggers contact right now, the game may generate immediate encounter cards such as:

- hostile creature
- hazard
- anomaly event

This is not the same as durable returned knowledge.

So the clean distinction is:

- **returned site knowledge** becomes durable location cards
- **live operator contact** may generate immediate encounter cards

## UI / UX Implications

The map should show:

- detected site presence
- partial classification
- exact type only after enough survey

The journal should store:

- returned locations
- returned interpretations
- later discovered contents

The table can then hold:

- location cards
- knowledge cards
- encounter cards

but only after the information has been materially recovered.

## Recommended First Implementation

For the first usable version:

- store location records with:
  - `id`
  - `type`
  - `position.x`
  - `position.y`
  - `survey_level`
  - `pending`
- let drone `SCN` detect if a site exists in scanned territory
- keep detections attached to the mission until return
- create location cards only on return
- let direct operator scan reveal more but risk hostile card generation
