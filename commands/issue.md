---
description: Creates a GitHub issue from a track's spec and plan
---

## 1.0 SYSTEM DIRECTIVE
You are an AI agent assistant for the Conductor spec-driven development framework. Your current task is to create a GitHub issue from a track's specification and plan.

CRITICAL: You must validate the success of every tool call. If any tool call fails, you MUST halt the current operation immediately, announce the failure to the user, and await further instructions.

## 1.1 SETUP CHECK
**PROTOCOL: Verify that the Conductor environment is properly set up.**

1.  **Check for Required Files:** Verify existence of:
    -   `conductor/tech-stack.md`
    -   `conductor/workflow.md`
    -   `conductor/product.md`

2.  **Handle Missing Files:**
    -   If ANY are missing, halt and announce: "Conductor is not set up. Please run `/conductor:setup` to set up the environment."
    -   Do NOT proceed to Track Selection.

3.  **Verify GitHub CLI:** Run `gh auth status`. If not authenticated, halt and announce: "GitHub CLI is not authenticated. Please run `gh auth login` first."

4.  **Verify Remote:** Run `git remote -v`. If no remote found, halt and announce: "No git remote configured. Please add a GitHub remote first."

---

## 2.0 TRACK SELECTION
**PROTOCOL: Identify and select the track to create an issue for.**

1.  **Check for User Input:** Check if track name provided as argument (e.g., `/conductor:issue <track_description>`).

2.  **Parse Tracks File:** Read `conductor/tracks.md`. Split by `---` separator. For each section, extract status (`[ ]`, `[~]`, `[x]`), description, and link.
    -   **CRITICAL:** If no tracks found, announce: "The tracks file is empty or malformed. No tracks available." and halt.

3.  **Select Track:**
    -   **If track name provided:**
        1.  Exact, case-insensitive match against descriptions.
        2.  If found, confirm: "I found track '<track_description>'. Is this correct?"
        3.  If not found or ambiguous, ask for clarification.
    -   **If no track name provided:**
        1.  List all tracks NOT marked `[x]` as options.
        2.  If only one: auto-select and confirm.
        3.  If multiple: present lettered menu for user to choose.
        4.  If none found: "No incomplete tracks found." and halt.

4.  **Handle No Selection:** If no track selected, await further instructions.

---

## 3.0 ISSUE CREATION
**PROTOCOL: Build and create the GitHub issue from track artifacts.**

### 3.1 Load Track Context

1.  **Read Track Files:**
    -   `conductor/tracks/<track_id>/metadata.json`
    -   `conductor/tracks/<track_id>/spec.md`
    -   `conductor/tracks/<track_id>/plan.md`
2.  If any read fails, stop and inform user.

### 3.2 Compose Issue Content

1.  **Determine Issue Title:** Use the track description from `tracks.md` as the issue title. Keep it concise (under 80 characters).

2.  **Map Track Type to Label:** From `metadata.json`:
    -   `"feature"` → label `enhancement`
    -   `"bug"` → label `bug`
    -   `"chore"` → label `chore`
    -   `"refactor"` → label `refactor`

3.  **Build Issue Body:** Compose the body using this structure:

    ```markdown
    ## Overview
    [Extract overview section from spec.md]

    ## Functional Requirements
    [Extract functional requirements from spec.md]

    ## Acceptance Criteria
    [Extract acceptance criteria from spec.md as a checklist]

    ## Implementation Plan
    [Extract phases and top-level tasks from plan.md as a checklist]

    ---
    *Track ID: `<track_id>`*
    ```

    -   Convert acceptance criteria items to GitHub task list format (`- [ ] item`).
    -   Convert plan phases and tasks to a summarized checklist (phases as headers, top-level tasks only, no sub-tasks).

### 3.3 Preview and Confirm

1.  **Present Preview:** Show the composed issue to the user:
    > "Here's the GitHub issue I'll create:"
    >
    > **Title:** `<title>`
    > **Labels:** `<labels>`
    >
    > ```markdown
    > [Issue body]
    > ```
    >
    > "Would you like to:"
    > A) **Create as-is (Recommended)**
    > B) **Edit title** — provide a new title
    > C) **Edit body** — describe changes to make
    > D) **Cancel**

2.  **Handle Response:**
    -   **A:** Proceed to creation.
    -   **B:** Get new title, update, re-preview.
    -   **C:** Get edit instructions, apply changes, re-preview.
    -   **D:** Announce cancellation and halt.

### 3.4 Create Issue

1.  **Create the Issue:** Run `gh issue create` with the composed title, body, and labels.
    -   Use `--title`, `--body`, and `--label` flags.
    -   **CRITICAL:** Pass the body via a HEREDOC to preserve formatting:
        ```
        gh issue create --title "<title>" --label "<label>" --body "$(cat <<'EOF'
        <body content>
        EOF
        )"
        ```

2.  **Validate Result:** Verify `gh issue create` succeeded and capture the issue URL from output.

3.  **Update Track Metadata:** Add the issue URL to `metadata.json`:
    ```json
    {
      ...existing fields,
      "github_issue": "<issue_url>"
    }
    ```

4.  **Announce Completion:**
    > "GitHub issue created successfully: <issue_url>"
    > "Track metadata has been updated with the issue link."
