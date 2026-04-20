# Contributing

## Git commits

Use **atomic commits**: one logical change per commit. If a change mixes unrelated work, split it before opening a PR.

### Message format (Conventional Commits)

Write commit messages in **English**, **imperative mood**, with this prefix:

```
<type>(<optional-scope>): <short description>
```

**Types** (common):

| Type | When |
|------|------|
| `feat` | New behavior or feature |
| `fix` | Bug fix |
| `refactor` | Internal change without user-visible behavior change |
| `docs` | Documentation only |
| `test` | Tests only |
| `chore` | Tooling, build, deps, formatting |
| `style` | UI/style only (no logic change) |

**Examples**

```
feat(game): add final-answer flow before advancing question
fix(list): read countries from SwiftData when cache is warm
docs(readme): document WireMock base URL
refactor(router): extract navigation helper for flag game
```

### Body (optional)

Use the body for **why** the change exists, migration notes, or follow-ups—still in English.

### Do not

- Mix Spanish and English in commit titles.
- Put unrelated changes in a single commit (breaks review and `git bisect`).
