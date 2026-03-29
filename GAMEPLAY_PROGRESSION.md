# Gameplay Progression

This file describes the current implemented progression of `Last Spring` as it exists now.

It is not a long-term fantasy roadmap.
It is the practical answer to:

- what the player starts with
- what they can do first
- what loops open next
- what the current build can eventually become
- where the current ceiling stops

## 1. Starting State

A fresh run starts with Ark deployment.

The player:
- chooses `1` of `3` operators:
  - `OP. LERA`
  - `OP. MIRA`
  - `OP. DREN`
- the chosen operator materializes into the starter shelter

All runs start from the same warm shelter baseline, plus the chosen operator bias.

### Shared Starter Shelter

- `Operator` at full HP / energy
- `Spider Drone`
- `Butterfly Drone`
- `3` blank tapes
- `1` short demo tape
- `Power Unit x100`
- `Metal x2`
- `Biomass x2`
- `Fiber x2`
- `Paper x1`

### Shared Starter Knowledge

The journal starts with these core known pages:
- `FIELD`
- `POND`
- `FIBER`
- `BIOMASS`

Knowledge persists between runs. Shelter cards and local resources do not.

## 2. First Practical Actions

From a clean start, the first real things the player can do are:

1. inspect the shelter table
2. read the journal
3. choose a drone
4. load power into the drone
5. load a tape into the drone
6. send the drone through the `Route Table`
7. return with discoveries or salvage
8. research discovered subjects in the `Journal`
9. copy blueprints from complete recipes
10. begin crafting and biology loops

So the earliest gameplay is:
- scout
- discover
- research
- blueprint
- craft
- stabilize the shelter

## 3. Early Progression

The first coherent progression layer is field and pond biology.

### Early Gather / Research Targets

- `FIELD`
  - reveals `FIBER`
- `POND`
  - leads into `ALGAE`
  - leads into `MUSHROOMS`
- `BIOMASS`
- `FIBER`

### First Important Craftables

- `PAPER`
  - from `FIBER`
- `DRY RATIONS`
  - from `BIOMASS + FIBER`
- `MEDICINE`
  - from `BIOMASS + FIBER + BONE`
- `GROWTH MEDIUM`
  - from `BIOMASS + FIBER`

### What This Unlocks

Once `GROWTH MEDIUM` exists, the player can begin biological branching:
- `POND + GROWTH MEDIUM -> ALGAE`
- `POND + GROWTH MEDIUM -> MUSHROOMS`
- `BIOMASS + GROWTH MEDIUM -> BACTERIA`
- `BIOMASS + FIBER -> MEALWORMS`
- `BONE -> BONE MEAL`

This is the first real survival transition:
- from scavenged basics
- into controlled biological production

## 4. Tape And Drone Progression

Parallel to the material loop, the player expands drone capability.

### Drones

- `Butterfly Drone`
  - scout / passive survey
  - best for scanning and revealing locations

- `Spider Drone`
  - salvage / pickup / combat
  - best for field extraction and hostile contact

### Tape Progression

The player can:
- use the starter tape
- write new tapes
- duplicate utility through more blank tapes
- craft `FRESH TAPE` from `PAPER`

This means a stable paper loop supports:
- more programmable behavior
- more reusable drone capability
- more reliable outside action

## 5. Midgame Shelter Expansion

After early biology and first tape stability, the player can start building shelter infrastructure.

### Structure / Mechanism Unlocks

From discovered locations and recipes, the player can eventually build:

- `TOOL CHEST`
- `ARCHIVE SHELF`
- `BROOD CAGE`
- `TANK`

And equipment:
- `KNIFE`
- `BOW`
- `PLATE MAIL`
- `HIDE CLOAK`
- `TOOL KIT`

These are the important shifts:

- `TOOL CHEST`
  - direct physical LIFO storage for portable cards

- `ARCHIVE SHELF`
  - broad archive storage for portable non-hostile cards

- `BROOD CAGE`
  - enemy capture and enemy research

- `TANK`
  - slow repeating biology mechanism

## 6. Enemy / Capture Progression

The next layer is not only combat. It is controlled enemy handling.

### Enemy Flow

- encounter enemies on the table
- fight them with operator / drones / dog
- or capture them into `BROOD CAGE`

### Cage Research

An occupied cage can be:
- stored
- placed on the journal
- researched as enemy knowledge
- released back to the table

This turns enemies from:
- immediate threat

into:
- research subject
- loot source
- taming source in the wolf case

## 7. Dog Progression

One current midgame branch is animal taming.

