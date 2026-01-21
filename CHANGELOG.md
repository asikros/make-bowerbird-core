# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial release of make-bowerbird-core, consolidating make-bowerbird-deps and make-bowerbird-libs
- Git-based loader (`bowerbird-loader.mk`) for simplified bootstrapping
- Unified core functionality: dependency management + kwargs parsing
- Kwargs-based API (`bowerbird::core::git-dependency`) available immediately after bootstrap
- Command-line override system using dot notation (e.g., `make check dep.branch=feature`)
- Development mode flag (`--bowerbird-dev-mode`) to preserve git history
- Flexible spacing support in kwargs API
- Comprehensive test suite (migrated from deps and libs)
- Complete documentation with migration guide
- GitHub Actions CI workflow for automated testing on macOS and Ubuntu
- Live integration tests for git-dependency with error handling and cleanup
- Path safety validation to prevent dangerous operations
- Configurable git clone timeout variables (`BOWERBIRD_GIT_LOW_SPEED_LIMIT`, `BOWERBIRD_GIT_LOW_SPEED_TIME`, `BOWERBIRD_GIT_TIMEOUT`)
- Live test for tag-based cloning using semantic versioning format (X.Y.Z)
- Test for loader bootstrap functionality (`test-loader-bootstrap`)

### Changed
- Repository consolidation: deps + libs → core
- Bootstrap process: curl single loader → git clone full repo
- Entry point: `bowerbird-deps.mk` → `bowerbird.mk`
- Namespace: `bowerbird::libs::*` → `bowerbird::core::*` for main APIs, `bowerbird::lib::*` for utilities

### Deprecated
- `make-bowerbird-deps` - Use `make-bowerbird-core` instead
- `make-bowerbird-libs` - Use `make-bowerbird-core` instead

### Removed
- **BREAKING**: `revision` parameter removed from `git-dependency` API
  - GitHub doesn't support cloning arbitrary commits via `--revision` flag
  - Use `branch` parameter for branches and tags only
  - For specific commits, clone a branch and checkout manually in a post-install step

### Fixed
- GNU Make 4.3 compatibility in test recipes
- Performance issue where parse-time git-dependency calls caused repeated clones
- Live failure test hanging by using `.invalid` TLD for instant DNS failure instead of non-existent GitHub URLs
- Loader parse-time include issue by merging clone and entry point validation into single target
- Loader download path standardized to `$(WORKDIR_DEPS)/bowerbird-loader.mk` (separate from `bowerbird-core.path`)
- Loader test to use `$(lastword $(MAKEFILE_LIST))` for path resolution, captured outside `ifdef` for correct evaluation
- Loader clone target made idempotent to handle GNU Make 4.3 re-execution when loader file is created


