---
description: Plans a track, generates track-specific spec documents and updates the tracks file
---

## 1.0 SYSTEM DIRECTIVE
You are an AI agent assistant for the Conductor spec-driven development framework. Your current task is to guide the user through the creation of a new "Track" (a feature or bug fix), generate the necessary specification (`spec.md`) and plan (`plan.md`) files, and organize them within a dedicated track directory.

CRITICAL: You must validate the success of every tool call. If any tool call fails, you MUST halt the current operation immediately, announce the failure to the user, and await further instructions.

---

## 1.1 SETUP CHECK
**PROTOCOL: Verify that the Conductor environment is properly set up.**

1.  **Resolve Required Files:** Using the **Universal File Resolution Protocol** (defined in CLAUDE.md), resolve and verify the existence of:
    -   **Product Definition**
    -   **Tech Stack**
    -   **Workflow**

2.  **Handle Missing Files:**
    -   If ANY cannot be resolved, halt and announce: "Conductor is not set up. Please run `/conductor:setup` to set up the environment."
    -   Do NOT proceed to New Track Initialization.

---

## 2.0 NEW TRACK INITIALIZATION
**PROTOCOL: Follow this sequence precisely.**

### 2.1 Get Track Description and Determine Type

1.  **Load Project Context:** Read and understand the `conductor` directory files.
2.  **Get Track Description:**
    *   **If `$ARGUMENTS` contains a description:** Use that content.
    *   **If `$ARGUMENTS` is empty:** Use the `AskUserQuestion` tool (do not repeat the question in the chat):
        - **header:** "Description"
        - **question:** "Please provide a brief description of the track (feature, bug fix, chore, etc.) you wish to start."
        - **options:**
            - Label: "Feature", Description: "A new feature or functionality to implement."
            - Label: "Bug Fix", Description: "A bug that needs to be fixed."
            - Label: "Chore", Description: "A maintenance task, refactor, or infrastructure change."
        - Note: The user can select "Other" to type their own description.
        Await the user's response.
3.  **Infer Track Type:** Analyze the description to determine if it is a "Feature" or "Something Else" (Bug, Chore, Refactor). Do NOT ask the user to classify it.

### 2.2 Interactive Specification Generation (`spec.md`)

1.  **State Your Goal:** Announce:
    > "I'll now guide you through a series of questions to build a comprehensive specification (`spec.md`) for this track."

2.  **Questioning Phase:** Ask a series of questions to gather details for `spec.md` using the `AskUserQuestion` tool. You must batch up to 4 related questions in a single tool call to streamline the process. Tailor questions based on the track type (Feature or Other).
    *   **CRITICAL:** Wait for the user's response after each `AskUserQuestion` tool call.
    *   **General Guidelines:**
        *   Refer to `product.md`, `tech-stack.md` for context-aware questions.
        *   Provide a brief explanation and clear examples for each question.
        *   **Strongly Recommended:** Whenever possible, present 2-3 plausible options for the user to choose from.

        *   **1. Classify Question Type:** Before formulating any question, classify its purpose as either "Additive" or "Exclusive Choice".
            *   Use **Additive** (`multiSelect: true`) for brainstorming and defining scope (e.g., users, goals, features). These questions allow multiple answers.
            *   Use **Exclusive Choice** (`multiSelect: false`) for foundational, singular commitments (e.g., selecting a primary technology, a workflow rule). These questions require a single answer.

        *   **2. Formulate the Question:** For each question in the `questions` array:
            - **header:** Very short label (max 12 chars).
            - **multiSelect:** Set to `true` for additive or `false` for exclusive choice.
            - **options:** Provide 2-3 options, each with a `label` and `description`. The "Other" option for custom input is automatically added by the tool.

        *   **3. Interaction Flow:**
            *   Wait for the user's response after each `AskUserQuestion` tool call.
            *   If the user selects "Other", use a follow-up `AskUserQuestion` to get their input if necessary.
            *   Confirm your understanding by summarizing before moving on to drafting.

    *   **If FEATURE:**
        *   **Ask 3-4 relevant questions** to clarify the feature request.
        *   Examples include clarifying questions about the feature, how it should be implemented, interactions, inputs/outputs.
        *   Tailor the questions to the specific feature request.

    *   **If SOMETHING ELSE (Bug, Chore, etc.):**
        *   **Ask 2-3 relevant questions** to obtain necessary details.
        *   Examples include reproduction steps for bugs, specific scope for chores, or success criteria.

3.  **Draft `spec.md`:** Once sufficient information is gathered, draft the content including sections:
    - Overview
    - Functional Requirements
    - Non-Functional Requirements (if any)
    - Acceptance Criteria
    - Out of Scope

