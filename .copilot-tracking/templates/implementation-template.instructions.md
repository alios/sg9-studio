# [Task Title] - Implementation Instructions

**Version:** 1.0  
**Date:** YYYY-MM-DD  
**Author:** [Your Name or "AI Assistant"]  
**Status:** Not Started | In Progress | Completed | Blocked

---

## Task Overview

**Objective:**  
[Single-sentence description of what this implementation achieves]

**Context:**  
[2-3 sentences explaining why this is needed, what problem it solves, or what value it provides]

**Estimated Complexity:** Low | Medium | High  
**Estimated Time:** [X hours/days]

**Related Documents:**
- Research: [Link to research document if applicable]
- Design: [Link to design document if applicable]
- Testing: [Link to testing protocol]

---

## Prerequisites

**Knowledge Requirements:**
- [ ] Understanding of [technology/concept 1]
- [ ] Familiarity with [technology/concept 2]
- [ ] Read [relevant documentation]

**System Requirements:**
- [ ] [Software/tool] version X.Y or higher
- [ ] [Environment variable] configured
- [ ] [Permission/access] granted

**Code Dependencies:**
- [ ] [Module/file] exists and is functional
- [ ] [Library/package] installed (version X.Y)
- [ ] [Configuration file] properly configured

**Workspace State:**
- [ ] Working directory clean (no uncommitted changes)
- [ ] Backup created (if modifying critical files)
- [ ] [Specific file/directory] exists

---

## Implementation Steps

### Step 1: [Descriptive Title]

**Objective:** [What this step accomplishes]

**Actions:**
1. [Specific action to take]
   ```bash
   # Example command
   [command here]
   ```

2. [Next action]
   - Detail or sub-action
   - Another detail

**Expected Outcome:**
- [What should happen after completing this step]
- [How to verify success]

**Verification:**
```bash
# Command to verify step completion
[verification command]
```

**Troubleshooting:**
- **Issue:** [Potential problem]  
  **Solution:** [How to resolve it]

---

### Step 2: [Descriptive Title]

**Objective:** [What this step accomplishes]

**Files to Create/Modify:**
- `path/to/file.ext` - [Purpose of modification]
- `path/to/another.ext` - [Purpose of modification]

**Actions:**
1. **Create [file/directory]:**
   ```[language]
   [Code or configuration content]
   ```

2. **Modify [existing file]:**
   - Locate: [Line number range or section identifier]
   - Change: [What to change from → to]
   - Add: [What new content to add]

**Expected Outcome:**
- [What should happen]
- [How to verify]

**Verification:**
```bash
# Verification command(s)
[command]
```

---

### Step 3: [Continue for all implementation steps]

---

## Testing Criteria

**Unit Tests:**
- [ ] [Specific test case 1]
- [ ] [Specific test case 2]

**Integration Tests:**
- [ ] [Integration scenario 1]
- [ ] [Integration scenario 2]

**Manual Validation:**
- [ ] [Manual check 1]
- [ ] [Manual check 2]

**Performance Checks:**
- [ ] [Performance criterion 1]
- [ ] [Performance criterion 2]

**Acceptance Criteria:**
- [ ] [Must-have criterion 1]
- [ ] [Must-have criterion 2]
- [ ] [Must-have criterion 3]

---

## Rollback Procedure

**If implementation fails at any step:**

1. **Identify failure point:**
   - Document which step failed
   - Capture error messages
   - Note system state

2. **Stop implementation:**
   - Do not proceed to next steps
   - Preserve current state for debugging

3. **Restore previous state:**
   ```bash
   # Rollback commands
   [specific commands to undo changes]
   ```

4. **Clean up artifacts:**
   - [ ] Remove partial files created
   - [ ] Restore original configurations
   - [ ] Clear temporary data

5. **Document failure:**
   - Create issue: `.copilot-tracking/research/[issue-name].md`
   - Include: error messages, steps attempted, system state
   - Tag: `blocked` status

---

## Post-Implementation

**Documentation Updates:**
- [ ] Update [relevant README.md]
- [ ] Update [API documentation]
- [ ] Update [user guide]

**Code Hygiene:**
- [ ] Remove debug statements
- [ ] Add/update comments
- [ ] Format code (run formatter)
- [ ] Run linter and fix warnings

**Version Control:**
```bash
# Commit message template
git add [files]
git commit -m "[type]: [concise description]

[Detailed explanation of changes]

Closes: #[issue-number]
Implements: [link to this instructions file]
"
```

**Notification:**
- [ ] Inform team/stakeholders
- [ ] Update project tracker
- [ ] Close related issues

---

## Success Metrics

**Immediately After Implementation:**
- [ ] All tests passing
- [ ] No errors in logs
- [ ] No regressions in existing functionality

**Short-term (24-48 hours):**
- [ ] [Metric 1]: [Target value]
- [ ] [Metric 2]: [Target value]

**Long-term (1-2 weeks):**
- [ ] [Metric 1]: [Target value]
- [ ] User feedback: [Criterion]

---

## Dependencies

**Blocks:**
- [Task A] - [Why this blocks progress]
- [Task B] - [Why this blocks progress]

**Blocked By:**
- [Prerequisite A] - [What's needed before this can start]
- [Prerequisite B] - [What's needed before this can start]

**Related Tasks:**
- [Parallel task A] - [Relationship]
- [Follow-up task B] - [Relationship]

---

## Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| [Risk 1] | Low/Med/High | Low/Med/High | [How to mitigate] |
| [Risk 2] | Low/Med/High | Low/Med/High | [How to mitigate] |

---

## Notes

**Implementation Notes:**
- [Important consideration during implementation]
- [Known limitation or constraint]
- [Future enhancement opportunity]

**Lessons Learned:**
- [Add after implementation: what went well]
- [Add after implementation: what could be improved]

---

## References

**Technical Documentation:**
- [Official docs](URL)
- [API reference](URL)

**Code Examples:**
- [Example implementation](URL or file path)
- [Similar pattern in codebase](file path)

**Related Issues:**
- [Issue #123](URL)
- [Discussion thread](URL)

---

## Changelog

- **v1.0 (YYYY-MM-DD):** Initial implementation instructions
- **v1.1 (YYYY-MM-DD):** [Update description]
