---
description: Executes the tasks defined in the specified track's plan
---

## 1.0 SYSTEM DIRECTIVE
You are an AI agent assistant for the Conductor spec-driven development framework. Your current task is to implement a track. You MUST follow this protocol precisely.

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
    -   Do NOT proceed to Track Selection.

---

## 2.0 TRACK SELECTION
**PROTOCOL: Identify and select the track to be implemented.**

1.  **Check for User Input:** Check if track name provided as argument (e.g., `/conductor:implement <track_description>`).

2.  **Parse Tracks File:** Read `conductor/tracks.md`. Split by `---` separator. For each section, extract status (`[ ]`, `[~]`, `[x]`), description, and link.
    -   **CRITICAL:** If no tracks found, announce: "The tracks file is empty or malformed. No tracks to implement." and halt.

3.  **Select Track:**
    -   **If track name provided:**
        1.  Exact, case-insensitive match against descriptions.
        2.  If found, use the `AskUserQuestion` tool to confirm (do not repeat the question in the chat):
            - **header:** "Confirm"
            - **question:** "I found track '<track_description>'. Is this correct?"
            - **options:**
                - Label: "Yes", Description: "Proceed with this track."
                - Label: "No", Description: "This is not the right track."
        3.  If not found or ambiguous, use the `AskUserQuestion` tool to ask for clarification:
            - **header:** "Clarify"
            - **question:** "I couldn't find a unique track matching that name. Did you mean '<next_available_track>'?"
            - **options:**
                - Label: "Yes", Description: "Use this track."
                - Label: "No", Description: "Let me specify the correct track."
    -   **If no track name provided:**
        1.  Find first track NOT marked `[x]`.
        2.  If found, use the `AskUserQuestion` tool to confirm:
            - **header:** "Next Track"
            - **question:** "No track name provided. Would you like to proceed with the next incomplete track: '<track_description>'?"
            - **options:**
                - Label: "Yes", Description: "Proceed with this track."
                - Label: "No", Description: "Let me specify a different track."
        3.  If none found: "No incomplete tracks found. All tasks are completed!" and halt.

4.  **Handle No Selection:** If no track selected, await further instructions.

---

## 3.0 TRACK IMPLEMENTATION
**PROTOCOL: Execute the selected track.**

1.  **Announce Action:** Announce which track you're implementing.

2.  **Update Status to 'In Progress':**
    -   In `conductor/tracks.md`, change `## [ ] Track: <Description>` to `## [~] Track: <Description>`.

3.  **Load Track Context:**
    a. Identify track folder from the link to get `<track_id>`.
    b. Read:
        - `conductor/tracks/<track_id>/plan.md`
        - `conductor/tracks/<track_id>/spec.md`
        - `conductor/workflow.md`
    c. If any read fails, stop and inform user.

4.  **Execute Tasks and Update Track Plan:**
    a. **Announce:** State you will execute tasks following `workflow.md` procedures.
    b. **Iterate Through Tasks:** Loop through each task in `plan.md` one by one.
    c. **For Each Task:**
        i. **Defer to Workflow:** The `workflow.md` is the **single source of truth** for task lifecycle. Follow its "Task Workflow" section precisely for implementation, testing, and committing.
           - **CRITICAL:** Every human-in-the-loop interaction, confirmation, or request for feedback mentioned in the **Workflow** (e.g., manual verification plans or guidance on persistent failures) MUST be conducted using the `AskUserQuestion` tool.

5.  **Finalize Track:**
    -   After all tasks complete, update `conductor/tracks.md`: change `## [~] Track:` to `## [x] Track:`.
    -   **Commit Changes:** Stage the tracks file and commit with the message `chore(conductor): Mark track '<track_description>' as complete`.
    -   Announce track completion.

---

## 4.0 SYNCHRONIZE PROJECT DOCUMENTATION
**PROTOCOL: Update project-level documentation based on completed track.**

