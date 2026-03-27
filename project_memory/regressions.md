# Regression Traps

- Prediction/simulation paths must not trigger real world side effects such as salvage drops, encounters, or return commits.
- Content can exist in JSON catalogs but still fail to appear in play if generation/runtime tables are not updated.
- Assets can exist in `assets/cards/` but still not render if `WorkshopArt.gd` still points to an old helper path or special-case drawing branch.
- Save-state inconsistencies can leave drones logically active while already at shelter; normalize bot mission state carefully.
- Journal and blueprint formulas can disappear if runtime recipe lookup returns raw catalog entries with `parts` instead of normalized `formula_parts`. Keep `_get_loaded_recipe_by_id()` normalized, or journal pages and saved blueprints rebuild as `RESULT =` with empty bodies.

## Journal Formula Rendering

- Journal recipe cards can look empty even with valid formula payloads if the UI relies on a fragile wrapped formula string. Prefer rendering from normalized formula parts when drawing the recipe body.
