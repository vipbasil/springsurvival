# Refactor Plan

## Purpose

Track the planned split of oversized GDScript files into preloaded helper scripts.

Current targets:
- `scripts/core/GameState.gd`
- `scripts/workshop_main.gd`

Important constraint:
- no fake `include` pattern
- keep `GameState.gd` as the save/state orchestrator
- keep `workshop_main.gd` as the scene controller
- move subsystem rules/builders/runtime helpers into preloaded scripts

## Current Status

- Leak system feature work is live:
  - shelter leak state
  - decay
  - first leak producers
  - leak detector card
  - first encounter weighting
- Structural refactor into helper scripts has started
- Completed so far:
  - leak helper extraction
- Next work should focus on extracting stable subsystems, not adding random new splits

## Order

### 1. Shelter Leak Helpers
Status: `completed`

Goal:
- move leak formulas, decay, and encounter-bias math out of `GameState.gd`

Target helper scripts:
- `scripts/data/ShelterLeakRules.gd`
- `scripts/data/EncounterWeightRules.gd`

Expected result:
- `GameState.gd` keeps persistence/state
- leak math and threat weighting become reusable helpers

Implemented:
- `scripts/data/ShelterLeakRules.gd`
- `scripts/data/EncounterWeightRules.gd`
- `GameState.gd` now delegates leak normalization/decay and encounter weighting to those helpers

### 2. Tank Helpers
Status: `completed`

Goal:
- move tank process specs, slot validation, and cycle matching out of `GameState.gd`

Target helper scripts:
- `scripts/data/TankProcessRules.gd`

Expected result:
- tank process mapping and slot logic stop bloating core state code

Implemented:
- `scripts/data/TankProcessRules.gd`
- `GameState.gd` now delegates tank process specs, slot typing, slot normalization, and batch normalization to that helper

### 3. Journal Builder
Status: `completed`

Goal:
- move journal entry shaping, recipe display states, and related-subject building out of `GameState.gd`

Target helper scripts:
- `scripts/data/JournalEntryBuilder.gd`
- `scripts/data/JournalRecipeState.gd`
- `scripts/data/JournalCrossrefs.gd`

Expected result:
- journal construction logic becomes isolated and easier to change without touching save/runtime code

Implemented so far:
- `scripts/data/JournalRecipeState.gd`
- `GameState.gd` now delegates journal recipe-state and locked-formula masking logic to that helper
- `scripts/data/JournalEntryBuilder.gd`
- `GameState.gd` now delegates journal display-entry assembly, formula-known subject expansion, related-subject building, and locked-entry shaping to that helper
- `scripts/data/JournalCrossrefs.gd`
- `GameState.gd` now delegates journal subject-key mapping and recipe-related subject expansion to that helper

### 4. Workshop Enemy Runtime
Status: `in_progress`

Goal:
- move enemy wander, hostile card interactions, and fight-side table process helpers out of `workshop_main.gd`

Target helper scripts:
- `scripts/ui/WorkshopEnemyProcesses.gd`
- `scripts/ui/WorkshopCombatRuntime.gd`

Expected result:
- workshop scene controller keeps orchestration
- enemy table behavior moves into subsystem helpers

Implemented so far:
- `scripts/ui/WorkshopEnemyProcesses.gd`
- `workshop_main.gd` now delegates hostile card-target selection, hostile action classification, hostile target naming/id lookup, and wander collision clearance to that helper
- `workshop_main.gd` now also delegates enemy fight-state assembly and fight feedback emission to that helper
- `workshop_main.gd` now also delegates enemy interaction-state assembly and wander-candidate assembly to that helper
- `scripts/ui/WorkshopCombatRuntime.gd`
- `workshop_main.gd` now delegates enemy fight leak/outcome assembly and hostile card-interaction resolution to that helper

### 5. Storage Runtime
Status: `in_progress`

Goal:
- move chest/shelf interaction rules and storage modal logic out of `workshop_main.gd`

Target helper scripts:
- `scripts/data/StorageRules.gd`
- `scripts/ui/WorkshopStorageRuntime.gd`

Expected result:
- storage-specific behavior stops being scattered across drag/drop and overlay logic

Implemented so far:
- `scripts/ui/WorkshopStorageRuntime.gd`
- `workshop_main.gd` now delegates storage target selection, withdrawn-card placement dispatch, and storage modal click handling to that helper
- `workshop_main.gd` now also delegates storage container lookup and storage overlay paging/row layout assembly to that helper

Current size snapshot:
- `scripts/workshop_main.gd`: `4444` lines
- `scripts/core/GameState.gd`: `6126` lines

## Progress Notes

- `2026-03-30`
  - decided the split should be subsystem-based, not line-count-based
  - decided the first extraction order is:
    1. leaks
    2. tanks
    3. journal
    4. enemy table processes
    5. storage
  - extracted leak math into:
    - `scripts/data/ShelterLeakRules.gd`
    - `scripts/data/EncounterWeightRules.gd`
  - rewired `GameState.gd` to use those helpers
  - extracted tank rules into:
    - `scripts/data/TankProcessRules.gd`
  - rewired `GameState.gd` to use that helper for tank process lookup, slot normalization, and batch normalization
  - started the journal split by extracting:
    - `scripts/data/JournalRecipeState.gd`
    - `scripts/data/JournalEntryBuilder.gd`
    - `scripts/data/JournalCrossrefs.gd`
  - completed the pure journal split in `GameState.gd`
  - started the workshop enemy runtime split with:
    - `scripts/ui/WorkshopEnemyProcesses.gd`
  - extracted fight-state/combat-side helpers into the same enemy helper
  - extracted interaction-state and wander-candidate builders into the same enemy helper
  - started the dedicated combat helper with:
    - `scripts/ui/WorkshopCombatRuntime.gd`
  - extracted enemy fight leak/outcome assembly and hostile card-interaction resolution into that helper
  - next enemy-runtime substep is either:
    - moving enemy fight/card-interaction cooldown tick orchestration into the combat helper
    - or extracting enemy wander execution next
  - started the storage runtime split with:
    - `scripts/ui/WorkshopStorageRuntime.gd`
  - extracted storage overlay paging, row labels, and button rect layout into `WorkshopStorageRuntime.gd`
  - next storage substep is extracting the storage overlay drawing block or switching to a dedicated combat helper for a bigger `workshop_main.gd` reduction
