---
description: Generate/update AGENTS.md
---

Analyze this codebase and generate or update an `AGENTS.md` file with the following structured content:

1. **Build, Lint, and Test Commands**: Include all relevant commands, with a focus on running individual tests (e.g., via npm/yarn/pnpm/bun, pytest, or similar tools).
2. **Code Style Guidelines**: Cover key aspects such as imports, code formatting, type annotations, naming conventions, error handling, and any other established patterns.
3. **Structure**: General structure of the project; Key directories, files and what their purpose is.
4. **Version Control System**: A short section specifying which VCS is used in this project.

This `AGENTS.md` file serves as a reference for agentic coding agents (such as yourself) working in this repository. Keep the file concise, aiming for approximately 25 lines total.

Incorporate any existing rules from:

- Claude Code (in `CLAUDE.md`)
- Cursor (in `.cursor/rules/` or `.cursorrules`)
- Copilot (in `.github/copilot-instructions.md`)

If an `AGENTS.md` file already exists, improve and refine it.

## Version Control System Section

The user will specify which VCS they use via arguments.
Add a "Version Control" section to AGENTS.md following this format:

### If using Git:

```markdown
## Version Control

- **VCS**: Git
```

### If using Jujutsu:

```markdown
## Version Control

- **VCS**: Jujutsu (jj)
```

### If using other VCS:

```markdown
## Version Control

- **VCS**: [VCS name as specified by user]
```

**Note**: If no VCS is specified in the arguments, refuse to work with the AGENTS.md file until it is.
If it doesn't already exist, refuse to create it. If it does but doesn't have the Version Control section, refuse
to improve it until specified.

Once it is, create it and only then proceed as usual.

USER ARGUMENTS:

VCS: $1
