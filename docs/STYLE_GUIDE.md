# Style guide

Keep it short. The linter enforces most of this, so run it before every PR.

## Tools

```
pip install "gdtoolkit==4.*"
gdformat scripts      # auto-formats (tabs, 100 columns)
gdlint scripts        # must print "Success: no problems found"
```

## Naming

| Thing | Style | Example |
|---|---|---|
| Files | `snake_case.gd` / `.tscn` | `merge_manager.gd` |
| Classes (`class_name`) | `PascalCase` | `MergeManager` |
| Functions, variables | `snake_case` | `find_target()` |
| Private members | leading underscore | `_shot_time` |
| Constants | `UPPER_SNAKE_CASE` | `SHOT_DURATION` |
| Signals | past tense or event | `merge_completed` |
| Data ids in JSON | `snake_case` | `spike_ball` |

## Rules

1. **Type your variables and function signatures** (`var health: float`, `func heal(amount: float) -> void`).
2. **No balance numbers in scripts.** Costs, damage, speed, and timers live in `data/*.json`.
3. **Systems talk through `GameEvents`.** Do not reach into another member's node tree with `get_node("../../X")`. Add a signal instead.
4. **One owner per script.** The owner is named in the header comment. Change someone else's file only through a PR they review.
5. **Order inside a script:** `class_name`, `extends`, doc comment, signals, constants, `@export`, public vars, private vars, `@onready`, then functions.
6. **Comments explain why, not what.** Every `TODO` names a member: `# TODO (Member 2): ...`
7. **Small functions.** If a function needs a scroll bar, split it.
8. **Delete dead code.** Git remembers it.

## Commits

- Present tense, under 70 characters: `Add infection timer to towers`.
- One idea per commit. Do not mix reformatting with behavior changes.
- Never commit `.godot/`.
