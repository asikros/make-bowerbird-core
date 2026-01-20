# Proposal: Live Integration Tests and Improved Error Handling

**Status:** Draft
**Created:** 2026-01-20
**Author:** System

## Summary

Add live integration tests that clone real git repositories to verify `git-dependency` works end-to-end, and improve error handling to ensure failed clones don't leave the filesystem in a bad state.

## Motivation

### Current State

**Tests are all mocked:**
- All `test-git-dependency-mock-*.mk` tests use `BOWERBIRD_MOCK_RESULTS` to capture shell commands instead of executing them
- We test that the correct commands are generated, but not that they actually work
- Real-world failures (network issues, authentication, malformed URLs) are never tested

**Error handling has gaps:**
- If `git clone` fails (line 134), we exit with error but don't clean up the partially created directory
- Only the "entry point not found" error path (line 142-146) does cleanup with `\rm -rf $1`
- This can leave `.make/deps/` in a bad state requiring manual cleanup

**API ambiguity:**
- `branch` parameter is used for both branches and tags (works but semantically unclear)
- Users might not realize tags can be used with `branch=v1.2.3`
- No validation that branch/tag/revision are mutually exclusive at parse time

## Proposal

### 1. Add Live Integration Tests

Create `test/bowerbird-deps/test-git-dependency-live-*.mk` that actually clone real repositories:

**Test repos to use:**
- `https://github.com/asikros/make-bowerbird-core.git` - small, stable, we control it
- `https://github.com/asikros/make-bowerbird-core.git` - small, stable, we control it

**Test cases:**
```makefile
test-git-dependency-live-branch:
	# Clone with branch=main
	# Verify .git is removed
	# Verify entry point exists

test-git-dependency-live-tag:
	# Clone with branch=0.1.0 (semantic tag)
	# Verify works same as branch

test-git-dependency-live-revision:
	# Clone with specific commit SHA
	# Verify correct revision checked out

test-git-dependency-live-dev-mode:
	# Clone with --bowerbird-dev-mode flag
	# Verify .git directory is preserved
	# Verify we can git log, etc.

test-git-dependency-live-failure-cleanup:
	# Force a clone failure (bad URL)
	# Verify partial directory is cleaned up
	# Verify error message is helpful
```

**Benefits:**
- Catch real-world issues (network, git protocol changes, authentication)
- Verify cleanup actually works
- Test dev mode actually preserves .git
- Confidence for releases

**Considerations:**
- Network required (skip on offline systems)
- Slower than mocked tests
- Can fail due to GitHub downtime (not our fault)
- Should be separate from fast mock tests

### 2. Improve Error Handling

**Fix clone failure cleanup:**

```makefile
$1/.:
	$$(if $(__BOWERBIRD_KEEP_GIT),@echo "INFO: Cloning dependency in DEV mode: $2")
	@git clone --config advice.detachedHead=false \
			--config http.lowSpeedLimit=1000 \
			--config http.lowSpeedTime=60 \
			$$(__BOWERBIRD_CLONE_DEPTH) \
			$$(if $3,--branch $3,--revision $4) \
			$2 \
			$1 || \
		(\rm -rf $1 && \
		>&2 echo "ERROR: Failed to clone $2 $$(if $3,[branch: $3],[revision: $4])" && \
		exit 1)
	@test -n "$1" && test -d "$1/.git" || \
		(\rm -rf $1 && \
		>&2 echo "ERROR: Clone validation failed for $1" && \
		exit 1)
	$$(if $(__BOWERBIRD_KEEP_GIT),,@\rm -rfv -- "$1/.git")
```

**Changes:**
- Add `\rm -rf $1` to clone failure path (line 140)
- Add more detailed error messages showing URL and branch/revision
- Consistent with entry point failure cleanup

### 3. Add Explicit `tag` Parameter (Optional Enhancement)

**Current API:**
```makefile
$(call bowerbird::core::git-dependency, \
    name=dep, \
    url=https://github.com/org/repo.git, \
    branch=v1.2.3, \
    entry=lib.mk)
```

**Proposed enhanced API:**
```makefile
# Mutually exclusive: branch XOR tag XOR revision
$(call bowerbird::core::git-dependency, \
    name=dep, \
    url=https://github.com/org/repo.git, \
    tag=v1.2.3, \
    entry=lib.mk)
```

**Implementation:**
- Add `tag` as valid kwarg
- Validation: error if more than one of `branch`, `tag`, `revision` specified
- Both `branch` and `tag` use `--branch` flag (git treats them the same)
- Clearer semantics for users

