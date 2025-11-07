# Orchestrator

An AI agent orchestration system that delegates tasks to specialized subagents for optimal results while maintaining cost-efficiency.

### Architecture

**Orchestrator (Primary Agent)**

The main agent you interact with. Provide high-level requirements and the Orchestrator will:

- Analyze your request
- Create clear execution plans
- Delegate work to appropriate specialized subagents
- Coordinate task execution and track progress

**Specialized Subagents**

Domain-specific subagents that execute focused work based on the Orchestrator's instructions.<br/>
Each subagent is optimized for a particular type of task, ensuring high-quality results.

## Key Features

- **Cost-Effective Quality**: Achieves excellent results by having larger models guide smaller ones
- **Intelligent Task Delegation**: Automatically breaks down complex tasks into focused subtasks and assigns them to appropriate subagents
- **Pre-Configured Subagents**: Includes multiple specialized subagents for various development tasks
- **Future-Proof**: Built specifically for OpenCode to be as open, accessible and future-proof as possible

## Quality Assurance

Agents are manually tested and refined for reliable performance.<br/>
Each agent is paired with models optimized for their domain, balancing quality and cost-efficiency.

## Getting Started

### Prerequisites

- [OpenCode](https://opencode.ai) installed and up-to-date

### Installation

> [!NOTE]
> It's a good practice to verify scripts before running them

```bash
curl -fsSL https://raw.githubusercontent.com/ShalevAri/orchestrator/main/orchestrator.sh | bash
```

The installation script will install the latest tagged release into your project's `.opencode` directory.

### Usage

Launch OpenCode and select Orchestrator as the Primary Agent:

```bash
opencode
```

Provide high-level instructions to the Orchestrator. It will:

1. Analyze your requirements
2. Break down the work into focused subtasks
3. Delegate tasks to appropriate subagents
4. Coordinate execution and track progress
5. Report results back to you

### Updating

To update Orchestrator, simply re-run the installation command.

## Configuration

Files in the `.opencode/` directory are managed by Orchestrator and will be overwritten during updates.<br/>
**Do not modify these files directly.**

Instead, to customize agent behavior or configuration:

- **Project-specific settings**: Use your project's `opencode.json` file
- **User-wide preferences**: Use your global OpenCode configuration at `~/.config/opencode/`

For detailed configuration options, see the [OpenCode documentation](https://opencode.ai/docs).

## Development & Releases

Orchestrator uses a tag-based release workflow:

- **`main` branch**: Active development (not to be used)
- **Release tags**: Stable, verified versions intended for production use

## Available Agents

Orchestrator includes the following agents:

### Primary Agents

- **Orchestrator** - Main agent that analyzes requests and delegates tasks to subagents intelligently

### Specialized Subagents

- **Planner** - Analyzes requests and gathers necessary context
- **Task Manager** - Breaks down complex features into manageable subtasks
- **Reviewer** - Performs thorough code audits and quality checks
- **Tester** - Authors tests following TDD principles
- **Rustacean** - Expert in Rust programming and best practices
- **Frontend Developer** - Specializes in React and frontend development
- **Designer** - Creates beautiful, user-friendly UI designs
- **Commentor** - Enhances code documentation and comments
- **Jujutsu** - Manages version control using Jujutsu VCS

More agents coming soon.

## Roadmap

### Maybe

- [ ] Choose model providers during installation

### Planned

- [ ] Better agent organization

### In Rotation

N/A

### In Progress

N/A

### Done

- [x] v1.0.0
- [x] New React subagent
- [x] New React Native subagent
- [x] Improved Rust subagent

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
