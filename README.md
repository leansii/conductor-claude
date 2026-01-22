# Conductor Plugin for Claude Code

> **Note:** This is a port of the [Conductor extension for Gemini CLI](https://github.com/gemini-cli-extensions/conductor) adapted for Claude Code.

**Context-Driven Development** - Measure twice, code once.

Conductor transforms AI-assisted development into a disciplined process with persistent project context, specifications, and phased implementation plans.

## Philosophy

By treating context as a managed artifact alongside your code, Conductor enables AI agents to work with deep, persistent project awareness. The protocol follows: **Context → Spec & Plan → Implement**.

## Commands

| Command | Description |
|---------|-------------|
| `/conductor:setup` | Initialize Conductor in your project |
| `/conductor:newTrack [description]` | Create a new feature/bug track with spec and plan |
| `/conductor:implement [track]` | Execute tasks from a track's plan |
| `/conductor:status` | Display project progress overview |
| `/conductor:revert [target]` | Git-aware revert of tracks, phases, or tasks |

## Installation

### Option 1: Development Mode (Local Testing)

```bash
claude --plugin-dir .claude/plugins/conductor
```

### Option 2: Install from Marketplace

```bash
# Add marketplace (if published)
claude marketplace add https://github.com/your-org/conductor-marketplace

# Install plugin
claude plugin install conductor
```

## Project Structure

After running `/conductor:setup`, your project will have:

```
conductor/
├── product.md                    # Product vision, users, goals
├── product-guidelines.md         # Prose style, brand messaging
├── tech-stack.md                 # Languages, frameworks, databases
├── workflow.md                   # Team preferences (TDD, commits)
├── code_styleguides/             # Language-specific style guides
├── tracks.md                     # Master tracks file
└── tracks/
    └── <track_id>/
        ├── metadata.json         # Track metadata
        ├── spec.md               # Detailed specifications
        └── plan.md               # Phased implementation plan
```

## Workflow

### 1. Setup (One-time)

```
/conductor:setup
```

Conductor will guide you through:
- Project discovery (brownfield vs greenfield)
- Product definition (vision, guidelines, tech stack)
- Workflow configuration (TDD, commit strategy)
- Initial track generation

### 2. Create Tracks

```
/conductor:newTrack user authentication with OAuth
```

Creates specification and phased plan for the feature.

### 3. Implement

```
/conductor:implement
```

Executes tasks following your configured workflow (e.g., TDD: write tests → implement → verify).

### 4. Monitor Progress

```
/conductor:status
```

Shows current phase, task, and overall progress.

### 5. Revert if Needed

```
/conductor:revert
```

Git-aware rollback of tracks, phases, or individual tasks.

## Templates

The plugin includes templates for:

- **Workflow:** TDD, commit strategy, code coverage requirements
- **Code Style Guides:**
  - General principles
  - Python
  - JavaScript
  - TypeScript
  - Go
  - Dart
  - HTML/CSS

## Key Features

- **Resumable Setup:** If interrupted, setup resumes from last successful step
- **Brownfield Support:** Analyzes existing projects to infer tech stack
- **TDD Enforcement:** Plans follow Test-Driven Development structure
- **Git Integration:** Commits, notes, and intelligent revert
- **Documentation Sync:** Auto-updates product docs after track completion

## Credits

Ported from [Gemini CLI Conductor Extension](https://github.com/gemini-cli-extensions/conductor).

## License

Apache-2.0
