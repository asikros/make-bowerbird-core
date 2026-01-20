# Bowerbird Core

Core functionality for the Bowerbird Make framework, providing dependency management and utility libraries in a unified package.

## Overview

**Bowerbird Core** consolidates dependency management (`make-bowerbird-deps`) and utility libraries (`make-bowerbird-libs`) into a single, cohesive repository. This eliminates the chicken-and-egg problem where kwargs support required a separate dependency, and provides a cleaner, more maintainable architecture.

### Why Consolidate?

- **No chicken-and-egg**: Dependency kwargs API available immediately
- **Single version**: Guaranteed compatibility between components
- **Simpler bootstrap**: One repository, one loader
- **Better UX**: Clean kwargs API from the start
- **Easier maintenance**: One repo, one release cycle

## Quick Start

### In your `make/deps.mk`:

```makefile
# Required Constants
WORKDIR_DEPS ?= $(error ERROR: Undefined variable WORKDIR_DEPS)

# Bootstrap Bowerbird Core
bowerbird-core.url ?= git@github.com:asikros/make-bowerbird-core.git
bowerbird-core.branch ?= main
bowerbird-core.path ?= $(WORKDIR_DEPS)/bowerbird-core
bowerbird-core.entry ?= bowerbird-loader.mk

$(bowerbird-core.path)/$(bowerbird-core.entry):
	@curl --silent --show-error --fail -L --create-dirs -o $@ \
	https://raw.githubusercontent.com/asikros/make-bowerbird-core/$(bowerbird-core.branch)/bowerbird-loader.mk

include $(bowerbird-core.path)/$(bowerbird-core.entry)

# Declare Dependencies using kwargs API
$(call bowerbird::core::git-dependency, \
	name=bowerbird-help, \
	url=https://github.com/asikros/make-bowerbird-help.git, \
	branch=main, \
	entry=bowerbird.mk)

$(call bowerbird::core::git-dependency, \
	name=bowerbird-test, \
	url=https://github.com/asikros/make-bowerbird-test.git, \
	branch=main, \
	entry=bowerbird.mk)
```

That's it! The loader downloads itself via curl, then clones the full repository, making all functionality immediately available.

## Features

### Dependency Management

Declare git dependencies with a clean kwargs API:

```makefile
# Clone from branch
$(call bowerbird::core::git-dependency, \
	name=my-tool, \
	url=https://github.com/org/my-tool.git, \
	branch=main, \
	entry=tool.mk)

# Clone from semantic version tag (MAJOR.MINOR.PATCH format, no 'v' prefix)
$(call bowerbird::core::git-dependency, \
	name=my-lib, \
	url=https://github.com/org/my-lib.git, \
	branch=1.2.3, \
	entry=lib.mk)
```

**Note:** The `branch` parameter accepts both branch names and tags. For version tags, use semantic versioning format (`MAJOR.MINOR.PATCH`) without a prefix, e.g., `1.0.0` not `v1.0.0`.

### Command-Line Overrides

Override any dependency parameter from the command line:

```bash
# Override branch
make check my-tool.branch=feature-xyz

# Override URL (test a fork)
make check my-tool.url=https://github.com/myuser/fork.git

# Multiple overrides (tags use semantic versioning: MAJOR.MINOR.PATCH)
make check my-tool.branch=2.0.0 my-other-tool.branch=main
```

### Development Mode

For local development of dependencies, preserve full git history:

```bash
make check -- --bowerbird-dev-mode
```

**Normal Mode (default):**
- Shallow clone (`--depth 1`)
- Removes `.git` directories
- Faster, smaller downloads
- Prevents accidental commits

**Development Mode:**
- Full clone with git history
- Preserves `.git` directories
- Enables local modifications
- Can commit and push changes

### Flexible Spacing

Kwargs work with any spacing style:

```makefile
# Readable (with spaces)
$(call bowerbird::core::git-dependency, name=foo, url=..., branch=main, entry=foo.mk)

# Compact (no spaces)
$(call bowerbird::core::git-dependency,name=foo,url=...,branch=main,entry=foo.mk)

# Mixed (whatever you prefer)
$(call bowerbird::core::git-dependency, name=foo,url=..., branch=main,entry=foo.mk)
```

## How It Works

### Bootstrap Process

1. **User curls loader**: Single file (`bowerbird-loader.mk`) downloaded via curl
2. **Loader validates**: Checks required variables are set
3. **Loader clones repo**: Full `make-bowerbird-core` repository cloned via git
4. **Loader includes entry**: Main `bowerbird.mk` file included
5. **All APIs available**: Dependency management and kwargs ready to use

