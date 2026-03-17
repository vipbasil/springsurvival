# Mechanical Drone Concept Design & Vector Bone Animation Specification

## Purpose

This document defines the **concept design rules and animation pipeline for mechanical drones** used in the game world. These drones are small autonomous machines built using **analog mechanical engineering** rather than advanced electronics.

All drone characters must be designed as **vector-based modular assets** intended for **bone (skeletal) animation**, not raster frame animation.

The goal is to create machines that feel:

- believable
- repairable
- modular
- mechanically understandable
- suitable for a post-electronic technological world

These drones should look like **clockwork machines, mechanical automata, and engineering prototypes**, not futuristic sci-fi robots.

---

# Design Philosophy

The drones must follow three main principles:

### 1. Mechanical Logic

Every visible element should imply a **real mechanical function**:

- gears
- linkages
- springs
- pulleys
- cams
- winding systems
- simple optical sensors

Avoid unexplained smooth surfaces or purely decorative elements.

### 2. Modular Construction

All drones should appear **assembled from replaceable modules**:

- central chassis
- actuator units
- sensor module
- locomotion modules
- cargo tools

This reinforces the idea that the machines are **maintained and repaired in a survival environment**.

### 3. Readable Silhouette

The drone must remain recognizable even when scaled down.

Good silhouettes include:

- walker drones
- spider drones
- rolling scouts
- tracked micro-carriers
- hovering balloon scouts

Avoid shapes that become visually confusing at small size.

---

# Art Direction

## Style

The overall aesthetic combines:

- industrial mechanical devices
- Victorian engineering instruments
- laboratory prototypes
- survival engineering

The visual language should feel similar to:

- mechanical toys
- clockwork devices
- surveying instruments
- field laboratory tools

Not:

- glossy sci-fi drones
- military robots
- AI androids

---

# Materials

Preferred material palette:

- dark iron
- oxidized steel
- brass components
- glass optics
- ceramic insulators
- paper or punch-tape mechanisms

### Example color palette

- iron black `#1c1c1c`
- machine grey `#2b2b2b`
- brass `#b58c4c`
- rust `#8f3a2b`
- aged paper `#d9c9a5`
- signal green `#3dbf6f`

Because assets are vector-based, materials should be represented with:

- layered shapes
- simple shading
- engraved mechanical linework

Avoid painted textures.

---

# Drone Categories

Designers may build multiple drone types following the same structural philosophy.

### Walker Drone

Legged machines using mechanical linkages.

Possible roles:

- exploration
- inspection
- climbing terrain

### Rolling Drone

Wheeled or spherical locomotion.

Possible roles:

- cargo transport
- courier
- fast scouting

### Tracked Drone

Small tracked chassis.

Possible roles:

- heavy hauling
- terrain stability

### Hover / Balloon Drone

Buoyant scout units.

Possible roles:

- observation
- mapping

### Micro Utility Drone

Small repair or maintenance automata.

Possible roles:

- manipulating objects
- resource gathering

---

# Current Workshop Exemplars

The current prototype uses two cabinet drones as style anchors for future designs.

### Mechanical Spider

This drone should read as a **repairable walker**, not a toy creature.

Current visual rules:

- dark steel chassis as the main body
- brass reserved for hardware accents rather than full body panels
- front optical sensor module
- visible spring or service hatch
- four articulated legs per side
- rigid segmented limbs with exposed joints
- crouched industrial silhouette

Use this as the baseline for:

- walker drones
- inspection drones
- climbing utility machines

### Wind-Up Butterfly

This drone should read as a **mechanical toy-instrument hybrid**.

Current visual rules:

- upright central body with visible spring core
- explicit wind-up key at the center of the body
- paper-like wings using the same material language as punch tape
- strong dark outlines and restrained internal rib lines
- small optical head
- decorative but believable mechanical construction

Use this as the baseline for:

- observation drones
- signaling drones
- delicate scout automata

These two examples define an important project rule:

- **body structures are mechanical**
- **surfaces use the established machine materials**
- **ornamental forms must still show a believable actuator or winding logic**

---

# Exterior Functional Elements

Every drone should visually expose parts of its mechanical system.

Include at least several of the following elements:

- winding key
- exposed gears
- mechanical drive shafts
- cable pulleys
- spring tension indicators
- service hatches
- inspection panels
- mechanical sensor eye
- rotating optic lens
- cargo clamp or hook

Optional components:

- punch-tape slot
- indicator lamps
- mechanical gauges
- stamped serial numbers

These features help communicate the drone's function.

---

# Vector Asset Construction

