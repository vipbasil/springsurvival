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
- Journal: research and recipe discovery
- Journal now has an index page, structured drone/location note sections, paginated recipe display on subject pages, clickable related-subject cross-references, and live recipe states: locked / partial / complete.
- Enemy research now runs through cages, not loose enemy cards: an occupied cage is a persistent crafted container that stores a captive enemy, can be placed on the journal for research, and can release the captive back to the table.
- Enemy capture is now a timed cage process started by overlapping an enemy card and an empty cage in either direction. Success is rolled against current operator energy versus enemy HP and attack; failure destroys the cage and leaves the enemy free.
- Blueprint: craft authorization and formula carrier
- Tank: small legible bio-processing machine
- Journal knowledge now has two visible sources: direct research entries and formula-derived subject knowledge. If a recipe becomes complete, its result page is revealed for browsing and cross-reference.
- Journal now has crafted-structure subject pages too: TANK, TOOL CHEST, BROOD CAGE, and ARCHIVE SHELF can appear as real journal pages and cross-reference from their recipes.
- Route table: this is the actual map surface, not just a decorative machine card. It is a core mechanic layer for route reading, mission targeting, map feedback, and outside-world state.
- Fresh no-save runs now begin with an Ark deployment choice between 3 operators. The selected operator is stored in operator_state, then materializes into the starter shelter on Earth.
- Current implemented starter shelter package for that selected operator:
  - operator at full HP / energy
  - spider drone
  - butterfly drone
  - 3 blank tapes
  - 1 short programmed demo tape
  - 2 power units
  - starting materials: metal x2, biomass x2, fiber x2, paper x1
  - starting discovered journal pages: FIELD, POND, FIBER, BIOMASS
  - starter journal is seeded with FIELD, POND, FIBER, BIOMASS plus operator-specific known subjects
  - current demo tape is START LOOP: SCN, MOV, ROT 4, DIE
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
- Current implementation uses the same portrait art for all three operators. The differentiation is name, focus, starter gear, extra materials, and seeded knowledge.
- If a shelter run ends with the operator dead, the game now returns to the Ark deployment flow instead of leaving the player in a dead workshop state. The same 3-operator selection overlay is reused as redeployment.
- Journal knowledge is persistent between runs. Redeployment resets the shelter state, cards, and local resources, but keeps discovered journal entries and recipe knowledge as the roguelite meta-progression layer.
- Storage now has a split behavior:
  - TOOL CHEST is direct physical storage for portable non-NPC cards. Drop a portable card onto the chest to store it, and double-click the chest to withdraw the latest stored card with LIFO behavior.
  - ARCHIVE SHELF remains the browsable storage container with the overlay list / withdraw UI.
