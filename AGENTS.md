# Agent Guidelines for Orchestrator

## Build/Lint/Test Commands

- Format: `bun run prettier` or `bun run prettier:check`
- No test suite currently configured

## Code Style

- **Formatting**: Prettier with 2-space indentation, semicolons, double quotes, no trailing commas
- **File naming**: kebab-case for directories and markdown files (e.g., `task-manager.md`, `rust-developer.md`)
- **Naming conventions**: Use descriptive, functional names; avoid abbreviations
- **File structure**: Agent definitions in `dot_opencode/agent/`, subagents in `subagents/`, commands in `dot_opencode/command/`

## Agent File Structure

- All agent files are markdown with YAML frontmatter
- Required frontmatter: `description`, `mode` (primary/subagent), `model`, `temperature`, `tools`, `permissions`

## Task Management

- Tasks stored in `tasks/subtasks/{feature}/` with 2-digit sequence numbers
- Task files: `{seq}-{task-description}.md` in kebab-case
- Each feature has a README.md index with status tracking

## Error Handling

- Agents must validate inputs and provide clear error messages
- Use permissions to deny dangerous operations (rm -rf, sudo, .env modifications)

## Agent List

### Primary

- Orchestrator

### Subagents

#### Core

- Context Manager
- Planner
- Reviewer
- Task Manager
- Tester

#### Lang

- React Specialist
- Rust Developer

#### Specialists

- Designer
- Frontend Developer
- React Native Specialist

#### Util

- Commentor
- Commit Message Generator
- Jujutsu

## Version Control

- **VCS**: Jujutsu (jj)

## Diff checking

- `dot_opencode_diff` directory used to check for user customizations
