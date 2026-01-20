# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] - YYYY-MM-DD

### Added
- GitHub Actions CI workflow for automated testing on macOS and Ubuntu

### Changed
- **API Simplification**: `bowerbird::core::git-dependency` no longer requires outer `$(eval ...)` wrapper
  ```makefile
  # Old (verbose)
  $(eval $(call bowerbird::core::git-dependency, name=foo, ...))
  
  # New (clean)
  $(call bowerbird::core::git-dependency, name=foo, ...)
  ```

### Fixed
- GNU Make 4.3 compatibility in test recipes

## [1.0.0] - 2026-01-16

### Added
- Initial release of make-bowerbird-core, consolidating make-bowerbird-deps and make-bowerbird-libs
- Git-based loader (`bowerbird-loader.mk`) for simplified bootstrapping
- Unified core functionality: dependency management + kwargs parsing
- Kwargs-based API (`bowerbird::core::git-dependency`) available immediately after bootstrap
- Low-level positional API (`bowerbird::core::git-dependency-low-level`) for advanced use cases
- Command-line override system using dot notation (e.g., `make check dep.branch=feature`)
- Development mode flag (`--bowerbird-dev-mode`) to preserve git history
- Branch/revision distinction for explicit clone behavior
- Flexible spacing support in kwargs API
- Comprehensive test suite (migrated from deps and libs)
- Complete documentation with migration guide

### Changed
- Repository consolidation: deps + libs → core
- Bootstrap process: curl single loader → git clone full repo
- Entry point: `bowerbird-deps.mk` → `bowerbird.mk`
- Namespace: `bowerbird::libs::*` → `bowerbird::core::*` for main APIs, `bowerbird::lib::*` for utilities

### Deprecated
- `make-bowerbird-deps` - Use `make-bowerbird-core` instead
- `make-bowerbird-libs` - Use `make-bowerbird-core` instead

## Background

This repository consolidates the previously separate `make-bowerbird-deps` and `make-bowerbird-libs` repositories into a unified core package. This eliminates the chicken-and-egg problem where kwargs support required a separate dependency, simplifies maintenance, and provides a better user experience.

### Migration from make-bowerbird-deps + make-bowerbird-libs

Projects using the old repos should:
1. Replace bootstrap code to use `bowerbird-loader.mk`
2. Convert `git-dependency-low-level` calls to `git-dependency` kwargs API
3. Remove `bowerbird-libs` from dependencies (now included automatically)

See [README.md#migration-guide](README.md#migration-guide) for detailed instructions.
