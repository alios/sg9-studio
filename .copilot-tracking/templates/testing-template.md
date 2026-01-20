# [Feature/Component] Testing Protocol

**Version:** 1.0  
**Date:** YYYY-MM-DD  
**Tester:** [Your Name or "AI Assistant"]  
**Status:** Not Started | In Progress | Passed | Failed

---

## Test Overview

**System Under Test:**  
[Component, feature, or system being tested]

**Test Objective:**  
[What this testing protocol validates or verifies]

**Test Type:**
- [ ] Unit Testing (individual functions/methods)
- [ ] Integration Testing (component interactions)
- [ ] System Testing (end-to-end workflows)
- [ ] Regression Testing (existing functionality)
- [ ] Performance Testing (speed, resource usage)
- [ ] Acceptance Testing (user requirements)

**Test Environment:**
- **Platform:** [macOS, Linux, NixOS, etc.]
- **Version:** [Software version being tested]
- **Dependencies:** [Required libraries, services, or configurations]
- **Test Data:** [Location of test files/fixtures]

---

## Prerequisites

**Setup Requirements:**
- [ ] [Software/tool] installed and configured
- [ ] [Environment variable] set
- [ ] [Test data] available at [location]
- [ ] [Service/daemon] running
- [ ] Workspace at: [path to your sg9-studio checkout]

**Pre-Test Validation:**
```bash
# Commands to verify test environment is ready
[validation commands]
```

**Expected Output:**
```
[What successful validation looks like]
```

---

## Test Scenarios

### Scenario 1: [Descriptive Title]

**Test ID:** T001  
**Priority:** High | Medium | Low  
**Type:** Functional | Performance | Security | Usability

**Description:**  
[What this scenario tests]

**Preconditions:**
- [State required before test begins]
- [Configuration needed]

**Test Steps:**
1. [Action to perform]
2. [Next action]
3. [Final action]

**Expected Result:**
- [What should happen]
- [Specific values or states]

**Actual Result:**
- [ ] Pass: [Record actual outcome if passed]
- [ ] Fail: [Record failure details if failed]

**Verification Method:**
```bash
# Command to verify outcome
[verification command]
```

**Success Criteria:**
- [ ] [Specific criterion 1]
- [ ] [Specific criterion 2]

---

### Scenario 2: [Descriptive Title]

**Test ID:** T002  
**Priority:** High | Medium | Low  
**Type:** Functional | Performance | Security | Usability

**Description:**  
[What this scenario tests]

**Preconditions:**
- [State required before test begins]

**Test Steps:**
1. [Action to perform]
2. [Next action]

**Expected Result:**
- [What should happen]

**Actual Result:**
- [ ] Pass: [Record actual outcome]
- [ ] Fail: [Record failure details]

**Verification Method:**
```bash
[verification command]
```

**Success Criteria:**
- [ ] [Criterion]

---

### Scenario 3: [Continue for all test scenarios]

---

## Edge Cases & Boundary Testing

### Edge Case 1: [Descriptive Title]

**Test ID:** E001  
**Description:** [What boundary condition this tests]

**Test Input:** [Extreme value, empty input, maximum value, etc.]  
**Expected Behavior:** [How system should handle edge case]  
**Actual Behavior:**
- [ ] Pass: [Outcome]
- [ ] Fail: [Outcome]

---

### Edge Case 2: [Descriptive Title]

**Test ID:** E002  
**Description:** [What boundary condition this tests]

**Test Input:** [Edge condition]  
**Expected Behavior:** [Expected handling]  
**Actual Behavior:**
- [ ] Pass: [Outcome]
- [ ] Fail: [Outcome]

---

## Error Handling Tests

### Error Test 1: [Invalid Input]

**Test ID:** ERR001  
**Description:** [What error condition this tests]

**Trigger Method:**
```bash
# Command or action that triggers error
[command]
```

**Expected Error:**
```
[Expected error message or code]
```

**Actual Error:**
- [ ] Pass: [Error handled correctly]
- [ ] Fail: [Error not handled or wrong message]

**Recovery Test:**
- [ ] System recovers gracefully
- [ ] No data corruption
- [ ] User receives clear error message

---

### Error Test 2: [Continue for all error scenarios]

---

## Performance Benchmarks

### Performance Test 1: [Metric Name]

**Test ID:** PERF001  
**Metric:** [Response time, throughput, CPU usage, memory usage, etc.]  
**Target:** [Acceptable value or range]

**Test Method:**
```bash
# Command to measure performance
[benchmark command]
```

