# Systems Memory

## Current Game Identity

- Last Spring is currently a shelter-table systems game.
- The strongest live loops are: drone missions, journal research, blueprint crafting, storage, and tank processing.
- The game should stay card-native where possible.

## Current Strong Production Spine

- FIELD -> FIBER
- FIBER -> PAPER
- BIOMASS + FIBER -> DRY RATIONS
- BIOMASS + FIBER + BONE -> MEDICINE
- BIOMASS + FIBER -> GROWTH MEDIUM
- POND + GROWTH MEDIUM -> ALGAE / MUSHROOMS
- BIOMASS + GROWTH MEDIUM -> BACTERIA
- BIOMASS + FIBER -> MEALWORMS
- BONE -> BONE MEAL
- ALGAE / BACTERIA / MEALWORMS -> TANK processing
- PAPER -> FRESH TAPE

## Current Role Split

- Butterfly drone: passive scouting / scanning
- Spider drone: salvage / transport / combat
- Drone runtime is now type-driven. Bot cards carry explicit `drone_type`, and commands, research text, names, combat values, journal preview, and card rendering are no longer derived from fixed slot indices.
- Journal: research and recipe discovery
- Journal now has an index page, structured drone/location note sections, paginated recipe display on subject pages, clickable related-subject cross-references, and live recipe states: locked / partial / complete.
- Enemy research now runs through cages, not loose enemy cards: an occupied cage is a persistent structure container that stores a captive enemy, can be placed on the journal for research, and can release the captive back to the table.
- Enemy capture is now a timed cage process started by overlapping an enemy card and an empty cage in either direction. Success is rolled against current operator energy versus enemy HP and attack; failure destroys the cage and leaves the enemy free.
- Blueprint: craft authorization and formula carrier
- Tank: portable bioprocess mechanism, not a passive structure
- Journal knowledge now has two visible sources: direct research entries and formula-derived subject knowledge. If a recipe becomes complete, its result page is revealed for browsing and cross-reference.
- Journal now has structure subject pages too: TANK, TOOL CHEST, BROOD CAGE, and ARCHIVE SHELF can appear as real journal pages and cross-reference from their recipes.
- Route table: this is the actual map surface, not just a decorative machine card. It is a core mechanic layer for route reading, mission targeting, map feedback, and outside-world state.
- Fresh no-save runs now begin with an Ark deployment choice between 3 operators. The selected operator is stored in operator_state, then materializes into the starter shelter on Earth.
- Current implemented starter shelter package for that selected operator:
  - operator at full HP / energy
  - spider drone
  - butterfly drone
  - 3 blank tapes
  - 1 short programmed demo tape
  - power_unit material x100
  - starting materials: metal x2, biomass x2, fiber x2, paper x1
  - starting discovered journal pages: FIELD, POND, FIBER, BIOMASS
  - starter journal is seeded with FIELD, POND, FIBER, BIOMASS plus operator-specific known subjects
  - current demo tape is START LOOP: SCN, MOV, ROT 4, DIE
- `power_unit` now lives in `material_cards`, not a separate resource stack. It has two live recharge paths:
  - `CHARGE MACHINE` consumes up to `50` `power_unit` quantity automatically when a workshop drone is placed on the machine; operator overlap is no longer required.
  - dropping a `power_unit` material card directly onto a workshop drone transfers charge from that specific card into the drone and reduces the card quantity immediately.
- Current implemented Ark operator roster:
  - OP. LERA
    - focus: MECH / ARCHIVE
    - role: balanced generalist
    - start bias: TOOL KIT equipped, paper +1, PAPER page known
  - OP. MIRA
    - focus: BIO / SURVEY
    - role: biology / stealth bias
    - start bias: HIDE CLOAK equipped, biomass +1, fiber +1, MUSHROOMS page known
  - OP. DREN
    - focus: SALVAGE / SECURITY
    - role: salvage / hostile handling bias
    - start bias: KNIFE equipped, metal +1, METAL page known, TOOL CHEST page known, BROOD CAGE page known
