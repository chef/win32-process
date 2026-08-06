# GitHub Copilot Instructions for win32-process

## Purpose

This document defines the authoritative operational workflow for AI assistants contributing to the win32-process Ruby gem repository. This gem provides enhanced Process API functionality for Microsoft Windows platforms. All AI actions must operate through explicit user confirmation gates and repository safeguards.

## Repository Structure

```
win32-process/
├── .expeditor/                    # Chef Expeditor release automation
│   ├── config.yml                # Main Expeditor configuration
│   ├── run_windows_tests.ps1     # Windows-specific test script
│   ├── update_version.sh         # Version bump automation
│   └── verify.pipeline.yml       # CI pipeline configuration
├── .github/                      # GitHub configuration and templates
│   ├── workflows/                # CI/CD workflows
│   │   ├── lint.yml             # RuboCop linting workflow
│   │   └── unit.yml             # Cross-platform unit tests
│   ├── CODEOWNERS              # Repository ownership definitions
│   ├── ISSUE_TEMPLATE.md       # Issue reporting template
│   ├── PULL_REQUEST_TEMPLATE.md # PR template
│   └── dependabot.yml          # Dependency update configuration
├── examples/                     # Usage examples and demonstrations
│   ├── example_create.rb        # Process creation examples
│   └── example_kill.rb          # Process termination examples
├── lib/                         # Main library code
│   ├── win32-process.rb         # Primary entry point
│   └── win32/                   # Core implementation
│       ├── process.rb           # Main Process class
│       └── process/             # Implementation modules
│           ├── constants.rb     # Windows API constants
│           ├── functions.rb     # Windows API function bindings
│           ├── helper.rb        # Utility functions
│           ├── structs.rb       # Windows data structures
│           └── version.rb       # Gem version management
├── test/                        # Test suite
│   ├── test_win32_process.rb    # Core functionality tests
│   └── test_win32_process_kill.rb # Process termination tests
├── .rubocop.yml                 # Ruby code style configuration
├── CHANGELOG.md                 # Version history and changes
├── Gemfile                      # Bundler dependency specification
├── README.md                    # Project documentation
├── Rakefile                     # Build and test tasks
├── VERSION                      # Current version number
└── win32-process.gemspec        # Gem specification
```

## Tooling & Ecosystem

- **Language**: Ruby (3.1+ supported)
- **Platform**: Microsoft Windows (Windows 2019, Windows 2022)
- **Testing**: Minitest framework via `rake test`
- **Linting**: RuboCop with Cookstyle configuration
- **CI/CD**: GitHub Actions with Windows runners
- **Release**: Chef Expeditor automation
- **Dependencies**: Managed via Bundler (Gemfile)

## Issue (Jira/Tracker) Integration

This repository supports both Jira and GitHub Issues integration. Chef Software typically uses Atlassian Jira for issue tracking.

**When working with Jira issues:**
- Invocation Pattern: `mcp_atlassian-mcp_*` tools for issue retrieval and management
- Branch naming: `CHEF-123-short-description` or `CHF-456-feature-name`
- Link issues in PR descriptions: `Fixes CHEF-123` or reference Jira URL
- Parse: summary, description, acceptance criteria, issue type from Jira

**When working with GitHub issues:**
- Reference issue number in branch names: `issue-123-fix-process-creation`
- Link issues in PR descriptions using GitHub syntax: `Fixes #123`

**For all issue types:**
- Ensure implementation aligns with Windows API capabilities
- Verify reproduction on supported Windows versions for bug reports

Implementation Plan Template (MUST before code):
- **Goal**: Clear objective statement
- **Impacted Files**: List of files requiring changes
- **Public API/Interface Changes**: Any breaking or additive API changes
- **Data/Integration Considerations**: Windows API compatibility
- **Test Strategy**: Cross-platform testing approach
- **Edge Cases**: Windows version differences, permission scenarios
- **Risks & Mitigations**: Compatibility and stability concerns
- **Rollback Strategy**: Revert commit SHA or feature toggle

## Workflow Overview

**Phases (MUST follow in order):**

1. **Intake & Clarify**: Understand requirements and scope
2. **Repository Analysis**: Examine existing code patterns
3. **Plan Draft**: Create implementation plan
4. **Plan Confirmation**: User approval gate (requires "yes")
5. **Incremental Implementation**: Small, cohesive changes
6. **Lint / Style**: RuboCop validation
7. **Test & Coverage Validation**: Windows platform testing
8. **DCO Commit**: Developer Certificate of Origin compliance
9. **Push & Draft PR Creation**: Branch and PR setup
10. **Label & Risk Application**: Appropriate categorization
11. **Final Validation**: Complete checklist verification

