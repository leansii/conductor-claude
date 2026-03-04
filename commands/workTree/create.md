---
description: Creates a git worktree for a specific track
---

## 1.0 SYSTEM DIRECTIVE
You are an AI agent assistant for the Conductor framework. Your task is to create a Git worktree for a given track, allowing parallel development in an isolated working directory.

CRITICAL: You must validate the success of every tool call. If any tool call fails, you MUST halt the current operation immediately, announce the failure to the user, and await further instructions.

---

## 1.1 SETUP CHECK
**PROTOCOL: Verify that the environment is ready.**

1.  **Check Git Repository:** Verify that the current directory is a Git repository by checking for `.git`.
    -   If not a Git repo, halt and announce: "This is not a Git repository. Cannot create a worktree."

2.  **Check Conductor Setup:** Verify existence of `conductor/tracks.md`.
    -   If missing, halt and announce: "Conductor is not set up. Please run `/conductor:setup` first."

---

## 2.0 RESOLVE TRACK NAME

1.  **Get Track Name:**
    *   **If `$ARGUMENTS` contains a track name:** Use that as the track name.
    *   **If `$ARGUMENTS` is empty:** Read `conductor/tracks.md`, list available tracks, and ask the user to pick one.

2.  **Validate Track Exists:** Check that a directory matching the track name exists under `conductor/tracks/`.
    -   If not found, list available tracks from `conductor/tracks/` and ask the user to choose or provide the correct name.

---

## 3.0 RESOLVE WORKTREE BASE DIRECTORY

1.  **Check Conductor Settings:** Read `conductor/settings.json` if it exists.
    -   Look for the `worktree_dir` key. If found and non-empty, use its value as the base directory for worktrees.

2.  **If No Setting Found:** Ask the user:
    > "Where should I create worktrees? Please provide an absolute path to the base directory."
    >
    > The worktree for this track will be created at `<your_path>/<track_name>`.

3.  **Save Setting:** After the user provides a path, create or update `conductor/settings.json` with the `worktree_dir` value so future invocations don't need to ask again.
    -   If `conductor/settings.json` exists, merge the new key. If not, create:
        ```json
        {
          "worktree_dir": "<user_provided_path>"
        }
        ```

---

## 4.0 CREATE GIT WORKTREE

1.  **Determine Full Path:** The worktree path is `<worktree_dir>/<track_name>`.

2.  **Check if Worktree Already Exists:** Run `git worktree list` and check if a worktree at the target path already exists.
    -   If it does, announce: "A worktree for track '<track_name>' already exists at `<path>`." and halt.

3.  **Resolve Git User:** Run `git config user.name` to get the current Git user name. Sanitize it for use in a branch name (lowercase, replace spaces with hyphens, remove special characters). Let this be `<git_user>`.

4.  **Create Branch:** Create a new branch named `<git_user>/tracks/<track_name>` from the current HEAD.
    -   Run: `git branch <git_user>/tracks/<track_name>`
    -   If the branch already exists, ask the user whether to reuse it or halt.

5.  **Create Worktree:** Run:
    ```
    git worktree add <worktree_dir>/<track_name> <git_user>/tracks/<track_name>
    ```

6.  **Validate:** Run `git worktree list` and confirm the new worktree appears.

---

## 5.0 ANNOUNCE COMPLETION

1.  **Report Success:**
    > "Git worktree for track '<track_name>' created successfully."
    > - **Branch:** `<git_user>/tracks/<track_name>`
    > - **Path:** `<worktree_dir>/<track_name>`
    >
    > You can now work on this track in the worktree directory. To start implementation, `cd` into the worktree and run `/conductor:implement`.
