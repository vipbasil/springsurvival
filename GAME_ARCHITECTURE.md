# Game Architecture Notes — Last Spring

This file captures the current high-level product and systems decisions that should guide implementation.

It is intentionally short and practical. If a future feature conflicts with this file, treat this file as the working design default until a newer decision replaces it.

---

## 1. Core Game Definition

**Last Spring** is a knowledge-driven mechanical and biological survival roguelite.

The player selects an operator from the Ark, enters an Earth shelter, prepares mechanical drones through punch-tape programming, explores the outside world indirectly, and preserves only what can be recorded before the deployment fails or ends.

The game is built on three equal progression pillars:

- mechanical knowledge
- world / cartographic knowledge
- biological / genetic knowledge

Material tools are finite.
Knowledge is the main durable victory.

---

## 2. Run Structure

A run is one **Earth deployment cycle**.

Recommended structure:

1. Select an operator on the Ark
2. Enter a shelter workshop
3. Create / store / load punch-tape cartridges
4. Install power into drones
5. Launch drones into the outside world
6. Observe routes, discoveries, and failures
7. Record useful knowledge in the journal
8. End the run through failure, collapse, evacuation, or deliberate closure

### Run Persistence Rule

By default, only **recorded knowledge** persists between runs.

This includes:

- journal entries
- discovered categories and interpreted findings
- archived program records as knowledge
- map knowledge
- operator notes
- biological and genetic records

This does **not** include by default:

- physical cartridges
- shelf stock
- bot loadouts
- installed power units
- local material state of the shelter

---

## 3. Layer Separation

The game has four top-level layers.

### Ark Layer

Purpose:

- choose the next operator
- frame the deployment
- expose strategic long-term R&D direction

### Workshop Layer

Purpose:

- physical preparation
- programming
- cartridge and power handling
- bot launch

### Route Table Layer

Purpose:

- live operational display
- show what active bots are doing now
- show predicted vs executed movement
- show detected site presence before durable knowledge is recovered

### Large Map Layer

Purpose:

- strategic Earth planning surface
- place and review landmarks, routes, sites, risks

### Journal Layer

Purpose:

- canonical knowledge archive
- manual and automatic record keeping
- cross-run progression

Short rule:

- route table = what is happening now
- large map = what we think the world looks like
- journal = what we know, believe, and preserve

### Scan And Return Rule

Scanning should follow one strict knowledge rule:

- scan detects whether a site exists in scanned territory
- scan may partially classify that site
- scan does not immediately create durable location cards
- successful return converts pending mission intel into persistent location cards and journal/map knowledge

This applies to both drones and operators, with one difference:

- drone scan is safer and lower-fidelity
- direct operator scan is richer but can trigger immediate encounters such as hostile creatures or hazards

---

## 3A. Entity Form Rule

The project uses one strict interaction and presentation rule:

**All movable entities are cards. All fixed infrastructure is machinery.**

### Cards

Cards are used for anything that can be moved, stored, stacked, archived, or assigned.

Examples:

- drones
- cartridges
- power units
- saved programs
- discoveries
- biological samples and cultures
- genetic strains
- operator profiles

Cards are the default form for:

- inventory
- drag and drop
- assignment
- workshop composition
- archival knowledge objects

### Composite Drone Cards

Drone cards are not just identity cards. They are **composite cards** that accumulate loadout state.

Recommended rule:

- one drone card may carry **one tape assignment**
- one drone card may carry **multiple power cards**
- attached power values are **additive**

This means the workshop preparation loop should read as:

- drag a tape card onto a drone card
- drag one or more charged power cards onto the same drone card
- launch only after the drone card shows both a tape assignment and positive total power

### Tape Assignment Rule

Tape should not remain a second loose object once assigned.

Instead:

- the tape card is consumed into the drone card loadout
- the drone card then shows a visible tape label, badge, or symbol

The player should read the drone card as “this drone is carrying program X”.

### Power Card Rule

Power cards are additive charge objects.

- each charged power card adds its charge to the drone card
- multiple power cards may be attached
- when power is exhausted, the card is spent
- an empty power card should not be treated as a valid loadable unit

The player should read the drone card as “this drone is carrying N total power”.

### Machinery

Machinery is used for anything that is fixed, installed, or spatially rooted in the shelter or Ark.

Examples:

- programming bench
- route table
- large map table
- recycle press
- reactors
- storage racks
- cabinets

Machinery is the default form for:

- stations
- launch systems
- processing devices
- fixed displays
- shelter infrastructure

