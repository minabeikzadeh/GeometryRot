# How we work in Git

`main` must always open and run. Nobody pushes straight to it. All changes arrive through a pull request (PR).

## Every change, step by step

```
git checkout main
git pull
git checkout -b feature-name        # e.g. infection-system
# ...work in Godot, then:
gdformat scripts
gdlint scripts
git add <the files you changed>
git commit -m "Add infection timer to towers"
git push -u origin feature-name
```

Then on GitHub click **Compare & pull request**, fill in the template, and request a review from a teammate.

## Reviewing

- Read the diff. Run the branch in Godot if the change is visual or about gameplay.
- Leave at least one specific comment (a bug, a risk, or a concrete suggestion), then approve or request changes.
- The author answers each comment with a fix or a reason, then merges after approval.

## Merge conflicts

Pull `main` into your branch (`git pull origin main`), open the files with `<<<<<<<`, keep the right parts, then `git add` and `git commit`. Scenes (`.tscn`) conflict easily, so tell the team before editing `scenes/level.tscn`.

## One-time repo setup (repo owner)

1. GitHub repo, **Settings**, **Branches**, **Add branch protection rule**.
2. Branch name pattern: `main`.
3. Check **Require a pull request before merging** and **Require approvals** (1).
4. Save.

## Claims reminder

Competency claims are individual and need your own evidence: your commits, PRs, tests, and review comments. Being listed as the owner of a script is not evidence by itself.
