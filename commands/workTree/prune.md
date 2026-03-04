---
description: Prunes completed track worktrees after verifying PR merge status
---

## 1.0 SYSTEM DIRECTIVE
You are an AI agent assistant for the Conductor framework. Your task is to safely prune Git worktrees for tracks that have been completed, merged, and integrated into the main branch.

CRITICAL: You must validate the success of every tool call. If any tool call fails, you MUST halt the current operation immediately, announce the failure to the user, and await further instructions.

---

## 1.1 SETUP CHECK
**PROTOCOL: Verify that the environment is ready.**

1.  **Check Git Repository:** Verify that the current directory is a Git repository by checking for `.git`.
    -   If not a Git repo, halt and announce: "This is not a Git repository. Cannot prune worktrees."

2.  **Check Conductor Setup:** Verify existence of `conductor/tracks.md`.
    -   If missing, halt and announce: "Conductor is not set up. Please run `/conductor:setup` first."

3.  **Fetch Latest:** Run `git fetch --all --prune` to ensure remote state is up to date.

---

## 2.0 DISCOVER WORKTREES

1.  **List Worktrees:** Run `git worktree list` and parse the output.
    -   Exclude the main worktree (the bare repo / primary checkout).
    -   Collect all secondary worktrees with their paths and branch names.

2.  **If No Worktrees Found:** Announce: "No secondary worktrees found. Nothing to prune." and halt.

3.  **Resolve Worktree Base Directory:** Read `conductor/settings.json` for `worktree_dir` if available, to help identify conductor-managed worktrees.

---

## 3.0 EVALUATE EACH WORKTREE

**PROTOCOL: For each discovered worktree, perform the following checks in order.**

For each worktree, let `<branch>` be its checked-out branch and `<track_name>` be the track name extracted from the branch (last segment of `<git_user>/tracks/<track_name>`).

### 3.1 Check Track Completion Status

1.  **Find Track in Conductor:** Look for a matching track directory under `conductor/tracks/` using `<track_name>`.
2.  **Read Track Status:** Check `conductor/tracks.md` for the track's status marker.
    -   If track is marked `[x]` (completed) — proceed to 3.2.
    -   If track is marked `[ ]` or `[~]` (pending/in-progress) — mark as **not ready**, skip this worktree.
    -   If track is not found in conductor — flag as **orphan worktree**, include in summary but do not auto-prune.

### 3.2 Check PR Merge Status

1.  **Find Associated PR:** Run `gh pr list --head <branch> --state merged --json number,title,mergedAt` to find a merged PR for this branch.
    -   If a merged PR is found — proceed to 3.3.
    -   If no merged PR found, also check with `gh pr list --head <branch> --state all --json number,title,state` to determine if:
        -   PR exists but is still open — mark as **not ready** (PR not yet merged).
        -   PR exists but was closed without merge — flag as **closed without merge**, include in summary for user decision.
        -   No PR exists at all — flag as **no PR found**, include in summary for user decision.

### 3.3 Verify Changes in Main Branch

1.  **Check Branch Merge:** Run `git branch --merged main` (or the default branch) and check if `<branch>` appears in the output.
    -   If the branch is merged into main — mark as **safe to prune**.
    -   If not merged — mark as **not ready** (PR may be merged but main not updated locally). Suggest running `git pull` on main.

---

## 4.0 PRESENT PRUNE PLAN

1.  **Compile Results:** Group worktrees into categories:

    -   **Safe to prune:** Track completed, PR merged, changes in main.
    -   **Not ready:** Track incomplete, PR not merged, or changes not in main (with reason).
    -   **Needs attention:** Orphan worktrees, closed-without-merge PRs, no PR found.

2.  **Present Summary:**
    > "Here's the worktree status report:"
    >
    > **Ready to prune:**
    > | Worktree | Branch | Track | PR | Reason |
    > |----------|--------|-------|----|--------|
    > | ... | ... | ... | #N | All checks passed |
    >
    > **Not ready:**
    > | Worktree | Branch | Track | Reason |
    > |----------|--------|-------|--------|
    > | ... | ... | ... | PR still open / Track in progress / ... |
    >
    > **Needs attention:**
    > | Worktree | Branch | Reason |
    > |----------|--------|--------|
    > | ... | ... | Orphan / No PR / Closed without merge |

3.  **If Nothing to Prune:** Announce: "No worktrees are ready to prune at this time." and halt.

4.  **Ask for Confirmation:**
    > "Would you like to prune the ready worktrees?"
    > A) Prune all ready worktrees
    > B) Select which ones to prune
    > C) Cancel

    -   **If B:** Present a numbered list of ready worktrees and let the user pick.

---

## 5.0 EXECUTE PRUNE

**PROTOCOL: For each worktree approved for pruning, perform the following steps.**

1.  **Check for Uncommitted Changes:** Run `git -C <worktree_path> status --porcelain`.
    -   If there are uncommitted changes, warn the user and skip this worktree unless they explicitly confirm deletion.

2.  **Remove Worktree:** Run `git worktree remove <worktree_path>`.
    -   If removal fails (e.g., locked), try `git worktree remove --force <worktree_path>` only after user confirmation.

3.  **Delete Local Branch:** Run `git branch -d <branch>`.
    -   Use `-d` (safe delete) not `-D`. If it fails because the branch is not fully merged, warn the user and skip branch deletion.

4.  **Repeat** for each approved worktree.

5.  **Run Cleanup:** Execute `git worktree prune` to clean up stale worktree references.

---

## 6.0 ANNOUNCE COMPLETION

1.  **Report Results:**
    > "Worktree pruning complete."
    >
    > **Pruned:**
    > - `<track_name>` — worktree removed, branch `<branch>` deleted
    > - ...
    >
    > **Skipped:**
    > - `<track_name>` — <reason>
    > - ...
    >
    > Remaining worktrees: `git worktree list`