All drones must be produced as **clean vector assets** with separated rigid parts.

### Construction Rules

- each moving element must be its own vector layer
- rigid components should not deform
- joints must be separate pieces
- avoid excessive anchor points

### Suggested Part Structure

Typical drone asset structure:

Main body:

- chassis_core
- chassis_plate_front
- chassis_plate_side_left
- chassis_plate_side_right
- chassis_bottom

Sensors:

- sensor_mount
- optic_lens
- optic_shutter

Mechanisms:

- gear_visible
- gear_cover
- spring_gauge
- winding_key

Locomotion:

Examples depending on drone type:

Legged drone:

- leg_upper
- leg_mid
- leg_lower
- foot

Wheeled drone:

- wheel
- wheel_arm

Tracked drone:

- track
- suspension_arm

Tools:

- cargo_hook
- manipulator_arm

---

# Bone Animation System

The animation system should use **skeletal animation with rigid parts**.

### Animation Principles

- mechanical movement
- precise rotations
- limited elastic deformation
- visible mechanical timing

Parts should rotate around **explicit mechanical pivots**.

Avoid rubber-like bending typical of organic characters.

---

# Rig Structure

Minimum skeleton example:

- root
- body
- sensor
- key

For locomotion modules:

Leg example:

- leg_root
- leg_mid
- leg_lower
- leg_foot

Wheel example:

- wheel_axis

Tool example:

- arm_base
- arm_mid
- arm_claw

---

# Pivot Placement

Correct pivot placement is essential for believable mechanics.

Pivots should be located at:

- hinge joints
- wheel axles
- gear rotation centers
- key rotation axis
- manipulator joints

Bad pivot placement breaks the illusion of a real machine.

---

# Animation Language

Drone movement should feel:

- mechanical
- deliberate
- energy efficient
- spring-driven

Keywords describing motion style:

- tick
- click
- wind
- pause
- tension
- release

Avoid fluid organic movement.

---

# Core Animation Set

Every drone should support a minimal animation library.

### Idle

Subtle mechanical tension.

Possible details:

- tiny vibration
- optic adjustment
- indicator flicker

### Activate

Machine powering up.

Possible actions:

- winding key turn
- gears engaging
- sensor opening

### Move

Primary locomotion animation.

Depends on drone type.

Examples:

- walk cycle
- rolling motion
- track movement

### Turn

Directional change.

Often includes small mechanical pauses.

### Scan

Observation behavior.

Possible features:

- sensor rotation
- optical aperture
- head tilt

### Interact

Interaction with objects.

Possible actions:

- cargo hook
- manipulator arm

### Damage

Low power or malfunction.

Possible effects:

- stuttering movement
- unstable posture

### Shutdown

Complete power loss.

Machine collapses or locks into resting position.

---

# Vector Shading Rules

Because assets are vector-based, shading should remain simple.

Recommended shading style:

- 2-3 tone cel shading
- hard metallic highlights
- small shadow wedges under plates

Avoid heavy gradients unless supported by the entire asset pipeline.

---

# Concept Art Deliverables

Each drone design should include the following sheets.

### Character Sheet

- neutral pose
- clear readable silhouette
- colored design

### Construction Sheet

- exploded modules
- labeled moving parts

### Rig Sheet

- bone locations
- pivot points

### Motion Sheet

- idle pose
- locomotion poses
- interaction pose

---

# Production Pipeline

Recommended workflow:

1. concept sketch
2. mechanical logic pass
3. vector construction drawing
4. part separation
5. pivot placement
6. skeleton rig
7. test animation
8. export to engine

---

# Suggested Tools

Possible software pipeline:

Vector creation:

- Illustrator
- Inkscape
- Figma

Rigging and animation:

- Spine
- Moho
- Creature
- After Effects
- Godot 2D skeleton

---

# Engine Integration

Export assets as:

- layered SVG
- separated vector parts

Requirements:

- consistent naming
- mirrored modules where possible
- shared scale across drones

Runtime states:

- idle
- move
- turn
- scan
- interact
- damage
- shutdown

---

# What to Avoid

Do not design drones as:

- organic animals
- humanoid robots
- sleek sci-fi machines
- complex deformable characters

The design strength should come from:

- clarity
- believable mechanics
- modular construction

---

# Final Statement

Mechanical drones in this project represent **small autonomous machines built from analog engineering principles**.

They should appear as practical devices constructed from gears, springs, and mechanical linkages. Every part must feel purposeful and understandable.

From the beginning, these machines must be designed as **vector-based modular puppets** optimized for **bone animation**, ensuring efficient production and clear mechanical motion.