**Baseline (before changes):** [Value]  
**Current (after changes):** [Value]  
**Delta:** [Difference, +/- %]

**Result:**
- [ ] Pass: Within acceptable range
- [ ] Fail: Exceeds target

---

### Performance Test 2: [Continue for all performance metrics]

---

## Regression Testing Checklist

**Existing Functionality to Verify:**
- [ ] [Feature 1] still works as expected
- [ ] [Feature 2] not affected by changes
- [ ] [Integration point 3] still functional

**Test Commands:**
```bash
# Commands to verify no regressions
[regression test commands]
```

**Result:**
- [ ] All regression tests passed
- [ ] Regression detected: [Details]

---

## Test Data & Fixtures

**Test Files:**
- `path/to/test-file-1.ext` - [Purpose]
- `path/to/test-file-2.ext` - [Purpose]

**Test Data Characteristics:**
| File | Size | Format | Content | Purpose |
|------|------|--------|---------|---------|
| [File 1] | [Size] | [Format] | [Description] | [Why used] |
| [File 2] | [Size] | [Format] | [Description] | [Why used] |

**Cleanup After Testing:**
```bash
# Commands to remove test artifacts
[cleanup commands]
```

---

## Acceptance Criteria

**Must Pass:**
- [ ] All high-priority test scenarios pass
- [ ] No critical errors or crashes
- [ ] Performance meets or exceeds targets
- [ ] No regressions in existing functionality

**Should Pass:**
- [ ] Medium-priority scenarios pass
- [ ] Edge cases handled gracefully
- [ ] Error messages are clear and helpful

**Nice to Have:**
- [ ] Low-priority scenarios pass
- [ ] Performance exceeds targets significantly
- [ ] User experience improvements noted

**Overall Test Status:**
- [ ] **PASSED** - All acceptance criteria met
- [ ] **PASSED WITH ISSUES** - Core functionality works, minor issues noted
- [ ] **FAILED** - Critical issues prevent acceptance

---

## Issues Found

### Issue 1: [Descriptive Title]

**Severity:** Critical | High | Medium | Low  
**Test ID:** [Which test revealed this issue]

**Description:**  
[What the issue is]

**Steps to Reproduce:**
1. [Step 1]
2. [Step 2]

**Expected Behavior:**  
[What should happen]

**Actual Behavior:**  
[What actually happens]

**Error Messages:**
```
[Error output]
```

**Workaround:**  
[Temporary fix, if any]

**Resolution:**
- [ ] Fixed in [version/commit]
- [ ] Deferred to [future milestone]
- [ ] Won't fix: [Justification]

---

### Issue 2: [Continue for all issues found]

---

## Test Coverage

**Code Coverage:**
- Lines covered: [X%]
- Branches covered: [X%]
- Functions covered: [X%]

**Feature Coverage:**
| Feature | Tested | Coverage | Notes |
|---------|--------|----------|-------|
| [Feature 1] | ✅ | 100% | [Notes] |
| [Feature 2] | ✅ | 80% | [What's not covered] |
| [Feature 3] | ⏳ | 0% | [Reason not tested] |

**Untested Areas:**
- [Area 1]: [Reason]
- [Area 2]: [Reason]

---

## Test Execution Log

**Test Run #1:**
- **Date:** YYYY-MM-DD HH:MM
- **Tester:** [Name]
- **Duration:** [X minutes]
- **Result:** [X passed, Y failed]
- **Notes:** [Observations]

**Test Run #2:**
- **Date:** YYYY-MM-DD HH:MM
- **Tester:** [Name]
- **Duration:** [X minutes]
- **Result:** [X passed, Y failed]
- **Notes:** [Observations]

---

## Recommendations

**For Release:**
- [ ] Ready for production
- [ ] Ready with known issues (documented above)
- [ ] Not ready - critical issues must be resolved

**Future Testing:**
- [Suggestion for additional test coverage]
- [Automated testing opportunity]
- [Performance optimization area]

**Documentation Updates Needed:**
- [ ] User documentation reflects tested behavior
- [ ] API documentation accurate
- [ ] Known issues documented

---

## References

**Testing Tools:**
- [Tool 1](URL or command)
- [Tool 2](URL or command)

**Test Standards:**
- [Testing methodology followed]
- [Industry standard referenced]

**Related Documents:**
- [Implementation instructions](link)
- [Technical specification](link)

---

## Changelog

- **v1.0 (YYYY-MM-DD):** Initial test protocol created
- **v1.1 (YYYY-MM-DD):** [Updates after test run]