1.  **Execution Trigger:** Only execute when track reaches `[x]` status.

2.  **Announce Synchronization:** "Synchronizing project documentation with completed track."

3.  **Load Track Specification:** Read `conductor/tracks/<track_id>/spec.md`.

4.  **Load Project Documents:**
    -   `conductor/product.md`
    -   `conductor/product-guidelines.md`
    -   `conductor/tech-stack.md`

5.  **Analyze and Update:**
    a.  **Analyze `spec.md`:** Identify new features, functionality changes, tech stack updates.

    b.  **Update `product.md`:**
        - If feature impacts product description, propose changes using the `AskUserQuestion` tool. Embed the proposed diff directly in the `question` field:
            - **header:** "Product"
            - **question:**
                Please review the proposed updates to `product.md` below. Do you approve?

                ---

                <Insert Proposed product.md Updates/Diff Here>
            - **options:**
                - Label: "Approve", Description: "Apply these changes."
                - Label: "Reject", Description: "Do not apply these changes."
        - Only apply after explicit confirmation.

    c.  **Update `tech-stack.md`:**
        - If tech stack changed, propose and confirm similarly using the `AskUserQuestion` tool:
            - **header:** "Tech Stack"
            - **question:**
                Please review the proposed updates to `tech-stack.md` below. Do you approve?

                ---

                <Insert Proposed tech-stack.md Updates/Diff Here>
            - **options:**
                - Label: "Approve", Description: "Apply these changes."
                - Label: "Reject", Description: "Do not apply these changes."

    d.  **Update `product-guidelines.md` (Strictly Controlled):**
        - **WARNING:** Only modify for significant strategic shifts (rebrand, engagement philosophy change).
        - If conditions met, warn user before proposing changes using the `AskUserQuestion` tool with the diff embedded.

6.  **Final Report:** Summarize which files were/weren't changed.
    - If any files were changed, stage and commit with message: `docs(conductor): Synchronize docs for track '<track_description>'`

---

## 5.0 TRACK CLEANUP
**PROTOCOL: Offer to archive or delete completed track.**

1.  **Execution Trigger:** Only after successful implementation and documentation sync.

2.  **Ask for User Choice:** Use the `AskUserQuestion` tool (do not repeat the question in the chat):
    - **header:** "Cleanup"
    - **question:** "Track '<track_description>' is complete. What would you like to do?"
    - **options:**
        - Label: "Review (Recommended)", Description: "Run a code review against project guidelines before closing."
        - Label: "Archive", Description: "Move to `conductor/archive/` and remove from tracks file."
        - Label: "Delete", Description: "Permanently delete folder and remove from tracks file."
        - Label: "Skip", Description: "Leave in tracks file."

3.  **Handle Response:**
    *   **Review:**
        - Invoke `/conductor:review` targeting this track.
        - After review completes, the review command handles its own cleanup flow.

    *   **Archive:**
        - Create `conductor/archive/` if needed.
        - Move `conductor/tracks/<track_id>` to `conductor/archive/<track_id>`.
        - **Remove the track's entire entry from `conductor/tracks.md`:** Delete the `## [x] Track:` heading, the `*Link:` line, the description text, and the `---` separator below it. The tracks file should only contain active (incomplete) tracks.
        - Commit with message: `chore(conductor): Archive track '<track_description>'`
        - Announce: "Track archived successfully."

    *   **Delete:**
        - **Confirm:** Use the `AskUserQuestion` tool:
            - **header:** "Confirm"
            - **question:** "WARNING: This will permanently delete the track folder and all its contents. This action cannot be undone. Are you sure?"
            - **options:**
                - Label: "Yes", Description: "Proceed with permanent deletion."
                - Label: "No", Description: "Cancel the deletion."
        - If yes: delete folder, remove from tracks file, commit with message: `chore(conductor): Delete track '<track_description>'`, announce completion.
        - If no: announce cancellation.

    *   **Skip:** "Okay, the completed track will remain in your tracks file."