### Dog Unlock

- capture `WOLF PACK` in a cage
- drop `BONE` onto the occupied cage
- start the taming process
- on success, gain a `DOG` card

### Dog Role

`DOG` is a real unit card.

It has:
- energy
- HP
- attack
- armor
- `3` equipment slots

It can:
- wear normal equipment
- gain energy from `BONE`
- gain energy from `DRY RATIONS`
- gain HP from `MEDICINE`
- join combat when colliding with hostile enemy cards

If killed, it dies permanently and drops animal-style loot.

So the dog branch gives the player:
- another combat body
- another equip target
- another upkeep loop

## 8. Tank Progression

The tank is the current deepest shelter-production mechanism.

It uses:
- `1` culture slot
- `1` feed / support slot
- `1` recipe blueprint slot

The recipe stays loaded.
The culture stays loaded.
Only the feed or support rules determine ongoing production.

### Current Tank Outputs

#### Fiber Line

- culture: `ALGAE`
- support: `GROWTH MEDIUM`
- blueprint result: `FIBER`
- cycle is slow
- `GROWTH MEDIUM` is not consumed

#### Biomass Line

- culture: `MUSHROOMS`
- support: `GROWTH MEDIUM`
- blueprint result: `BIOMASS`
- cycle is slow
- `GROWTH MEDIUM` is not consumed

#### Medicine Line

- culture: `BACTERIA`
- feed: `BIOMASS`
- blueprint result: `MEDICINE`
- `BIOMASS` is consumed
- this is the slowest current tank process

#### Dry Rations Line

- culture: `MEALWORMS`
- feed: `BIOMASS`
- blueprint result: `DRY RATIONS`
- `BIOMASS` is consumed
- this is faster than medicine

### What Tank Progression Means

The tank is the point where the player moves from:
- manual one-shot crafting

to:
- slow repeating shelter-side biological production

This is the strongest current “automation-like” loop in the build.

## 9. Journal Progression

The journal is the meta layer and the real persistent progression.

It currently supports:
- index page
- subject pages
- structured notes
- related subjects
- recipe visibility
- locked / partial / complete formula states
- blueprint copying from complete recipes

### Practical Journal Progression

The player expands from:
- a few known starter pages

toward:
- locations
- materials
- equipment
- enemies
- structures
- mechanisms

And because knowledge persists across runs, this is the real roguelite carryover.

The shelter can fail.
The journal remains.

## 10. Current Strongest Full Loop

The most complete current loop in the build is:

1. choose operator
2. power and program drones
3. scout / scavenge locations
4. bring back materials and knowledge
5. research in journal
6. copy blueprints
7. craft survival supplies and shelter infrastructure
8. capture and study enemies
9. tame wolves into dogs
10. build tanks
11. convert biology into repeated food / medicine / fiber / biomass production
12. craft more tapes and expand drone action

That is the closest thing to the current “full game loop”.

## 11. Maximum Currently Achievable State

The current implemented ceiling is not a final victory condition.

There is no finished “repopulate Earth” win state yet.

The current maximum reachable condition is:

- one active shelter run with:
  - a chosen operator
  - powered and equipped drones
  - a trained dog
  - working tape supply
  - broad journal knowledge
  - enemy cage handling
  - storage structures
  - tank biology running continuously
  - sustainable production of:
    - `Fiber`
    - `Biomass`
    - `Dry Rations`
    - `Medicine`

- plus persistent cross-run knowledge in the journal

So the current ceiling is:
- a stable, informed, biologically productive shelter-table ecosystem
- not yet an endgame narrative resolution

## 12. What The Current Build Still Does Not Fully Reach

Important limit:

- there is no final macro-goal resolution yet
- there is no completed Earth-restoration ending
- there is no fully finished late-game faction / network / settlement layer

So the current build is strongest as:
- survival progression
- shelter logistics
- research accumulation
- low-tech automation
- card-native biology / storage / combat loops

Not yet as:
- complete endgame campaign
- final world-state solution

## 13. Short Summary

From zero, the player currently progresses like this:

- start with one operator, two drones, basic resources, and a little knowledge
- discover locations and salvage
- research what is found
- unlock recipes and blueprints
- craft food, medicine, paper, tapes, storage, and equipment
- capture enemies and build cages
- tame wolves into dogs
- build tanks
- shift into slow biological production
- stabilize the shelter while keeping the journal as permanent meta-progression

The current maximum is not a win screen.
It is a well-functioning shelter system with persistent knowledge and several interlocking production/combat/research loops running together.
