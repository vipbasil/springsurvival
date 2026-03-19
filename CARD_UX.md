# Card UX Spec

## Purpose

This document defines the **workshop card language** for the current game, not a generic card-system theory.

It must fit the actual loop:

1. prepare a program on the punch bench
2. create or move tape cards
3. combine tape and power with drone cards
4. drag drones onto the map card
5. recover knowledge through mission results

The workshop is not a deckbuilder board in the abstract. It is a **mechanical worktable** with **physical cards**.

Core rule:

**All movable entities are cards. All fixed infrastructure is machinery.**

Current exception:

- some machinery is represented as **machinery cards** on the table for UX consistency
- those cards still represent infrastructure, not consumable objects

---

## Design Goal

Cards must be:

- immediately readable
- physically movable
- combinable by drag and drop
- low-noise
- consistent across the workshop

Cards must not feel like:

- software windows
- mini dashboards
- inventory tooltips frozen onto paper

---

## Visible Card Classes

Use a **small visible class set** in the workshop.

Do not expose every future simulation category as a first-class visual taxonomy yet.

Visible workshop classes:

1. `Machine`
2. `Agent`
3. `Medium`
4. `Charge`
5. `Material`
6. `Knowledge`

Interpretation for current gameplay:

- `Machine`
  - programming bench
  - route table / map
  - trash / recycler
- `Agent`
  - spider drone
  - butterfly drone
  - later operator if present on the table
- `Medium`
  - programmed tape
  - blank tape
- `Charge`
  - power / spring cards
- `Material`
  - later paper, scrap, biomass, etc.
- `Knowledge`
  - later notes, discoveries, recipes, genetic records

Future internal categories like `Person`, `Construct`, `Creature`, `Place`, `Specimen` may still exist in design/lore, but they should not all become separate visible frame systems immediately.

---

## Card Budget

Every card has a strict information budget.

At a glance, a card may show:

- one class signal
- one main image
- one label if needed
- one numeric or state signal if needed
- one attachment cluster if needed

Do not exceed that unless the card is selected.

This is the main anti-clutter rule.

---

## Universal Card Anatomy

Every card uses the same base frame and proportions.

Shared structure:

1. **Frame**
- same size
- same margins
- same shadow depth
- same border logic

2. **Class marker**
- one small top tab, band, or corner sign
- should identify class quickly

3. **Art field**
- largest area on the card
- should do most of the recognition work

4. **Optional label slot**
- only for cards that need a readable name
- not every card needs a visible title strip

5. **Optional state slot**
- only for one critical number or state
- do not turn this into a mini control panel

---

## Card Reading Order

The player should read cards in this order:

1. what category is this
2. what object is this
3. what state is it in
4. what is attached to it

If the eye is pulled first to tiny badges, numbers, or widgets, the card is wrong.

---

## Class Styling

Class distinction should be light, not overwhelming.

Each class should be identified by:

- one color family
- one suit/icon family

Do not add multiple redundant category systems.

Recommended workshop classes:

- `Machine`
  - muted red paper
  - heavier, more infrastructural feel
- `Agent`
  - dark steel / charcoal body
  - living or active unit emphasis
- `Medium`
  - tan / dossier paper
  - archival / encoded feel
- `Charge`
  - pale gold / paper-gold
  - spring-energy feel
- `Material`
  - neutral grey / brown
  - practical resource feel
- `Knowledge`
  - blue-grey / archive tone
  - document feel

---

## Interaction Rule

If it is an object, you **drag it**.

If it is an action, you **drop onto a target** or use a machine action.

Current workshop interaction model:

- drag tape card onto drone card
- drag power card onto drone card
- drag drone card onto route/map card
- drag deletable cards onto trash card
- click the programming bench card to open the programming scene

This means cards should not need many tiny embedded controls.

---

## Attachments

Attachments are the correct way to represent combined state.

Do not draw mechanical slot widgets into every card.

### Drone card attachments

Drone cards are the main composite cards right now.

A drone card should show:

- drone image
- tape attachment
- power attachment
- mission state

#### Tape attachment

Tape should appear as:

- one attached tag
- one compact label

Not:

- a full second mini-card rendered as a sub-window
- a socket illustration

#### Power attachment

Power should appear as:

- one spring suit
- one accumulated numeric value

Not:

- multiple tiny stacked battery widgets
- a full power card embedded on the drone face

### Machine card state

Machine cards should show only:

- their image
- one ready/blocked/active state if needed

They should not display deep runtime UI on the card face.

---

## Per-Class Rules

### Machine

Examples:

- programming bench
- route table
- bucket

Rules:

- red paper class
- image-forward
- no large numeric overlays
- no busy sub-widgets
- must read as infrastructure, not inventory

### Agent

Examples:

- spider drone
- butterfly drone

Rules:

- darker body
- central image
- attached tags for tape/power
- one mission/state marker only

### Medium

Examples:

- programmed tape
- blank tape

Rules:

- paper-forward
- strong label readability for programmed tape
- punch/tape suit visible
- blank tape should remain simpler than programmed tape

### Charge

Examples:

- spring power card

Rules:

- one spring suit
- one clearly readable value
- no duplicated numbers
- no overdrawn meters unless absolutely needed

### Material

Future:

- scrap
- paper stock
- fungus mass
- reagents

Rules:

- image first
- optional quantity
- minimal UI

### Knowledge

Future:

- notes
- discoveries
- recipes
- genetic records

Rules:

- dossier feel
- title-led rather than image-led when appropriate
- should read as archival, not as a resource

---

## Selection / Hover / Drag

### Hover

Hover should show:

- slight lift
- slight shadow increase
- maybe a thin class-colored edge

Do not show helper text by default.

### Selected

Selection should be used sparingly.

This workshop is becoming drag-first, so selection should not carry too much meaning.

Use selection only when needed for:

- current focus
- current source object
- explicit chosen object for a follow-up action

Selection should appear as:

- stronger border
- maybe one small clip/tab marker

Not:

- large labels like `SELECTED`
- extra explanatory text

### Dragging

Rules:

- card stays full size
- card should not shrink
- valid targets should highlight by whole card/table area
- target logic should be based on overlap, not a tiny hotspot

---

## Gameplay-Specific Constraints

This project is not pure Stacklands. The card UX must support these differences:

### 1. The programming bench is a separate scene

So the bench card is not just a combinable card.

It must:

- look like a machine card
- open a deeper interface when clicked

### 2. Tape is authored content

Programmed tape cards are not generic resources.

They need:

- readable labels
- persistent identity
- archival feel

### 3. Power is additive

Power cards are not attached individually in a visible stack on the drone.

The drone card only needs:

- spring suit
- accumulated power value

### 4. Launch is spatial

The route table/map card is not just a display.

Dragging a drone onto it is a real action:

- launch
- recover
- mission interaction

### 5. Journal and knowledge come later

So the card system must leave room for future `Knowledge` cards without forcing that complexity into the current workshop.

---

## What To Avoid

Do not do the following:

- one custom card layout per object type
- tiny slot boxes on the face
- duplicated numbers
- multiple suits on one card
- heavy helper text
- card faces that behave like windows
- category systems with too many visible classes at once

---

## Current Refactor Priority

The card redesign should proceed in this order:

1. unify all workshop cards under one base frame
2. simplify `Charge` cards
3. simplify `Medium` cards
4. simplify `Agent` cards
5. simplify `Machine` cards
6. only then add future `Material` and `Knowledge` card variants

---

## Final Rule

**A card is a physical object with identity, state, and attachment marks. It is not a miniature software panel.**
