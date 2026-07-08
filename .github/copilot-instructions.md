# Copilot Code Review Instructions

## Review priority

Review the full PR holistically before commenting. Prioritize issues in this order:

1. Correctness bugs
2. Security issues
3. Data-loss or migration risks
4. Performance regressions
5. Missing or weak tests
6. Maintainability issues

## Commenting rules

- Prefer fewer, higher-confidence comments over many minor comments.
- Group repeated issues into one comment when they share the same root cause.
- Do not comment on purely stylistic issues unless they violate repository conventions.
- When suggesting a fix, mention whether the same pattern appears elsewhere in the PR.
- Check whether a proposed fix could introduce a second-order bug.

## Testing expectations

- Flag missing tests for changed behavior.
- Check edge cases and failure paths.
- Verify that existing tests still cover the modified logic.

## Security checks

- Check for missing authorization checks.
- Check for unsafe input handling.
- Check for accidental exposure of secrets, tokens, or personal data.