Each phase ends with: **Step Summary + Checklist + "Continue to next step? (yes/no)"**.

## Detailed Step Instructions

**Principles (MUST):**
- Smallest cohesive change per commit
- Add/adjust tests immediately with each behavior change
- Present mapping of changes to tests before committing
- Maintain Windows API compatibility
- Preserve backwards compatibility unless explicitly breaking change

**Example Step Output:**
```
Step: Add boundary guard in process creation
Summary: Added nil check & size constraint; tests added for empty input & overflow cases.
Checklist:
- [x] Plan
- [x] Implementation  
- [ ] Tests
- [ ] Windows compatibility verification
Proceed? (yes/no)
```

If user responds other than explicit "yes" → AI MUST pause & clarify.

## Branching & PR Standards

**Branch Naming (MUST):** 
- GitHub issue: `issue-123-short-description`
- Feature work: `feature-kebab-case-description` (≤40 chars)
- Bug fixes: `fix-kebab-case-description` (≤40 chars)

**One logical change set per branch (MUST).**

**PR MUST remain draft until:**
- Tests pass on all Windows platforms
- RuboCop linting passes
- Coverage mapping completed
- Windows API compatibility verified

**PR Description Sections (per existing template):**
- **Description**: What this change achieves
- **Issues Resolved**: GitHub issues, discussions referenced  
- **Check List**: Testing, DCO compliance verification

**Risk Classification (MUST pick one):**
- **Low**: Localized, non-breaking, test-only changes
- **Moderate**: Shared module changes, minor API additions
- **High**: Public API changes, Windows API integration changes

**Rollback Strategy (MUST):** `git revert <commit-SHA>` or feature toggle reference.

## Commit & DCO Policy

**Commit format (MUST):**
```
{{TYPE}}({{OPTIONAL_SCOPE}}): {{SUBJECT}} ({{ISSUE_KEY}})

Rationale explaining what and why this change was made.

Issue: #123 or none
Signed-off-by: Full Name <email@domain>
```

**Missing sign-off → block and request name/email.**

## Testing & Coverage

**Changed Logic → Test Assertions Mapping (MUST):**

| File | Method/Block | Change Type | Test File | Assertion Reference |
|------|--------------|-------------|-----------|-------------------|
| lib/win32/process.rb | create_process | Added validation | test/test_win32_process.rb | test_create_with_invalid_args |

**Coverage Threshold (MUST):** ≥80% changed lines (qualitative reasoning allowed if tooling absent).

**Edge Cases (MUST enumerate for each plan):**
- **Large input / boundary size**: Command line length limits
- **Empty / nil input**: Null parameter handling  
- **Invalid / malformed data**: Malformed command strings
- **Platform-specific differences**: Windows version variations
- **Concurrency / timing**: Process creation/termination races
- **External dependency failures**: Windows API call failures
- **Permission scenarios**: Administrative vs user privileges

**Platform Requirements:**
- Tests MUST pass on Windows 2019 and Windows 2022
- Ruby 3.1+ compatibility required
- Windows API integration points require validation

## Labels Reference

| Name | Description | Typical Use |
|------|-------------|-------------|
| **Aspect: Documentation** | How do we use this project? | README, API docs, examples |
| **Aspect: Integration** | Works correctly with other projects | Windows API compatibility |
| **Aspect: Packaging** | Distribution artifacts | Gem building, release |
| **Aspect: Performance** | System performance impact | Optimization work |
| **Aspect: Portability** | Platform compatibility | Windows version support |
| **Aspect: Security** | Security implications | Privilege escalation, process isolation |
| **Aspect: Stability** | Consistent results | Bug fixes, reliability |
| **Aspect: Testing** | Coverage and CI health | Test improvements |
| **Expeditor: Bump Version Major** | Breaking changes | API incompatibility |
| **Expeditor: Bump Version Minor** | Feature additions | New functionality |
| **Expeditor: Skip All** | Skip automation | Emergency fixes |
| **Expeditor: Skip Changelog** | Skip changelog update | Documentation-only |
| **Expeditor: Skip Version Bump** | No version change | Internal changes |
| **dependencies** | Dependency updates | Gemfile, gemspec changes |
| **oss-standards** | OSS compliance | License, DCO, standards |

**Mapping Guidance:**
- Bug fixes → **Aspect: Stability**
- New features → **Aspect: Integration** + **Expeditor: Bump Version Minor**
- Documentation → **Aspect: Documentation**
- Security issues → **Aspect: Security**
- Performance → **Aspect: Performance**
- Windows compatibility → **Aspect: Portability**