### Design Consequence

If an interaction can be expressed either as:

- clicking tiny shapes inside a machine
- or moving a card onto a machine

prefer the card version unless the action is clearly a machine-only action such as:

- launch
- recover
- open bench
- activate reactor

So in the workshop:

- assign tape by moving a tape card onto a drone card
- assign power by moving one or more power cards onto a drone card
- use fixed machine controls only for machine actions such as launch and recovery

---

## 4. Main Victory Currency

The main victory currency is **preserved operational knowledge**.

That knowledge has three equal branches:

- mechanical / programming knowledge
- Earth / route / discovery knowledge
- biological / genetic knowledge

Resources, drones, and shelter systems matter because they allow the player to produce knowledge under dangerous conditions.

They are not the ultimate long-term score by themselves.

---

## 5. Operator Selection

Operator selection is a **strategic research choice**, not a combat-class choice.

### Design Rule

**Operator = research lens for the run**

Each operator should begin with:

- different starting journal knowledge
- different practical familiarity with systems
- different research biases
- different notes, interpretations, or archival priorities

### Example Operator Biases

- mechanical programming
- field surveying / cartography
- insect farming
- fungal cultivation
- bacterial / algal systems
- genetics / strain selection
- repair / salvage engineering
- stealth / low-signature survival

### What Operator Choice Should Change

- what the player understands earlier
- what research paths advance faster
- what records are easier to interpret
- what kinds of discoveries are more valuable in that run

### What Operator Choice Should Not Primarily Be

- raw combat stats
- generic RPG strength/dexterity classes
- arbitrary numerical bonuses detached from the fiction

---

## 6. Journal Definition

The journal is the main roguelite progression layer.

It is both:

- archive
- laboratory notebook
- run history
- codex

### Journal Domains

The journal should eventually store at least:

- Earth observations
- discovered places
- discovered object classes
- route records
- programming-language knowledge
- known instruction meanings
- previously created programs as archived knowledge
- biological systems knowledge
- genetic / strain knowledge
- operator notes
- Ark / cryo-bank / deployment records

### Journal Entry Types

The system should support:

- automatic factual entries
- player-edited notes
- operator-authored notes
- linked records between map, program, and biology domains

---

## 7. Biology As A First-Class Pillar

Biology is not secondary flavor. It is one of the three core progression pillars.

### Biological Knowledge Domains

- algae reactors
- insect farming
- mushroom systems
- bacterial cultures
- bioluminescent cultures
- later genetics / strain selection / gene alteration

### Biology In The Game

Biology should eventually support:

- food
- oxygen
- waste reduction
- stealth / low-signature survival
- shelter resilience
- long-term adaptive research

### Important Rule

The game is not “mechanics first, biology later.”

It is a **bio-mechanical survival civilization**.

---

## 8. Detection / Stealth Rule

Earth survival is constrained by residual orbital detection.

Important signature types:

- heat
- CO2
- noise
- magnetic anomalies

This means low-signature survival is a systems rule, not only flavor.

It should eventually influence:

- shelter design
- machine choice
- field operations
- biology loops
- waste handling

---

## 9. Bot Execution Rule

There should be **one canonical tape interpreter**.

The same instruction semantics should govern:

- programming-scene execution
- route prediction
- outside bot execution

Different scenes may present the data differently, but they should not invent separate program logic.

---

## 10. Product-Level Core Loop

The intended top-level loop is:

1. Choose operator on the Ark
2. Enter workshop
3. Program and store cartridge
4. Load cartridge into bot
5. Install power
6. Launch bot
7. Observe route and discoveries
8. Interpret results on map and in journal
9. Preserve knowledge
10. Lose the run, keep the record, deploy again

Within that loop:

- preparation and assignment should increasingly happen through cards
- execution and monitoring should happen through machinery

---

## 11. Long-Term Direction

The long-term world progression should support:

- better understanding of Earth
- richer program archives
- stronger biological systems
- genetic and strain knowledge
- operator specialization
- cryo-bank / deployment continuity
- later colony-network or distributed knowledge growth

The future civilization should not grow primarily through stockpiled items.

It should grow through **better preserved knowledge and better system understanding**.

---

## 12. Working Design Principles

When a future feature is ambiguous, prefer the version that:

- makes knowledge more valuable than material
- keeps machines physical and finite
- preserves readable mechanical causality
- supports low-signature survival
- treats biology as equal to mechanics
- makes operator choice about understanding, not power fantasy
- strengthens the journal as the true persistence layer
