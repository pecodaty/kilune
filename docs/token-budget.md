# Token Budget Rules

## Goal

Build this project while measuring and reducing token usage.

## Rules

1. Prefer command-output compression via RTK.
2. Never paste full logs into the conversation.
3. Keep design decisions in short ADRs.
4. Split features into small tasks.
5. Prefer small GDScript files.
6. Ask the agent to inspect only relevant files.
7. After each session, write a short summary in `docs/ai/session-log.md`.

## Metrics to track

- Raw command output avoided
- RTK gain
- Number of files read per task
- Number of files changed per task
- Failed iterations per task
