# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**3.1.1.AI.Intro** is a Godot 4.6 top-down action game serving as a teaching project for neural network behavioral AI. NPCs make decisions via a small feedforward neural network that selects from 5 behavioral states.

## Development Commands

This is a Godot 4.6 project. There is no build system — open and run from the Godot editor:

```bash
# Open project in Godot editor (adjust path to your Godot 4.6 binary)
godot --path .

# Run headless (for CI or testing without display)
godot --headless --path . --quit

# Export (requires export templates installed)
godot --headless --export-release "Linux/X11" build/game.x86_64
```

GDScript has no separate lint step — the editor validates scripts on save.

## Architecture

### Scene Hierarchy

```
World (world.tscn / world.gd)
├── Player (player.tscn / player.gd) — CharacterBody2D
└── NPCs Container
    └── NPC (npc.tscn / npc.gd) — CharacterBody2D, instantiated multiple times
        └── NPCBot (NPC_bot.gd) — senses player, orchestrates AI
            ├── FiniteStateMachine (finite_state_machine.gd)
            │   ├── WanderingFSMComponent
            │   ├── AttackPlayerFSMComponent
            │   ├── FindFriendsFSMComponent
            │   ├── RunawayPlayerFSMComponent
            │   └── GoHomeFSMComponent
            └── ActionSelectionComponent (action_selection_component.gd)
                └── NeuralNetwork (neural_network.gd)
                    └── Matrix (matrix.gd)
```

### AI Decision Pipeline

Each physics frame the AI pipeline runs:

1. **NPCBot** reads game state: player visibility (via vision Area2D, 1200px radius), NPC health, player health, nearby friend count
2. **ActionSelectionComponent** normalizes inputs to [0,1] and calls `NeuralNetwork.predict()`
3. **NeuralNetwork** runs a forward pass: 4 inputs → 30 hidden (sigmoid) → 5 outputs
4. The output with the highest value selects one of 5 actions (enum in `action_selection_component.gd`)
5. **FiniteStateMachine** activates the corresponding FSM component
6. The active FSM component returns a velocity vector applied via `move_and_slide()`

### Neural Network

- **Architecture:** 4→30→5 feedforward, sigmoid activation throughout
- **Training:** Supervised backpropagation, 400 epochs, triggered by a button in `world.tscn`
- **Training data:** `data/action_selection_data.json` — 6 labeled examples mapping `[player_visible, npc_health, player_health, friends_nearby]` → one-hot action
- **Weights** are serializable to JSON via `matrix.gd`

Key files under `scripts/AI/`:
- `action_selection_component.gd` — bridges game state to NN; holds the `Action` enum
- `NN/neural_network.gd` — `train()` and `predict()` entry points
- `NN/matrix.gd` — all linear algebra (multiply, transpose, element-wise ops, gradient math)
- `NN/activation_functions.gd` — sigmoid and its derivative

### FSM Components

Each component under `scripts/AI/FSM/` implements one action. They receive the NPC node and return a velocity:

| Component | Behavior | Speed |
|---|---|---|
| Wandering | Random walk, periodic direction changes | 200 |
| AttackPlayer | Chase player, stop at 190px, attack within 150px | 400 |
| RunawayPlayer | Flee opposite player direction | 450 |
| FindFriends | Move toward nearest other NPC | 200 |
| GoHome | Return to spawn position | 200 |

### Combat & Stats

- **Player:** 100 HP / 100 stamina; melee costs 30 stamina; running costs stamina; slow HP regen when stamina > 80
- **Weapons:** sword (melee, Space) and bow (ranged, mouse click, charge-based damage); switch with 1/2
- **NPC melee:** attacks trigger via an Area2D overlap at 150px; hit tracked with a timer to avoid repeat hits

## Key Conventions

- All AI logic lives under `scripts/AI/`; FSM components under `scripts/AI/FSM/`
- Scene scripts are in `scripts/` at the root level (`player.gd`, `npc.gd`, `world.gd`, etc.)
- The `Action` enum in `action_selection_component.gd` is the canonical mapping between NN output indices and FSM states — keep these in sync
- Training data indices must match the `Action` enum order exactly
- `matrix.gd` uses plain `Array` of `Array` for matrices — no typed arrays