- Current implementation now uses a distinct portrait asset for each starting operator profile:
  - LERA -> operator_lera
  - MIRA -> operator_mira
  - DREN -> operator_dren
  Ark deployment preview cards and the live operator card both use the selected profile portrait.
- If a shelter run ends with the operator dead, the game now returns to the Ark deployment flow instead of leaving the player in a dead workshop state. The same 3-operator selection overlay is reused as redeployment.
- Journal knowledge is persistent between runs. Redeployment resets the shelter state, cards, and local resources, but keeps discovered journal entries and recipe knowledge as the roguelite meta-progression layer.
- Storage now has a split behavior:
  - TOOL CHEST is direct physical storage for portable non-NPC cards. Drop a portable card onto the chest to store it, and double-click the chest to withdraw the latest stored card with LIFO behavior.
  - ARCHIVE SHELF is the broad archive container with the overlay list / withdraw UI. It can store portable state-table cards across kinds, including locations, dogs, materials, blueprints, mechanisms, structures, and equipment. Hostile enemy cards are excluded.
- Occupied BROOD CAGE cards now render the captive creature behind the cage art: enemy art is drawn first and the cage bars are drawn over it, while empty cages keep the normal empty-cage look.
- Structure cards no longer use a special provenance-only visual layout. They now use the same normal item card shell language as other portable cards, and only show mechanic-specific state text such as storage counts, tank state, or cage occupancy.
- Captured wolves can now be tamed into dogs. Dropping a BONE card onto an occupied BROOD CAGE that contains a WOLF PACK starts a timed taming bar on the cage. When it completes, success is rolled from operator energy versus captive wolf HP and attack. Success empties the cage and spawns a DOG unit card; failure consumes the bone and leaves the captive wolf in the cage.
- DOG is now a real unit card family on the table. Dogs have energy, HP, base attack, base armor, and the same 3 equipment slots used by other units. They can equip normal equipment cards, be fed with BONE or DRY RATIONS for energy, and be treated with MEDICINE for HP.
- Dogs now participate in table combat through the same collision loop as operator and drones. If a DOG card overlaps an enemy card and has HP and energy remaining, it attacks during the enemy-fight tick, spends 1 energy for that fight, and takes mitigated HP damage back from the enemy based on its armor.
- Enemy roster now includes `WARDEN`, a heavy machine enforcer with high attack, high HP, and real enemy armor. Enemy combat now supports enemy-side armor as a live stat instead of faking toughness through HP alone.
- If a dog is reduced to 0 HP in combat, it dies permanently, is removed from the table, and drops animal loot using its stored source enemy type. Current tamed dogs come from wolves, so they drop the same loot family as wolf-pack animals.
- TANK now lives in the `mechanism` research/card family. Internally it still persists in the old portable-card array for save compatibility, but the live runtime, journal, and table logic treat it as a mechanism rather than a structure.
- The tank now runs as a slow continuous cycle machine with 3 slots:
  - culture slot: ALGAE / BACTERIA / MEALWORMS
  - feed slot: GROWTH MEDIUM or BIOMASS, depending on the cycle
  - recipe slot: a blueprint for FIBER / MEDICINE / DRY RATIONS
- Tank cultures are not consumed. Each completed cycle consumes one unit of feed, keeps the culture and recipe loaded, and spawns one output material. If feed remains, the next cycle starts automatically.
- Current tank cycle mapping:
  - ALGAE + GROWTH MEDIUM + FIBER blueprint -> FIBER
  - BACTERIA + GROWTH MEDIUM + MEDICINE blueprint -> MEDICINE
  - MEALWORMS + BIOMASS + DRY RATIONS blueprint -> DRY RATIONS
- Tank cards now show a compact slot/state summary on-card so the loaded culture, feed, recipe, and running/idle state are readable at a glance.
- Double-clicking a tank is now the stop/unload action. It aborts any active tank batch, clears the batch state immediately, and ejects all loaded tank cards back to the table in one action instead of withdrawing only one slot.
- Journal preview rendering now uses the actual card art for equipment, structures, and mechanisms instead of generic placeholder blocks, so newer card assets show up in the journal once the subject kind is supported.
