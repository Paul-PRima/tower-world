# Changelog

All notable changes to this project are documented here, newest first. Each entry notes who made the change: **(Claude)** for AI-driven edits, **(User)** for manual edits made directly in the Godot editor or elsewhere.

## 2026-07-10

### Fixed
- Restored the `InputEventMouseMotion` type guard in `player.gd`'s `_unhandled_input`, which had been accidentally deleted along with the Escape-to-release-mouse handling during a manual edit, breaking mouse look entirely. (Claude)
- Crosshair `ColorRect`s (`HBar`/`VBar`) were left at the default `MOUSE_FILTER_STOP`, so sitting at screen center — right where the captured cursor sits — they silently swallowed every mouse-motion event before `_unhandled_input` saw it, which was the real remaining cause of mouse look not working. Set `mouse_filter = 2` (ignore) on both. (Claude)

### Added
- Underground parkour: shrank the underground hub floor to 44x44 (just enough to safely hold the 4 tower landing spots + return pad) and added 4 procedurally-generated platform courses (`parkour_challenge.gd`, one per tower direction, mirrors the `forest.gd`/`spiral_stairs.gd` procedural-generation pattern) extending out over open void, each ending in a glowing pickup item (`item.gd`/`scenes/item.tscn`). Falling off a platform is caught by a large `fall_reset.gd` volume under the whole layer, which works out which challenge you fell from by X/Z quadrant and teleports you back to that tower's landing spot. `GameState` now tracks collected items and fires `all_items_collected` once all 4 are found; a new `hud.gd` on the player's HUD shows a "Well Done!" overlay (dismiss with Esc) when that happens. (Claude)
- Interactive trees: pressing E near a tree launches it into the air with a random impulse/spin and plays an interact sound (empty slot, assign later), then despawns it after 3s. Reworked `tree.tscn`'s root from `StaticBody3D` to a frozen `RigidBody3D` (`tree.gd`) so it stays static like before until triggered, then unfreezes to fly off. (Claude)
- Sprinting: hold Shift (new `sprint` input action) to move at `SPRINT_SPEED` (8.0 vs the normal 5.0) with a faster footstep cadence, playing a separate `SprintFootstepPlayer` sound slot instead of the walking footstep sound. (Claude)
- Screen-space crosshair on the player HUD. (Claude)
- Interact sound slot (`AudioStreamPlayer3D`) on all doors, playing on open/close when a stream is assigned. (Claude)
- Four self-contained "floors" in the 2D platformer scene, one per tower, each with its own ground and building-block platforms. (Claude)
- Assigned real audio: jump sound, footstep sound, background music, and a creaking-door interact sound. (User)
- Kept a fourth tower (`TowerC2` alongside `TowerA`/`TowerB`/`TowerC`) after duplicating one while repositioning towers in the editor, instead of deleting it. (User)

### Changed
- Village wall (four segments with a south gate) and three corner towers replacing the single center tower; floor and forest ring expanded to make room. (Claude)
- Tower-to-2D transition: reaching a tower's top platform now switches to a 2D platformer scene via a `GameState` autoload, spawning the player at a point specific to that tower. (Claude)
- Reaching a tower's top platform now instead teleports the player straight down to a new underground layer, keeping X/Z and only changing height, via a generic `vertical_teleporter.gd` (replaces `tower_top_trigger.gd`). The 2D-platformer scene switch this replaced is left intact and unused in the project in case it's wired up elsewhere later. Added `scenes/underground.tscn`: a floor 20m below the surface, four point lights, and a glowing return pad that teleports back up to the surface the same way. (Claude)
- Interactive doors (press E) added to all houses and towers via a shared `door.gd` script with `Area3D` proximity detection, replacing the tower's previously static propped-open door. (Claude)
- Tweaked door/window cut transforms and tower door scale in the Godot editor. (User)
- Adjusted `spiral_stairs.gd`'s default starting angle. (User)
- Added a `CameraAttributesPractical` resource to the player camera and a `window/size/mode` display setting. (User)

### Earlier this session
- Initial 3D scene: floor plus a first-person `CharacterBody3D` player with WASD movement, mouse look, and Space to jump. (Claude)
- Village of five procedural houses (box walls, wedge roofs). (Claude)
- Hollow house interiors (CSG walls) with a door opening, two window openings, and basic furniture (table, bed, chair). (Claude)
- Forest ring of procedurally scattered trees around the village (`forest.gd`). (Claude)
- Audio slots for background music, footsteps, and jump, wired to play only once a stream is assigned. (Claude)
- Central stone tower with a hollow interior and a procedurally generated spiral staircase (`spiral_stairs.gd`). (Claude)
- Raycast-based step-up assist in `player.gd` so the player can climb the stair risers instead of getting stuck on them. (Claude)
- `sounds/` folder created; audio files moved and renamed to `jump.mp3`, `footstep.mp3`, `music.mp3`, with `.import` metadata updated to match. (Claude)
- `.gitignore` added for the Godot 4 project. (Claude)
