---
name: skill-creator
description: Create new skills, modify and improve existing skills, and measure skill performance. Use when users want to create a skill from scratch, update or optimize an existing skill, run evals to test a skill, benchmark skill performance, or optimize a skill's description for better triggering accuracy. Also use when someone says "turn this into a skill" or "make a skill for X".
---

# Skill Creator

A skill for creating new skills and iteratively improving them.

## Process Overview

The process of creating a skill goes like this:

1. Decide what the skill should do and roughly how it should do it
2. Write a draft of the skill
3. Create test prompts and run Claude-with-access-to-the-skill on them
4. Evaluate results both qualitatively and quantitatively
5. Rewrite the skill based on feedback
6. Repeat until satisfied
7. Expand the test set and try again at larger scale

Figure out where the user is in this process and help them progress. If they say "I want to make a skill for X", help narrow it down, write a draft, write test cases, run them, and iterate. If they already have a draft, go straight to eval/iterate.

Be flexible — if the user says "just vibe with me", skip the formal eval process.

## Communicating with the User

Skill-creator is used by people across a wide range of coding familiarity. Pay attention to context cues. Terms like "evaluation" and "benchmark" are OK, but for "JSON" and "assertion" check the user's comfort level first. Briefly explain terms when in doubt.

## Creating a Skill

### Step 1: Capture Intent

Start by understanding what the user wants. The conversation might already contain a workflow to capture. If so, extract answers from history first — tools used, sequence of steps, corrections made, formats observed. Ask the user to fill gaps and confirm before proceeding.

Key questions:
1. What should this skill enable Claude to do?
2. When should this skill trigger? (what user phrases/contexts)
3. What's the expected output format?
4. Should we set up test cases to verify it works?

### Step 2: Interview and Research

Proactively ask about edge cases, input/output formats, example files, success criteria, and dependencies. Use available tools to research docs, find similar skills, look up best practices. Come prepared with context to reduce burden on the user.

### Step 3: Write the SKILL.md

#### Skill Directory Structure

```
skill-name/
├── SKILL.md           (required)
│   ├── YAML frontmatter (name, description required)
│   └── Markdown instructions
└── Bundled Resources  (optional)
    ├── scripts/       Executable code for deterministic/repetitive tasks
    ├── references/    Docs loaded into context as needed
    └── assets/        Files used in output (templates, icons, fonts)
```

#### YAML Frontmatter

```yaml
---
name: skill-name
description: When to trigger and what it does. Be specific and slightly "pushy" — include contexts where the skill should activate even if the user doesn't explicitly name it.
---
```

The description is the primary triggering mechanism. All "when to use" info goes here, not in the body. Claude tends to "undertrigger" skills, so make descriptions proactive.

**Good description**: "Build dashboards to display internal data. Use whenever the user mentions dashboards, data visualization, internal metrics, or wants to display any kind of data, even if they don't explicitly ask for a 'dashboard.'"

**Bad description**: "How to build a dashboard."

#### Writing Patterns

- Keep SKILL.md under 500 lines
- Use progressive disclosure: metadata (~100 words) always in context, SKILL.md body when triggered, bundled resources as needed
- Prefer imperative form in instructions
- Explain the **why** behind instructions — today's LLMs are smart and respond better to reasoning than rigid MUSTs
- Include examples of expected output format
- For multi-domain skills, organize by variant with separate reference files

#### Principle of Lack of Surprise

Skills must not contain malware, exploit code, or any content that could compromise security. A skill's contents should not surprise the user in intent.

### Step 4: Where to Save

Ask the user where to save the skill:

| Location | Command |
|----------|---------|
| Project-level | `mkdir -p .claude/skills/<name>` |
| User-level (all projects) | `mkdir -p ~/.claude/skills/<name>` |

Write the SKILL.md to the chosen location.

### Step 5: Test Cases

After writing the draft, create 2-3 realistic test prompts — things a real user would actually say. Share them with the user for approval, then run them.

Save test cases to `evals/evals.json` in the skill directory:

```json
{
  "skill_name": "example-skill",
  "evals": [
    {
      "id": 1,
      "prompt": "Realistic user prompt",
      "expected_output": "Description of expected result",
      "files": []
    }
  ]
}
```

### Step 6: Evaluate and Iterate

For each test case:
1. Run with the skill and without (baseline)
2. Compare results
3. Get user feedback
4. Improve the skill based on feedback
5. Repeat

When improving:
- **Generalize from feedback** — don't overfit to specific examples
- **Keep the prompt lean** — remove things that aren't pulling their weight
- **Explain the why** — reasoning beats rigid instructions
- **Look for repeated work** — if test runs all write similar helper scripts, bundle that script in `scripts/`

## Description Optimization

After creating or improving a skill, offer to optimize the description for better triggering.

1. Generate 20 eval queries — mix of should-trigger (8-10) and should-not-trigger (8-10)
2. Make queries realistic with detail, file paths, context, casual speech
3. For should-not-trigger, use near-misses — queries that share keywords but need something different
4. Review with user
5. Test current description against queries
6. Iterate on description to improve trigger accuracy

## Quick Reference: Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Skill identifier (lowercase, hyphens) |
| `description` | Yes | When to trigger + what it does |
| `allowed-tools` | No | Restrict available tools |
| `disable-model-invocation` | No | `true` = only user can invoke |
| `user-invocable` | No | `false` = hide from / menu |
| `context` | No | `fork` = run in isolated subagent |
| `agent` | No | Subagent type for context:fork |
| `model` | No | Model override |