## CI / Release Automation Integration

**GitHub Workflows:**
- **lint.yml**: RuboCop linting on Ubuntu with Ruby 3.1, triggered on PR/push to main
- **unit.yml**: Cross-platform testing on Windows 2019/2022 with Ruby 3.1/3.4, triggered on PR/push to main

**Expeditor Release Automation:**
- **Version Management**: Automatic patch bumps, manual minor/major via labels
- **Changelog**: Automated generation from PR titles/descriptions
- **Gem Publishing**: Automatic RubyGems.org publishing on promotion
- **Branch Management**: Auto-delete merged PR branches

**Version Bump Mechanism:**
- Default: Patch version increment
- Minor: Apply "Expeditor: Bump Version Minor" label
- Manual: Edit VERSION file directly
- Tag Format: `win32-process-{{version}}`

**AI MUST NOT directly edit release automation configs without explicit user instruction.**

## Security & Protected Files

**Protected Files (NEVER edit without explicit approval):**
- `LICENSE` - Gem licensing terms
- `CODEOWNERS` - Repository ownership definitions  
- `.expeditor/config.yml` - Release automation configuration
- `.github/workflows/*.yml` - CI/CD pipeline definitions
- `CHANGELOG.md` - Version history (Expeditor managed)

**NEVER:**
- Exfiltrate or inject secrets or credentials
- Force-push to main branch
- Merge PR autonomously
- Insert new binaries without justification
- Remove license headers from source files
- Fabricate issue or label data
- Modify Windows API security contexts without explicit approval

## Prompts Pattern (Interaction Model)

After each step AI MUST output:
```
Step: {{STEP_NAME}}
Summary: {{CONCISE_OUTCOME}}
Checklist: 
- [x] {{COMPLETED_ITEM}}
- [ ] {{PENDING_ITEM}}
Prompt: "Continue to next step? (yes/no)"
```

**Non-affirmative response → AI MUST pause & clarify.**

## Validation & Exit Criteria

**Task is COMPLETE ONLY IF:**

1. ✅ Feature/fix branch exists & pushed
2. ✅ RuboCop linting passes  
3. ✅ Tests pass on Windows 2019 and Windows 2022
4. ✅ Tests pass with Ruby 3.1 and 3.4
5. ✅ Coverage mapping complete + ≥80% changed lines
6. ✅ PR open (draft or ready) with required sections
7. ✅ Appropriate labels applied
8. ✅ All commits DCO-compliant (Signed-off-by present)
9. ✅ No unauthorized Protected File modifications
10. ✅ Windows API compatibility verified
11. ✅ User explicitly confirms completion

**Otherwise AI MUST list unmet items.**

## Issue Planning Template

```
Issue: #123
Summary: <from GitHub issue>
Acceptance Criteria:
- <criterion 1>
- <criterion 2>

Implementation Plan:
- **Goal**: Clear objective
- **Impacted Files**: File list with change types
- **Public API Changes**: None | Additive | Breaking
- **Data/Integration Considerations**: Windows API compatibility notes
- **Test Strategy**: Platform coverage plan
- **Edge Cases**: Windows-specific scenarios
- **Risks & Mitigations**: Compatibility and stability risks
- **Rollback**: git revert <SHA>

Proceed? (yes/no)
```

## PR Description Canonical Template

Since `.github/PULL_REQUEST_TEMPLATE.md` exists, AI MUST use that structure and inject additional required sections:

```markdown
### Description
[What this change achieves and why]

### Issues Resolved
[GitHub issues: Fixes #123 | Related discussions]

### Tests & Coverage
**Changed lines:** N | **Estimated covered:** ~X% | **Mapping:** Complete
**Windows platforms tested:** 2019, 2022 | **Ruby versions:** 3.1, 3.4

### Risk & Mitigations  
**Risk:** Low | **Mitigation:** revert commit SHA | **Windows API impact:** None

### DCO
All commits signed off with Developer Certificate of Origin.

### Check List
- [ ] New functionality includes tests
- [ ] All tests pass on Windows platforms
- [ ] RuboCop linting passes
- [ ] Windows API compatibility verified
- [ ] All commits have been signed-off for the Developer Certificate of Origin
```

## Idempotency Rules

**Re-entry Detection Order (MUST):**

