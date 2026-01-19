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

ifndef __BOWERBIRD_DEPS_FLAGS_DEFINED
__BOWERBIRD_DEPS_FLAGS_DEFINED := 1

__BOWERBIRD_DEV_FLAG = --bowerbird-dev-mode
.PHONY: $(__BOWERBIRD_DEV_FLAG)
$(__BOWERBIRD_DEV_FLAG): ## Enables development mode (keeps .git history for dependencies)
	@:

endif

# Set clone depth based on dev mode flag
ifneq ($(filter $(__BOWERBIRD_DEV_FLAG),$(MAKECMDGOALS)),)
    __BOWERBIRD_CLONE_DEPTH :=
    __BOWERBIRD_KEEP_GIT := 1
    export __BOWERBIRD_KEEP_GIT
else
    __BOWERBIRD_CLONE_DEPTH := --depth 1
    __BOWERBIRD_KEEP_GIT :=
endif


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
#       revision: Specific commit SHA (uses git clone --revision).
#       entry: Entry point file (relative path).
#
#	Note:
#		Specify either 'branch' OR 'revision', not both (mutually exclusive).
#
#	Command-Line Overrides:
#		<name>.branch=<value>     Override branch/tag.
#		<name>.revision=<value>   Override to specific SHA.
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
#		$(call bowerbird::git-dependency,name=test,path=/tmp/test,\
#		    url=https://github.com/example/repo.git,revision=abc123,entry=test.mk)
#
#		make check bowerbird-help.branch=feature-xyz
#
define bowerbird::core::git-dependency
$(call bowerbird::temp::kwargs-parse,$1,$2,$3,$4,$5)\
$(call bowerbird::temp::kwargs-require,name,'name' parameter is required)\
$(call bowerbird::temp::kwargs-require,path,'path' parameter is required)\
$(call bowerbird::temp::kwargs-require,url,'url' parameter is required)\
$(call bowerbird::temp::kwargs-require,entry,'entry' parameter is required)\
$(if $(and $(call bowerbird::temp::kwargs-defined,branch),$(call bowerbird::temp::kwargs-defined,revision)),$(error ERROR: Cannot specify both 'branch' and 'revision'))\
$(if $(or $(call bowerbird::temp::kwargs-defined,branch),$(call bowerbird::temp::kwargs-defined,revision)),,$(error ERROR: Must specify either 'branch' or 'revision'))\
$(eval __dep_name := $(call bowerbird::temp::kwargs,name))\
$(eval $(__dep_name).path ?= $(call bowerbird::temp::kwargs,path))\
$(eval $(__dep_name).url ?= $(call bowerbird::temp::kwargs,url))\
$(eval $(__dep_name).branch ?=)\
$(eval $(__dep_name).revision ?=)\
$(if $(call bowerbird::temp::kwargs-defined,branch),$(eval $(__dep_name).branch := $(call bowerbird::temp::kwargs,branch)))\
$(if $(call bowerbird::temp::kwargs-defined,revision),$(eval $(__dep_name).revision := $(call bowerbird::temp::kwargs,revision)))\
$(eval $(__dep_name).entry ?= $(call bowerbird::temp::kwargs,entry))\
$(eval $(call bowerbird::core::__git_dependency_impl,$($(__dep_name).path),$($(__dep_name).url),$($(__dep_name).branch),$($(__dep_name).revision),$($(__dep_name).entry)))
endef

# bowerbird::core::__git_dependency_impl
#
#	Internal implementation that clones a git dependency.
#	Do not call directly - use bowerbird::git-dependency instead.
#
#	Uses --branch flag if branch is specified, --revision flag if revision is specified.
#	Parameters are already resolved with command-line overrides applied.
#
#	Args:
#		$1: Installation path for the dependency.
#		$2: Git repository URL.
#		$3: Branch or tag name (empty if revision is used).
#		$4: Specific commit SHA (empty if branch is used).
#		$5: Entry point file (relative path).
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
	@git clone --config advice.detachedHead=false \
			--config http.lowSpeedLimit=1000 \
			--config http.lowSpeedTime=60 \
			$$(__BOWERBIRD_CLONE_DEPTH) \
			$$(if $3,--branch $3,--revision $4) \
			$2 \
			$1 || \
			(>&2 echo "ERROR: Failed to clone dependency '$2'" && exit 1)
	@test -n "$1"
	@test -d "$1/.git"
	$$(if $(__BOWERBIRD_KEEP_GIT),,@\rm -rfv -- "$1/.git")

$1/$5: | $1/.
	@test -d $$|
	@test -f $$@ || (\
		\rm -rf $1 && \
		>&2 echo "ERROR: Expected entry point not found: $$@" && \
		exit 1\
	)

include $1/$5
endef
endif