# --bowerbird-dev-mode
#
#	Optional flag for enabling development mode when cloning dependencies.
#
#	In development mode, git repositories are cloned with full history and
#	.git directories are preserved, allowing for local modifications and commits.
#
#	Include guard prevents "overriding commands for target" warnings when this
#	file is included multiple times.
#
#	Example:
#		make <target> -- --bowerbird-dev-mode
#		make check -- --bowerbird-dev-mode
#
ifndef __BOWERBIRD_DEPS_MK_INCLUDED
__BOWERBIRD_DEPS_MK_INCLUDED := 1

__BOWERBIRD_DEV_FLAG = --bowerbird-dev-mode
.PHONY: $(__BOWERBIRD_DEV_FLAG)
$(__BOWERBIRD_DEV_FLAG): ## Enables development mode (keeps .git history for dependencies)
	@:

# Set clone depth based on dev mode flag
ifneq ($(filter $(__BOWERBIRD_DEV_FLAG),$(MAKECMDGOALS)),)
    __BOWERBIRD_CLONE_DEPTH :=
    __BOWERBIRD_KEEP_GIT := 1
    export __BOWERBIRD_KEEP_GIT
else
    __BOWERBIRD_CLONE_DEPTH := --depth 1
    __BOWERBIRD_KEEP_GIT :=
endif

# Git clone timeout configuration (can be overridden for faster failure in tests)
BOWERBIRD_GIT_LOW_SPEED_LIMIT ?= 1000
BOWERBIRD_GIT_LOW_SPEED_TIME ?= 30
BOWERBIRD_GIT_TIMEOUT ?= 30


# bowerbird::git-dependency
#
#	HIGH-LEVEL: Installs a git dependency using keyword arguments.
#	Requires bowerbird-kwargs for kwargs parsing.
#
#	This is the user-facing API with friendly named parameters.
#	Delegates to bowerbird::core::git-dependency-low-level for the actual installation.
#
#	By default, performs a shallow clone and deletes the git history to prevent
#	accidental changes. When --bowerbird-dev-mode flag is used, performs a full
#	clone and keeps the .git directory for development purposes.
#
# 	Args:
#       name: Dependency name (for override variables).
#       path: Installation path.
#       url: Git repository URL.
#       branch: Branch or tag name (uses git clone --branch).
#               For version tags, use semantic versioning format (MAJOR.MINOR.PATCH)
#               without prefix, e.g., "1.0.0" not "v1.0.0".
#       entry: Entry point file (relative path).
#
#	Command-Line Overrides:
#		<name>.branch=<value>     Override branch/tag (tags: "1.0.0" format).
#		<name>.url=<value>        Override repository URL.
#		<name>.path=<value>       Override installation path.
#		<name>.entry=<value>      Override entry point.
#
#	Returns:
#		Creates a target for the dependency path and includes the entry point.
#		Errors if required parameters are missing or validation fails.
#
#	Example:
#		$(call bowerbird::git-dependency, \
#		    name=bowerbird-help, \
#		    path=$(WORKDIR_DEPS)/bowerbird-help, \
#		    url=https://github.com/ic-designer/make-bowerbird-help.git, \
#		    branch=main, \
#		    entry=bowerbird.mk)
#
#		make check bowerbird-help.branch=feature-xyz
#
define bowerbird::core::git-dependency
$(eval $(call bowerbird::core::kwargs-parse,$1,$2,$3,$4,$5))\
$(eval $(call bowerbird::core::kwargs-require,name,'name' parameter is required))\
$(eval $(call bowerbird::core::kwargs-require,path,'path' parameter is required))\
$(eval $(call bowerbird::core::kwargs-require,url,'url' parameter is required))\
$(eval $(call bowerbird::core::kwargs-require,entry,'entry' parameter is required))\
$(eval $(call bowerbird::core::kwargs-require,branch,'branch' parameter is required))\
$(eval $(if $(filter . ..,$(call bowerbird::core::kwargs,path)),$(error ERROR: 'path' cannot be '.' or '..': $(call bowerbird::core::kwargs,path))))\
$(eval __dep_name := $(call bowerbird::core::kwargs,name))\
$(eval $(__dep_name).path ?= $(call bowerbird::core::kwargs,path))\
$(eval $(__dep_name).url ?= $(call bowerbird::core::kwargs,url))\
$(eval $(__dep_name).branch ?=)\
$(if $(call bowerbird::core::kwargs-defined,branch),$(eval $(__dep_name).branch := $(call bowerbird::core::kwargs,branch)))\
$(eval $(__dep_name).entry ?= $(call bowerbird::core::kwargs,entry))\
$(eval $(call bowerbird::core::__git_dependency_impl,$($(__dep_name).path),$($(__dep_name).url),$($(__dep_name).branch),$($(__dep_name).entry)))
endef

# bowerbird::core::__git_dependency_impl
#
#	Internal implementation that clones a git dependency.
#	Do not call directly - use bowerbird::git-dependency instead.
#
#	Uses --branch flag for cloning. Parameters are already resolved with
#	command-line overrides applied.
#
#	Args:
#		$1: Installation path for the dependency.
#		$2: Git repository URL.
#		$3: Branch or tag name.
#		$4: Entry point file (relative path).
#
#	Returns:
#		Creates target for dependency path and entry point.
#		Performs shallow or full clone based on --bowerbird-dev-mode flag.
#		Removes .git directory unless in dev mode.
#		Includes the entry point makefile.
#
#	Raises:
#		Errors if git clone fails or entry point is not found.
#		Cleans up partially installed files on failure.
#
define bowerbird::core::__git_dependency_impl
$1/.:
	$$(if $(__BOWERBIRD_KEEP_GIT),@echo "INFO: Cloning dependency in DEV mode: $2")
	@(\
		GIT_TERMINAL_PROMPT=0 git clone \
				--config advice.detachedHead=false \
				--config http.lowSpeedLimit=$$(BOWERBIRD_GIT_LOW_SPEED_LIMIT) \
				--config http.lowSpeedTime=$$(BOWERBIRD_GIT_LOW_SPEED_TIME) \
				--config http.timeout=$$(BOWERBIRD_GIT_TIMEOUT) \
				$$(__BOWERBIRD_CLONE_DEPTH) \
				--branch $3 \
				$2 \
				$1 && \
		test -n "$1" && \
		test -d "$1/.git"\
	) || (\
		test -n "$1" && \
		\rm -rf "$1" && \
		>&2 echo "ERROR: Failed to setup dependency $2 [branch: $3]" && \
		exit 1\
	)
	$$(if $(__BOWERBIRD_KEEP_GIT),,@\rm -rfv -- "$1/.git")

$1/$4: | $1/.
	@test -d $$|
	@test -f $$@ || (\
		test -n "$1" && \
		\rm -rf "$1" && \
		>&2 echo "ERROR: Expected entry point not found: $$@" && \
		exit 1\
	)

include $1/$4
endef
endif