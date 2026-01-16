# Developer Guide

Quick reference for contributing to make-bowerbird-core.

## Code Standards

Follow the project's coding conventions:
- **[Make Style Guide](https://github.com/asikros/make-bowerbird-docs/blob/main/docs/make-styleguide.md)** - Naming conventions, documentation patterns, and formatting rules for Makefiles

## Development Workflows

- **[Testing Workflow](https://github.com/asikros/make-bowerbird-docs/blob/main/docs/testing-workflow.md)** - How to test changes, debug failures, and ensure test coverage

## Key Principles

1. **Test everything**: Run `make clean && make check` after any modifications
2. **Root cause failures**: Fix underlying issues, don't hack tests or code to pass
3. **Simple, direct tests**: Test failures should clearly indicate what's broken
4. **Add missing coverage**: If a bug wasn't caught, add a test for it
5. **Consolidation mindset**: Core includes both dependency management and utilities - design for cohesion

## Quick Start

```bash
# Run all tests
make check

# Clean build artifacts and run tests
make clean && make check

# Run with dev mode to keep .git directories
make check -- --bowerbird-dev-mode
```

## Directory Structure

```
development/
├── DEVELOPMENT.md           # This file
└── proposals/               # Design proposals
    ├── INDEX.md            # Proposals index
    ├── draft/              # Proposals under active development
    ├── accepted/           # Accepted and implemented proposals
    └── rejected/           # Rejected proposals (with rationale)

src/
├── bowerbird-deps/         # Dependency management
│   └── bowerbird-deps.mk   # Git dependency implementation
└── bowerbird-kwargs/       # Kwargs parsing utilities
    └── bowerbird-kwargs.mk # Keyword argument parser

test/
├── bowerbird-deps/         # Dependency tests (27 tests)
│   ├── test-*.mk           # Individual test files
│   └── fixture-*.mk        # Test fixtures
├── bowerbird-kwargs/       # Kwargs tests (2 tests)
│   └── test-*.mk           # Kwargs test files
└── makefile/               # Makefile utilities tests (1 test)
    └── test-*.mk           # Makefile test files

bowerbird-loader.mk         # Bootstrap loader (at root)
bowerbird.mk                # Main entry point (includes kwargs + deps)
```

## Testing

### Test Structure

Tests use the bowerbird-test framework:
- Mock shell for recipe testing (no actual git operations)
- Fixtures for shared expected output
- Isolated test directories for parallel execution

### Adding Tests

1. Create test file: `test/bowerbird-core/test-feature-name.mk`
2. Follow existing test patterns (see fixture files)
3. Run `make check` to verify
4. Add to test suite in `make/private.mk` if needed

## Proposals

For full details on proposal workflow, see the **[Proposal Lifecycle](https://github.com/asikros/make-bowerbird-docs/blob/main/docs/proposals.md)** guide in make-bowerbird-docs.

### Creating a Proposal

1. Create markdown file in `development/proposals/draft/`
2. Use format from proposals guide (status, summary, problem, solution, etc.)
3. Number by creation date (01 = oldest)
4. Update `development/proposals/INDEX.md`

### Moving Proposals

- **Draft → Accepted**: After implementation, testing, and documentation complete
- **Draft → Rejected**: If not proceeding, document rationale

## Architecture Notes

### Consolidation

`make-bowerbird-core` consolidates:
- **Dependency management** (from make-bowerbird-deps)
- **Kwargs parsing** (from make-bowerbird-libs)

This eliminates the chicken-and-egg problem and provides a unified version.

### Loader Design

The `bowerbird-loader.mk` file:
- Lives at repository root
- Downloaded via curl by users
- Clones full repository via git
- Includes main `bowerbird.mk` entry point

This provides atomic, consistent bootstrap with access to all repo contents.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes with tests
4. Run `make check`
5. Submit pull request

For significant changes, create a proposal first (see proposals/ directory).