1. **Branch existence**: `git rev-parse --verify <branch>`
2. **PR existence**: `gh pr list --head <branch>`  
3. **Uncommitted changes**: `git status --porcelain`
4. **Test status**: Last CI run results
5. **Windows compatibility**: Platform-specific test results

**Delta Summary (MUST):**
- **Added Sections**: New functionality or test coverage
- **Modified Sections**: Changed implementation or fixes  
- **Deprecated Sections**: Backwards compatibility notes
- **Rationale**: Windows API evolution, Ruby version support

## Failure Handling

**Decision Tree (MUST):**

- **Labels fetch fails** → Abort; prompt: "Provide label list manually or fix auth. Retry? (yes/no)"
- **Issue fetch incomplete** → Ask: "Missing acceptance criteria—provide or proceed with inferred? (provide/proceed)"
- **Coverage < threshold** → Add tests; re-run; block commit until satisfied
- **Windows tests fail** → Investigate platform-specific issues; block until resolved
- **Missing DCO** → Request user name/email for sign-off
- **Protected file modification attempt** → Reject & restate policy
- **RuboCop failures** → Fix style issues; re-run linting
- **Windows API compatibility issues** → Research API documentation; verify platform support

## Glossary

- **Changed Lines Coverage**: Portion of modified lines executed by test assertions
- **Implementation Plan Freeze Point**: No code changes allowed until user approval
- **Protected Files**: Policy-restricted assets requiring explicit user authorization  
- **Idempotent Re-entry**: Resuming workflow without duplicated or conflicting state
- **Risk Classification**: Qualitative impact assessment (Low/Moderate/High)
- **Rollback Strategy**: Concrete reversal action (revert commit / disable feature)
- **DCO**: Developer Certificate of Origin sign-off confirming contribution rights
- **Windows API Compatibility**: Ensuring changes work across supported Windows versions

## Quick Reference Commands

```bash
# Standard development flow
git checkout -b issue-123-feature-name
bundle install
bundle exec rake test          # Run test suite
bundle exec cookstyle --chefstyle -c .rubocop.yml  # Lint code
git add .
git commit -m "feat(process): add capability (#123)" -s
git push -u origin issue-123-feature-name
gh pr create --base main --head issue-123-feature-name --title "#123: Short summary" --draft
gh pr edit <PR_NUMBER> --add-label "Aspect: Integration"

# Platform-specific testing
bundle exec rake test          # Windows-only (runs on CI)

# Release automation (Expeditor managed)
# Version bumps via labels: "Expeditor: Bump Version Minor"
# Changelog: Automated from PR titles
# Publishing: Automated on merge to main
```

## AI-Assisted Development & Compliance

- ✅ Create PR with `ai-assisted` label (if label doesn't exist, create it with description "Work completed with AI assistance following Progress AI policies" and color "9A4DFF")
- ✅ Include "This work was completed with AI assistance following Progress AI policies" in PR description

### Jira Ticket Updates (MANDATORY)

- ✅ **IMMEDIATELY after PR creation**: Update Jira ticket custom field `customfield_11170` ("Does this Work Include AI Assisted Code?") to "Yes"
- ✅ Use atlassian-mcp tools to update the Jira field programmatically
- ✅ **CRITICAL**: Use correct field format: `{"customfield_11170": {"value": "Yes"}}`
- ✅ Verify the field update was successful

### Documentation Requirements

- ✅ Reference AI assistance in commit messages where appropriate
- ✅ Document any AI-generated code patterns or approaches in PR description
- ✅ Maintain transparency about which parts were AI-assisted vs manual implementation

### Workflow Integration

This AI compliance checklist should be integrated into the main development workflow Step 4 (Pull Request Creation):

```
Step 4: Pull Request Creation & AI Compliance
- Step 4.1: Create branch and commit changes WITH SIGNED-OFF COMMITS
- Step 4.2: Push changes to remote
- Step 4.3: Create PR with ai-assisted label
- Step 4.4: IMMEDIATELY update Jira customfield_11170 to "Yes"
- Step 4.5: Verify both PR labels and Jira field are properly set
- Step 4.6: Provide complete summary including AI compliance confirmation
```

- **Never skip Jira field updates** - This is required for Progress AI governance
- **Always verify updates succeeded** - Check response from atlassian-mcp tools
- **Treat as atomic operation** - PR creation and Jira updates should happen together
- **Double-check before final summary** - Confirm all AI compliance items are completed

### Audit Trail

All AI-assisted work must be traceable through:

1. GitHub PR labels (`ai-assisted`)
2. Jira custom field (`customfield_11170` = "Yes")
3. PR descriptions mentioning AI assistance
4. Commit messages where relevant
