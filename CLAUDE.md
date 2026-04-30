# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Tiny Swords is a 2D auto-battler prototype in **Godot 4.3** (GL Compatibility renderer, 1600x900, y-sort enabled). Two teams of knights and monks fight each other. No player input — fully autonomous AI.

Assets are from [pixelfrog-assets.itch.io/tiny-swords](https://pixelfrog-assets.itch.io/tiny-swords).

## Running the Game

Open the project in Godot 4.3+. Main scene is `res://main.tscn`. Press **F5** to run. No CLI build tools or test runners.

## Architecture

### Scene & Resource Layout

- `main.tscn` — root scene; places knights, towers, terrain and camera
- `knight/` — knight unit (RigidBody2D with inner-class state machine); see `knight.gd` for state docs
- `monk/` — monk unit (RigidBody2D with inner-class state machine); see `monk.gd` for state docs
- `tower/` — tower structure (StaticBody2D; spawns and respawns monks)
- `team/` — `Team` Resource subclass; drives asset loading and group naming
- `terrain/` — `island.tscn` tilemap (4 layers); `terrain.tres` TileSet

### Team System

`Team` is a `Resource` subclass with a BLUE/RED enum. It owns group name strings (e.g. `"blue_units"`, `"red_towers"`, `"blue_monks"`, `"blue_ghosts"`) and preloads team-specific sprite frames and textures. All unit detection uses Godot's group system rather than direct node references.

### Physics Layers

| Layer | Name       | Used by                        |
| ----- | ---------- | ------------------------------ |
| 1     | collisions | terrain                        |
| 2     | knights    | knight + monk RigidBody2D bodies |
| 3     | towers     | tower StaticBody2D             |

Knight/Monk body: layers 1+2, mask 1+2 (terrain + units).
`AttackArea` (Area2D): mask 2 (detects units only).
`HealingArea` (Area2D): mask 3 (detects towers — fallback healing).
Monk `HealArea` (Area2D): mask 2 (detects ghost knights).

### Camera

`camera_2d.gd` averages positions of all living units from both teams each frame and uses Camera2D's built-in smoothing.

### Visual Effects

`knight/ghost.gdshader` — time-based UV distortion + blue tint applied as a `ShaderMaterial` on dead knights in `GhostState`.
