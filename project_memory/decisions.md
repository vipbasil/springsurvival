# Decisions Memory

## Finalized Decisions

- Keep DRY RATIONS; remove ENERGY BAR from the active design.
- Use one generic TANK instead of separate tank types for each biological process.
- Use three universal equipment slots on operator and drones.
- Equipment can stack by duplication across those three slots.
- Found gear and crafted gear should resolve into the same equipment card family.
- Research should consume one quantity from the researched card on each attempt when quantity-bearing.
- Titles belong in the top band of cards.
- Punch tape should be differentiated by physical commitment, scarce media, repair, and machine-specific capability, not by raw binary memorization alone.
- Program labels should be user-authored on the typewriter: no default label, editable directly from keyboard input.
- Journal pages should use a fixed structure: index first, subject sections on the left page, paginated recipes on the right page, and clickable related-subject cross-references instead of one flowing mixed text block.
- Journal recipe state is derived live from known subjects: only complete formulas can be copied into blueprints, while partial formulas stay visible with ?? placeholders for unknown requirements.
- Enemy pages should be researched from occupied cages only; loose enemy cards are not journal research subjects.
- Cages should behave as persistent containers: empty or occupied, storable without losing the captive, and releasable by double-click when occupied.
- Capturing an enemy should not be instant: enemy and cage contact starts a progress-bar capture process, and failed capture destroys the cage.
- Complete formulas now reveal their result subject pages in the journal, even without direct item research. This prevents recipe outputs like GROWTH MEDIUM from staying permanently masked after all ingredients are known.
- Crafted structures should be first-class journal subjects, not recipe-only outputs. TANK and the storage/cage structures need their own pages and recipe cross-references.
- Treat the route table as the live map and a core mechanic surface, not as a passive machine illustration. Map readability and interactions on it are gameplay-critical.
- The run should start with an Ark-side operator choice: present 3 operators, then deploy the selected one into the starter shelter on Earth.
- Use the previously agreed warm starter shelter package instead of a zero-resource start. The opening should let the player launch drones, read the journal, and begin the first biology/paper loop without dead time.
- Initial operator selection should use 3 distinct starter biases without changing the core shelter package, drone count, max HP, max energy, or slot count. Differences should come from equipped gear, a few extra resources, and a few extra known or partial journal pages.
- The current implemented Ark selection uses one shared portrait for all operators. Distinction comes from profile name/focus text, equipped starter item, extra resources, and seeded journal knowledge.
- Operator portraits should read as 40+ Ark survivors: visibly tired, worn, rationed, and weathered. Avoid youthful or glamorous faces even when the graphic style is simplified.
- Run end should return to the Ark selection flow, not trap the player inside a dead shelter state. Redeployment is the restart UX.
- Knowledge must persist between runs. Journal discoveries and learned formulas are the roguelite carryover; shelter state and local inventory are not.
- TOOL CHEST and ARCHIVE SHELF should not share the same interaction model. TOOL CHEST is direct card-native storage: drop portable non-NPC cards onto it to store them, and double-click it to withdraw the most recently stored card via LIFO. ARCHIVE SHELF keeps the explicit overlay browsing model.
- Generated card art should target an old minimalist flat-color poster look: hyper minimal, geometric, clean silhouette, poster-like flat illustration, pure white background only, and a strict max-4-color palette. Default palette: deep navy `#1F2A44`, parchment cream `#F2E9DA`, burnt ochre `#D9822B`, soft steel gray `#8A8F98`. No gradients, glows, vignettes, soft shadows, or extra colors. Hard-edged flat highlight and shadow planes are desired and are one of the key style traits; what is forbidden is soft airbrushed shading, not poster-style tonal blocks. Shapes should stay flat and vector-friendly so outputs can be cleaned and converted to SVG with minimal path complexity.
- For image generation, use these four reference images together as the default style pack unless explicitly overridden:
  - `/Users/vasilibraga/Downloads/5j3eWWkFs2HxE02P (1).png`
  - `/Users/vasilibraga/Downloads/moplvuKVOuQqyqhk (1).png`
  - `/Users/vasilibraga/Downloads/O2lu5iSUUeodLYPC (1).png`
  - `/Users/vasilibraga/Downloads/Ypmew12z4TnajY2l (1).png`

- Operator portraits should read as 40+ Ark survivors who are tired but determined: worn and rationed, not youthful, but also not defeated or melodramatically sad.

- Operator portraits should keep hair mostly deep navy, with only a small soft-steel-gray accent plane at a temple, hairline, or beard edge to suggest age. Do not turn the whole hair mass gray.
- Operator portrait facial features must survive minimization on cards. Wrinkles, brow masses, under-eye folds, mouth folds, and cheek planes should be drawn as a few broad flat poster shapes, not thin delicate lines that disappear at small size.
- Operator portraits must share one consistent framing format: front-facing head-and-shoulders bust, upper chest visible, shoulders included, centered on white, no vignette, no floating head-only crop, and no oversized torso/document-photo drift.
- Operator portraits may use a few small soft-steel-gray hair strays or accent streaks, but only as subtle flat planes inside otherwise deep-navy hair.
