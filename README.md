# Drop

Drop is a bright, controller-friendly falling-block puzzle game prototype built with Godot 4.

## Current modes

- Marathon: survive as the drop speed increases over time.
- Garbage Sprint: start with a messy board and clear it as quickly as possible.
- Versus Bot: clear multiple lines to send garbage to a simple bot opponent.

## Themes and languages

Drop includes six background themes:

- Vital Green / 活力绿
- Ocean Blue / 海洋蓝
- Sunrise Orange / 晨光橙
- Sport Black / 运动黑
- Pulse Red / 脉冲红
- Glacier Cyan / 冰川青

The in-game UI supports English and Chinese.

## Controls

Keyboard:

- Move: arrow keys or A/D
- Soft drop: down or S
- Hard drop: Space
- Rotate: Up/X and Z
- Hold: C
- Pause/back: P or Esc
- Give up and return to menu: Q
- Cycle theme: T
- Toggle language: L

Gamepad:

- Move: D-pad
- Soft drop: D-pad down
- Hard drop / rotate / hold: face buttons
- Pause/back: Start
- Give up and return to menu: Select/Back

## Run locally

Install Godot 4.6 or newer, then open this folder as a Godot project.

From Terminal:

```sh
godot --path /Users/bill/Documents/drop
```

Scores are stored locally in Godot's `user://scores.json`.

## Publishing note

Drop should stay visually and commercially distinct from official Tetris products: use the Drop name, original art, original audio, and avoid Tetris trademarks in marketing or store metadata.
