# Art Style Guide — Mechanical Survival Game

## Style Name
**Analog Apocalypse**

A visual language combining:
- Victorian engineering manuals
- Early computing machines
- Cold-war technical diagrams
- Mechanical steampunk survival

The world feels **post-electronic**, rebuilt with **mechanics, biology, and low-energy systems**.

---

# Core Principles

1. **Mechanical logic**
2. **Biological survival**
3. **Zero-waste stealth**
4. **Repairable machines**
5. **Human ingenuity over technology**
6. **Movable entities are cards; fixed entities are machinery**

The aesthetic should reflect a civilization forced to rebuild without electronics after orbital EMP warfare.

---

# Interaction Form

The project uses one strong visual rule:

**All movable entities are cards. All fixed infrastructure is machinery.**

Use this rule whenever interaction design is ambiguous.

### Cards

Cards represent portable, movable, archivable, or combinable things such as:

- drones
- cartridges
- power units
- discovered objects
- biological cultures
- genetic strains
- operator profiles
- saved program records

Cards should feel like:

- specimen plaques
- punched dossier cards
- brass-framed tags
- archival slates

They may stack, move, combine, and be placed onto machines or zones.

For drone cards specifically:

- the drone image sits on the card face
- tape assignment appears as a badge, strip, or label on the card
- power appears as added pips, cells, or charge markers on the card
- the card should visibly accumulate loadout state without turning back into a mini dashboard

### Machinery

Machinery represents fixed shelter infrastructure such as:

- programming bench
- route table
- large map table
- recycle press
- biological reactors
- cabinets
- racks

Machinery should feel mounted, heavy, repairable, and spatially rooted.

### Important Constraint

Do not solve movable-entity UX with tiny embedded widgets when a card metaphor would be clearer.

Preferred interaction grammar:

- move a card
- place a card on a machine
- place a card back into storage
- press a machine button for machine actions

Extended workshop rule:

- place a tape card onto a drone card to assign its program
- place one or more charged power cards onto a drone card to increase total power
- do not use tiny embedded slot widgets where a card composition read would be clearer

---

# Color Palette

Minimal, industrial, survival-oriented.

| Color | Use |
|-----|-----|
| `#1c1c1c` | background / void |
| `#2b2b2b` | machines / UI panels |
| `#b58c4c` | brass components |
| `#d9c9a5` | paper / punch tape |
| `#3dbf6f` | biological energy |
| `#8f3a2b` | danger / waste |

Tone: **muted, oxidized, functional**

---

# UI Style

Interface must look **physical and mechanical**, not digital.

Elements:

- gauges
- rotating drums
- punched tape
- mechanical meters
- indicator lights
- spring power meters

The workshop should read as a **tabletop of cards and machines**, not a dashboard of abstract panels.

Example:

```text
Energy
[==== SPRING GAUGE ====]

Waste
[//// pressure tube ////]

Program
● ○ ● ○ ○
```

Your prototype terminal UI already follows this direction.

---

# Materials

Machines should appear **repairable and handcrafted**.

Primary materials:

- brass
- iron
- wood
- leather belts
- glass tubes
- paper tape

For cards and slates, also use:

- punched paper
- lacquered card stock
- brass edge frames
- stamped labels
- wax-pencil annotations

Common components:

- gears
- flywheels
- cams
- wound springs
- pulleys
- mechanical sensors

---

# Machines

Automation relies on **mechanical computation**.

Machines include:

- punch-tape computers
- wind-powered winders
- water-driven gear systems
- animal traction engines

Programming occurs through **punch tape logic systems**.

Machines are fixed stations. They should not visually impersonate portable inventory.

---

# Automaton Design

Robots resemble **mechanical animals**.

Examples:

- mechanical spider
- wind-up butterfly
- mechanical crab

Design traits:

- thin articulated brass legs
- exposed gears
- spring cores
- bio-luminescent eyes
- fragile but ingenious construction

---

# Biological Systems

Food and energy come from **closed biological loops**.

Key systems:

| System | Visual |
|------|------|
| algae reactor | glowing green glass tubes |
| insect farms | stacked wooden trays |
| mushroom chambers | damp cave racks |
| bio-lights | bioluminescent bacteria bulbs |

These support the **zero-waste stealth survival economy**.

---

# Programming Aesthetic

Programming must feel **physical and tactile**.

Visual elements:

```text
Punch Tape
● ○ ● ○ ○

Registers
ACC | PTR

Rotating logic drum
```

Feedback examples:

- tape scrolling
- mechanical relays clicking
- scanning heads reading holes

Programs may also appear as archived program cards in the journal/workshop, but execution still happens through machinery.

---

# Map Style

Avoid modern digital minimaps.

Preferred style:

- graph paper
- ink lines
- mechanical pointers
- ASCII mapping

Example:

```text
·  ·  ×  ·
·  ↑  ×  ·
·  ×  ×  ·
```

The ASCII map prototype already supports this aesthetic.

---

# Environment Design

World characteristics:

- ruined industrial landscapes
- abandoned infrastructure
- fungal forests
- algae ponds
- wind towers
- scrap-based shelters

Color tone:

- cold gray earth
- rusted metal
- faint biological glow

---

# Animation Style

Movement should feel **mechanically constrained**.

Examples:

- gear rotation
- spring unwinding
- valve opening
- tape advancing
- mechanical walking cycles

Avoid smooth digital animation.

---

# Inspirations

Visual references:

- Frostpunk
- Machinarium
- Oxygen Not Included
- Scavengers Reign
- Sunless Sea
- Dishonored concept art

Historical references:

- Jacquard loom
- player piano
- Soviet engineering manuals
- early computer terminals
- Apollo mission diagrams

---

# Mood

The atmosphere should feel:

- quiet
- fragile
- patient
- tense
- ingenious

The main tension comes from **surviving invisibly under orbital surveillance**.

---

# Recommended Rendering Style

Best options:

### Option A (Recommended)
**Illustrated technical diagrams**

Mix of:
- hand-inked machines
- schematic overlays
- engineering drawings

### Option B
Low-poly mechanical diorama

### Option C
Pixel-art engineering manual

---

# Art Direction Summary

**Mechanical survival civilization**

Key visual identity:

```text
hand-drawn machines
ASCII diagnostics
punch tape programming
biological reactors
mechanical automatons
```

Technology feels **repaired, improvised, and mechanical**, never digital.
