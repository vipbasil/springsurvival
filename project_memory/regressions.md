# Regression Traps

- Prediction/simulation paths must not trigger real world side effects such as salvage drops, encounters, or return commits.
- Content can exist in JSON catalogs but still fail to appear in play if generation/runtime tables are not updated.
- Assets can exist in `assets/cards/` but still not render if `WorkshopArt.gd` still points to an old helper path or special-case drawing branch.
- Save-state inconsistencies can leave drones logically active while already at shelter; normalize bot mission state carefully.
- Journal and blueprint formulas can disappear if runtime recipe lookup returns raw catalog entries with `parts` instead of normalized `formula_parts`. Keep `_get_loaded_recipe_by_id()` normalized, or journal pages and saved blueprints rebuild as `RESULT =` with empty bodies.
- After the `power_unit` refactor from legacy resource cards to `material` cards, bot `power_charge` must be clamped to `max_power_charge` during save-load normalization. Old saves can otherwise end up with overfilled drones, which makes the charge machine appear broken because it finds no valid target to refill.
- The bench-craft matcher in `workshop_main.gd` must recognize every live material token used in recipe formulas. If `_parse_material_requirement()` lags behind the recipe catalog, valid stacks like `BACTERIA = BIOMASS + GROWTH MEDIUM` will never start even when the cards are arranged correctly.
- Material merging should not trust only the stale drag snapshot for freshly spawned or tank-produced cards. Merge target checks should use live material state by id and a forgiving overlap/center test, or newly generated materials can fail to stack when dropped onto an existing card of the same type.
- Material generation should use the same merge rule as manual dragging. If a newly spawned material lands on a same-type material card, it should auto-merge immediately instead of creating a separate overlapping stack.

## Journal Formula Rendering

- Journal recipe cards can look empty even with valid formula payloads if the UI relies on a fragile wrapped formula string. Prefer rendering from normalized formula parts when drawing the recipe body.