**Example validation:**
```makefile
$(if $(and $(call bowerbird::temp::kwargs-defined,branch),$(call bowerbird::temp::kwargs-defined,tag)),\
    $(error ERROR: Cannot specify both 'branch' and 'tag'))
$(if $(and $(call bowerbird::temp::kwargs-defined,branch),$(call bowerbird::temp::kwargs-defined,revision)),\
    $(error ERROR: Cannot specify both 'branch' and 'revision'))
$(if $(and $(call bowerbird::temp::kwargs-defined,tag),$(call bowerbird::temp::kwargs-defined,revision)),\
    $(error ERROR: Cannot specify both 'tag' and 'revision'))
$(if $(or $(call bowerbird::temp::kwargs-defined,branch),\
          $(call bowerbird::temp::kwargs-defined,tag),\
          $(call bowerbird::temp::kwargs-defined,revision)),,\
    $(error ERROR: Must specify one of 'branch', 'tag', or 'revision'))
```

## Implementation Plan

### Phase 1: Error Handling (Required)
1. Update `bowerbird-deps.mk` clone failure handling
2. Add better error messages
3. Update `bowerbird-temp-deps.mk` to match
4. Verify with existing mock tests

### Phase 2: Live Tests (Required)
1. Create `test/bowerbird-deps/test-git-dependency-live-branch.mk`
2. Create `test/bowerbird-deps/test-git-dependency-live-revision.mk`
3. Create `test/bowerbird-deps/test-git-dependency-live-dev-mode.mk`
4. Create `test/bowerbird-deps/test-git-dependency-live-failure.mk`
5. Update CI workflow to run live tests (with network permission)
6. Document how to run live vs mock tests

### Phase 3: Tag Parameter (Optional)
1. Add `tag` to kwargs-parse
2. Update validation logic
3. Pass tag same as branch to `__git_dependency_impl`
4. Update documentation and examples
5. Add tests for tag parameter
6. Mark `branch=<tag>` pattern as deprecated (still works)

## Testing Strategy

**Mock tests (fast, no network):**
- Keep all existing mock tests
- Verify command generation
- Verify entry point validation

**Live tests (slower, network required):**
- Actually clone real repos
- Verify cleanup on failure
- Test dev mode
- Can be skipped if `--no-network` flag passed

**Separation:**
```makefile
# Makefile
check: check-mock check-live

check-mock:
	# Run all mock tests (fast)

check-live:
	# Run live integration tests (requires network)
	# Skip if SKIP_LIVE_TESTS=1
```

## Backwards Compatibility

**Error handling improvements:**
- ✅ Fully backwards compatible
- Only adds cleanup, doesn't change API

**Live tests:**
- ✅ Fully backwards compatible
- New tests don't affect existing functionality
- Can be skipped

**Tag parameter:**
- ✅ Fully backwards compatible if we keep `branch` working for tags
- ⚠️ Breaking if we remove `branch=<tag>` support
- Recommendation: Keep both, prefer `tag` in docs

## Open Questions

1. Should live tests be run in CI by default or only on-demand?
   - Pro default: Catches real issues early
   - Con default: Slower, can fail due to GitHub

2. Should we add `tag` parameter or keep `branch` for tags?
   - Keep simple: just improve docs that `branch` works for tags
   - Add clarity: separate `tag` parameter

3. What's the right test repository to use for live tests?
   - Our own repos (bowerbird-help, bowerbird-test) - we control them
   - Public stable repos - more realistic but we don't control them

4. Should we add retry logic for transient network failures?
   - Git already retries internally
   - Could add exponential backoff
   - Might be overengineering

## Alternatives Considered

### Alternative 1: Skip live tests entirely
**Rejected:** Mock tests don't catch real-world issues like network problems, authentication, git protocol changes

### Alternative 2: Use local git repos for "live" tests
**Rejected:** Doesn't test real network operations, git clone with URL, etc.

### Alternative 3: Mock network failures
**Rejected:** Can't fully simulate all failure modes without actually hitting network

## References

- Current mock tests: `test/bowerbird-deps/test-git-dependency-mock-*.mk`
- Git clone docs: https://git-scm.com/docs/git-clone
- GitHub Actions network access: https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions

## Success Criteria

- [ ] Clone failures clean up partial directories
- [ ] Live tests clone real repos successfully
- [ ] Live tests verify dev mode preserves .git
- [ ] Live tests verify entry point validation
- [ ] Live tests can be skipped (for offline development)
- [ ] CI runs both mock and live tests
- [ ] Documentation updated with live vs mock test info
- [ ] (Optional) Tag parameter implemented and documented