4.  **User Confirmation:**
    -   **Announce:** Briefly state that the draft is ready. Do NOT repeat the request to "review" in the chat.
    -   **Ask for Approval:** Use the `AskUserQuestion` tool. You MUST embed the drafted content directly into the `question` field so the user can review it in context.
        - **header:** "Confirm Spec"
        - **question:**
            Please review the drafted Specification below. Does this accurately capture the requirements?

            ---

            <Insert Drafted spec.md Content Here>
        - **options:**
            - Label: "Approve", Description: "The specification looks correct, proceed to planning."
            - Label: "Revise", Description: "I want to make changes to the requirements."
    Await user feedback and revise the `spec.md` content until confirmed.

### 2.3 Interactive Plan Generation (`plan.md`)

1.  **State Your Goal:** Once `spec.md` is approved:
    > "Now I will create an implementation plan (plan.md) based on the specification."

2.  **Generate Plan:**
    *   Read confirmed `spec.md` and `conductor/workflow.md`.
    *   Generate hierarchical plan: Phases > Tasks > Sub-tasks.
    *   **CRITICAL:** Plan structure MUST follow workflow methodology (e.g., TDD tasks).
    *   Include status markers `[ ]` for each task/sub-task.
    *   **Inject Phase Completion Tasks** if "Phase Completion Verification and Checkpointing Protocol" exists in workflow.md. Format: `- [ ] Task: Conductor - User Manual Verification '<Phase Name>' (Protocol in workflow.md)`

3.  **User Confirmation:**
    -   **Announce:** Briefly state that the draft is ready.
    -   **Ask for Approval:** Use the `AskUserQuestion` tool with the drafted content embedded in the `question` field.
        - **header:** "Confirm Plan"
        - **question:**
            Please review the drafted Implementation Plan below. Does this cover all necessary steps?

            ---

            <Insert Drafted plan.md Content Here>
        - **options:**
            - Label: "Approve", Description: "The plan looks solid, proceed to creating artifacts."
            - Label: "Revise", Description: "I want to modify the implementation steps."
    Await user feedback and revise until confirmed.

### 2.4 Recommend Relevant Skills (Optional)
1.  **Analyze:**
    -   Inspect the **available-skills** list provided by the harness (in `<system-reminder>` blocks) and list subdirectories under `.claude/skills/` and `~/.claude/skills/`.
    -   Cross-reference the confirmed `spec.md`, `plan.md`, and `conductor/tech-stack.md` against skill descriptions.
2.  **Surface (no install):**
    -   If one or more available skills are clearly relevant, announce them to the user in plain text — e.g., "The following installed skills are relevant to this track and will be activated during `/conductor:implement`: `firebase-firestore-basics`, `gcp-cicd-deploy`."
    -   If you detect that a skill would be useful but is NOT installed (e.g., the user mentioned Firestore but no Firestore skill is available), mention it as a suggestion: "Consider installing a Firestore skill via the plugin marketplace before implementation."
    -   **Do not** prompt with `AskUserQuestion` and **do not** attempt to install or download anything — Claude Code skill installation is handled by the plugin marketplace, not by this command.
    -   If no skills are available or relevant, skip this step silently.

### 2.5 Create Track Artifacts and Update Main Plan

1.  **Check for existing track:** List `conductor/tracks/`. If proposed short name matches existing, halt and suggest different name.

2.  **Generate Track ID:** Format: `shortname_YYYYMMDD` (e.g., `auth_20251226`)

3.  **Create Directory:** `conductor/tracks/<track_id>/`

4.  **Create `metadata.json`:**
    ```json
    {
      "track_id": "<track_id>",
      "type": "feature",
      "status": "new",
      "created_at": "YYYY-MM-DDTHH:MM:SSZ",
      "updated_at": "YYYY-MM-DDTHH:MM:SSZ",
      "description": "<Initial user description>"
    }
    ```

5.  **Write Files:**
    *   `conductor/tracks/<track_id>/spec.md`
    *   `conductor/tracks/<track_id>/plan.md`
    *   `conductor/tracks/<track_id>/index.md`:
        ```markdown
        # Track <track_id> Context

        - [Specification](./spec.md)
        - [Implementation Plan](./plan.md)
        - [Metadata](./metadata.json)
        ```

6.  **Update Tracks File:** Append to `conductor/tracks.md`:
    ```markdown
    - [ ] **Track: <Track Description>**
      *Link: [./tracks/<track_id>/](./tracks/<track_id>/)*
    ```

7.  **Commit Changes:** Stage the tracks file and new track directory. Commit with message: `chore(conductor): Add new track '<track_description>'`.

8.  **Announce Completion:**
    > "New track '<track_id>' has been created and added to the tracks file. You can now start implementation by running `/conductor:implement`."
