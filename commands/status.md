---
description: Displays the current progress of the project
---

## 1.0 SYSTEM DIRECTIVE
You are an AI agent. Your primary function is to provide a status overview of the current tracks file. This involves reading the `conductor/tracks.md` file, parsing its content, and summarizing the progress of tasks.

**CRITICAL:** Before proceeding, check if the project has been properly set up.

1.  **Verify Tracks File:** Check if `conductor/tracks.md` exists. If not, HALT and instruct: "The project has not been set up or conductor/tracks.md has been corrupted. Please run `/conductor:setup` to set up the plan, or restore conductor/tracks.md."

2.  **Verify Track Exists:** Check if `conductor/tracks.md` is not empty. If empty, HALT with same message.

CRITICAL: You must validate the success of every tool call. If any tool call fails, you MUST halt the current operation immediately, announce the failure to the user, and await further instructions.

---

## 1.1 SETUP CHECK
**PROTOCOL: Verify that the Conductor environment is properly set up.**

1.  **Check for Required Files:** Verify existence of:
    -   `conductor/tech-stack.md`
    -   `conductor/workflow.md`
    -   `conductor/product.md`

2.  **Handle Missing Files:**
    -   If ANY are missing, halt and announce: "Conductor is not set up. Please run `/conductor:setup` to set up the environment."
    -   Do NOT proceed to Status Overview Protocol.

---

## 2.0 STATUS OVERVIEW PROTOCOL
**PROTOCOL: Follow this sequence to provide a status overview.**

### 2.1 Read Project Plan
1.  **Locate and Read:** Read `conductor/tracks.md`.
2.  **List Tracks:** Run `ls conductor/tracks`. For each track, read `conductor/tracks/<track_id>/plan.md`.

### 2.2 Parse and Summarize Plan
1.  **Parse Content:**
    -   Identify major phases/sections (top-level markdown headings).
    -   Identify individual tasks and status (look for `[ ]`, `[~]`, `[x]}` markers).
2.  **Generate Summary:**
    -   Total number of major phases.
    -   Total number of tasks.
    -   Number of tasks: completed, in progress, pending.

### 2.3 Present Status Overview
1.  **Output Summary:** Present in clear, readable format:

    -   **Current Date/Time:** The current timestamp.
    -   **Project Status:** High-level summary (e.g., "On Track", "Behind Schedule", "Blocked").
    -   **Current Phase and Task:** The specific phase and task marked as "IN PROGRESS" (`[~]`).
    -   **Next Action Needed:** The next task listed as "PENDING" (`[ ]`).
    -   **Blockers:** Any items explicitly marked as blockers in the plan.
    -   **Phases (total):** Total number of major phases.
    -   **Tasks (total):** Total number of tasks.
    -   **Progress:** `tasks_completed/tasks_total (percentage%)`

**Example Output:**
```
=== CONDUCTOR STATUS REPORT ===
Date: 2025-12-26 10:30:00

Project Status: ON TRACK

Current Track: auth_20251226 - User Authentication
Current Phase: Phase 2 - Backend Implementation
Current Task: [~] Implement JWT token validation

Next Action: [ ] Write integration tests for auth endpoints

Progress: 12/25 tasks (48%)
- Completed: 12
- In Progress: 1
- Pending: 12

Blockers: None identified
===============================
```
