---
name: skill-evals
description: Test, benchmark, and evaluate Claude Code skills. Use when users want to run evals on a skill, test skill quality, benchmark skill performance, measure pass rates, compare skill versions, check for regressions, or validate that a skill works correctly. Also use when someone says "test my skill", "evaluate this skill", or "is this skill working".
---

# Skill Evals

Test, benchmark, and evaluate Claude Code skills to ensure they work correctly and improve over time.

## Why Run Evals?

- **Catch regressions** — a skill that worked last month might behave differently with model updates
- **Measure quality** — pass rates, timing, and token usage give you quantitative signals
- **Compare versions** — A/B test old vs new skill versions
- **Validate triggers** — ensure the skill activates for the right prompts and stays quiet for the wrong ones

## Quick Start

When the user wants to evaluate a skill:

1. Identify the skill to evaluate (ask for path or name)
2. Read the SKILL.md to understand what it does
3. Generate test prompts (or use existing `evals/evals.json`)
4. Run the test prompts with and without the skill
5. Grade the results
6. Report findings

## Step 1: Identify the Skill

Find the skill to evaluate. Check these locations in order:

```bash
# Project skills
ls .claude/skills/

# User skills
ls ~/.claude/skills/

# Check if skill name was provided
# e.g., "evaluate my lint-fix skill"
```

Read the SKILL.md to understand:
- What the skill should do
- When it should trigger
- What tools it uses
- What output format is expected

## Step 2: Create or Load Eval Cases

### Create New Evals

Generate 5-10 realistic test prompts. Each eval needs:

```json
{
  "skill_name": "my-skill",
  "evals": [
    {
      "id": 1,
      "prompt": "Realistic user prompt that should trigger the skill",
      "expected_output": "Description of what good output looks like",
      "should_trigger": true,
      "files": [],
      "assertions": [
        {
          "text": "Output contains a summary section",
          "type": "contains"
        },
        {
          "text": "No errors in the output",
          "type": "absence"
        }
      ]
    },
    {
      "id": 2,
      "prompt": "A prompt that should NOT trigger this skill",
      "expected_output": "Skill should not activate",
      "should_trigger": false,
      "files": [],
      "assertions": []
    }
  ]
}
```

### Write Good Test Prompts

**Should-trigger prompts (5-7)**:
- Use different phrasings of the same intent
- Include casual speech, abbreviations, typos
- Cover common AND uncommon use cases
- Include cases where the user doesn't name the skill explicitly
- Add realistic detail: file paths, names, context

**Should-not-trigger prompts (3-5)**:
- Use near-misses — queries that share keywords but need something different
- Don't make them obviously irrelevant
- Test adjacent domains and ambiguous phrasing

**Bad**: `"Write a function"` (too generic)
**Good**: `"hey so i have this python file in src/utils/parser.py and its got like 30 flake8 warnings, mostly unused imports and line length stuff. can you clean it up?"` (realistic, detailed)

### Load Existing Evals

Check for existing eval files:

```bash
# Check skill directory
cat <skill-path>/evals/evals.json
```

## Step 3: Run the Evals

For each eval case, run two versions:

### With Skill (test)
Ask Claude to perform the task with the skill available. Record:
- The output produced
- Time taken
- Whether the skill triggered
- Any errors

### Without Skill (baseline)
Run the same prompt without the skill. This shows what Claude does by default, so you can measure the skill's added value.

### For Skill Improvements
If comparing old vs new versions:
- Snapshot the old skill first
- Run evals against both versions
- Compare side by side

## Step 4: Grade the Results

### Assertion Types

| Type | Check |
|------|-------|
| `contains` | Output contains the specified text/pattern |
| `absence` | Output does NOT contain the text/pattern |
| `file_exists` | A specific file was created |
| `file_contains` | A created file contains specific content |
| `command_ran` | A specific command was executed |
| `format` | Output matches expected format/structure |

### Grading Format

For each eval, produce a grading result:

```json
{
  "eval_id": 1,
  "eval_name": "lint-fix-python-project",
  "triggered": true,
  "assertions": [
    {
      "text": "Linter ran successfully",
      "passed": true,
      "evidence": "ESLint executed with exit code 0"
    },
    {
      "text": "All fixable errors were fixed",
      "passed": false,
      "evidence": "3 errors remain in src/utils.js"
    }
  ],
  "overall_pass": false
}
```

### Grading Tips

- **Grade outcomes, not steps** — focus on whether objectives were achieved, not specific command sequences
- For subjective skills (writing style, design), use qualitative review instead of assertions
- For deterministic checks (file created, command ran), write scripts to verify programmatically

## Step 5: Benchmark and Report

### Metrics to Collect

| Metric | Description |
|--------|-------------|
| **Pass rate** | % of assertions that pass |
| **Trigger rate** | % of should-trigger prompts that activated the skill |
| **False positive rate** | % of should-not-trigger prompts that activated anyway |
| **Time** | Duration per eval (seconds) |
| **Tokens** | Token usage per eval |

### Report Format

Present results as a summary table:

```
## Eval Results: lint-fix

| Eval | Triggered | Pass Rate | Time | Tokens |
|------|-----------|-----------|------|--------|
| python-project | Yes | 4/5 (80%) | 12s | 8,420 |
| js-project | Yes | 5/5 (100%) | 8s | 6,100 |
| no-lint-errors | Yes | 3/3 (100%) | 3s | 2,200 |
| unrelated-task | No (correct) | - | - | - |

Overall pass rate: 92%
Trigger accuracy: 100%
Avg time: 7.7s
Avg tokens: 5,573
```

### Compare Versions (if applicable)

```
## Comparison: v1 vs v2

| Metric | v1 (old) | v2 (new) | Delta |
|--------|----------|----------|-------|
| Pass rate | 75% | 92% | +17% |
| Trigger rate | 80% | 100% | +20% |
| Avg time | 15s | 8s | -47% |
| Avg tokens | 12,000 | 5,500 | -54% |
```

## Step 6: Recommend Improvements

Based on eval results, suggest specific improvements:

1. **Failed assertions** — what went wrong and how to fix the SKILL.md
2. **Trigger misses** — how to improve the description for better triggering
3. **False positives** — how to make the description more specific
4. **Performance** — how to reduce token usage or time
5. **Regressions** — what changed since the last eval run

Save the eval results to `<skill-path>/evals/results/` with a timestamp for tracking over time.

## Eval Storage

```
my-skill/
├── SKILL.md
└── evals/
    ├── evals.json              # Test cases
    └── results/
        ├── 2025-01-15.json     # Historical results
        └── 2025-01-20.json
```