### Architecture

```
make-bowerbird-core/
  bowerbird-loader.mk          # Bootstrap loader (curled by user)
  bowerbird.mk                 # Main entry point
  src/
    bowerbird-core/
      bowerbird-core.mk        # Core functionality
      bowerbird-deps.mk        # Dependency management
      bowerbird-kwargs.mk      # Kwargs parsing
```

The loader uses git clone instead of downloading individual files, ensuring atomic, consistent state and providing access to the full repository (tests, docs, examples).

## API Reference

### bowerbird::core::git-dependency

Declares a git dependency with kwargs API.

**Parameters (all required):**
- `name=<name>` - Dependency name (for override variables)
- `url=<url>` - Git repository URL
- `branch=<branch>` - Branch or tag name (tags should use semantic versioning: `MAJOR.MINOR.PATCH` without prefix)
- `entry=<file>` - Entry point file (relative path)

**Optional parameter:**
- `path=<path>` - Installation path (defaults to `$(WORKDIR_DEPS)/<name>`)

**Command-line overrides:**
- `<name>.url=<value>` - Override repository URL
- `<name>.branch=<value>` - Override branch/tag
- `<name>.path=<value>` - Override installation path
- `<name>.entry=<value>` - Override entry point

**Example:**
```makefile
$(call bowerbird::core::git-dependency, \
	name=bowerbird-help, \
	url=https://github.com/asikros/make-bowerbird-help.git, \
	branch=main, \
	entry=bowerbird.mk)
```


### bowerbird::lib::kwargs-parse

Internal kwargs parsing utility. Used by `git-dependency` macro.

## Configuration

### Override Variables

Set defaults or override from command line:

```makefile
# In your deps.mk
bowerbird-core.url ?= git@github.com:asikros/make-bowerbird-core.git
bowerbird-core.branch ?= main
bowerbird-core.path ?= $(WORKDIR_DEPS)/bowerbird-core
```

```bash
# From command line
make check bowerbird-core.branch=dev-branch
```

### Required Variables

Must be set in your Makefile:

- `WORKDIR_DEPS` - Base directory for dependencies

Typically set in `make/private.mk`:

```makefile
WORKDIR_DEPS = $(WORKDIR_ROOT)/deps
```

## Migration Guide

### From make-bowerbird-deps + make-bowerbird-libs

**Old approach:**

```makefile
# Bootstrap deps
BOWERBIRD_DEPS.MK := $(WORKDIR_DEPS)/bowerbird-deps/bowerbird_deps.mk
$(BOWERBIRD_DEPS.MK):
	@curl ... bowerbird-deps.mk
include $(BOWERBIRD_DEPS.MK)

# Bootstrap libs (required for kwargs)
$(call bowerbird::core::git-dependency-low-level,bowerbird-libs,...)

# Forced to use low-level API for everything else
$(call bowerbird::core::git-dependency-low-level,bowerbird-help,...)
```

**New approach:**

```makefile
# Bootstrap core (includes deps + libs)
bowerbird-core.url ?= git@github.com:asikros/make-bowerbird-core.git
bowerbird-core.branch ?= main
bowerbird-core.path ?= $(WORKDIR_DEPS)/bowerbird-core
bowerbird-core.entry ?= bowerbird-loader.mk

$(bowerbird-core.path)/$(bowerbird-core.entry):
	@curl -sSfL --create-dirs -o $@ \
	https://raw.githubusercontent.com/asikros/make-bowerbird-core/$(bowerbird-core.branch)/bowerbird-loader.mk

include $(bowerbird-core.path)/$(bowerbird-core.entry)

# Kwargs API available immediately
$(call bowerbird::core::git-dependency, name=bowerbird-help, url=..., branch=main, entry=bowerbird.mk)
```

**Benefits:**
- ~30% less code
- Kwargs API available from the start
- Cleaner, more maintainable
- Single version to manage

## Development

### Running Tests

```bash
make check
```

### Cleaning

```bash
make clean
```

### Dev Mode

```bash
make check -- --bowerbird-dev-mode
```

## Architecture

See [development/proposals](development/proposals/) for detailed design proposals:

- **[01-dependency-override.md](development/proposals/accepted/01-dependency-override.md)** - Kwargs API and override system design
- **[02-core-consolidation-and-loader.md](development/proposals/draft/02-core-consolidation-and-loader.md)** - Repository consolidation rationale and loader design

## Contributing

See [DEVELOPMENT.md](development/DEVELOPMENT.md) for development guidelines, testing workflow, and proposal process.

## License

MIT License - see [LICENSE](LICENSE) for details.
