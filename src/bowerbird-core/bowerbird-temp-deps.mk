# Bowerbird Temporary Dependencies (Temp variant)
#
# Temporary implementation for git dependency management using bowerbird::temp:: prefix.
# This is a copy of the core git-dependency functions for testing/development purposes.

ifndef __BOWERBIRD_TEMP_DEPS_MK_INCLUDED
__BOWERBIRD_TEMP_DEPS_MK_INCLUDED := 1

# bowerbird::temp::git-dependency
#
#	HIGH-LEVEL: Installs a git dependency using keyword arguments.
#	Requires bowerbird-kwargs for kwargs parsing.
#
#	This is the user-facing API with friendly named parameters.
#	Delegates to bowerbird::temp::__git_dependency_impl for the actual installation.
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
#		$(call bowerbird::temp::git-dependency, \
#		    name=bowerbird-help, \
#		    path=$(WORKDIR_DEPS)/bowerbird-help, \
#		    url=https://github.com/ic-designer/make-bowerbird-help.git, \
#		    branch=main, \
#		    entry=bowerbird.mk)
#
#		$(call bowerbird::temp::git-dependency,name=test,path=/tmp/test,\
#		    url=https://github.com/example/repo.git,revision=abc123,entry=test.mk)
#
#		make check bowerbird-help.branch=feature-xyz
#
define bowerbird::temp::git-dependency
$(eval $(call bowerbird::temp::kwargs-parse,$1,$2,$3,$4,$5))\
$(eval $(call bowerbird::temp::kwargs-require,name,'name' parameter is required))\
$(eval $(call bowerbird::temp::kwargs-require,path,'path' parameter is required))\
$(eval $(call bowerbird::temp::kwargs-require,url,'url' parameter is required))\
$(eval $(call bowerbird::temp::kwargs-require,entry,'entry' parameter is required))\
$(eval $(if $(and $(call bowerbird::temp::kwargs-defined,branch),$(call bowerbird::temp::kwargs-defined,revision)),$(error ERROR: Cannot specify both 'branch' and 'revision')))\
$(eval $(if $(or $(call bowerbird::temp::kwargs-defined,branch),$(call bowerbird::temp::kwargs-defined,revision)),,$(error ERROR: Must specify either 'branch' or 'revision')))\
$(eval $(if $(filter . ..,$(call bowerbird::temp::kwargs,path)),$(error ERROR: 'path' cannot be '.' or '..': $(call bowerbird::temp::kwargs,path))))\
$(eval __dep_name := $(call bowerbird::temp::kwargs,name))\
$(eval $(__dep_name).path ?= $(call bowerbird::temp::kwargs,path))\
$(eval $(__dep_name).url ?= $(call bowerbird::temp::kwargs,url))\
$(eval $(__dep_name).branch ?=)\
$(eval $(__dep_name).revision ?=)\
$(if $(call bowerbird::temp::kwargs-defined,branch),$(eval $(__dep_name).branch := $(call bowerbird::temp::kwargs,branch)))\
$(if $(call bowerbird::temp::kwargs-defined,revision),$(eval $(__dep_name).revision := $(call bowerbird::temp::kwargs,revision)))\
$(eval $(__dep_name).entry ?= $(call bowerbird::temp::kwargs,entry))\
$(eval $(call bowerbird::temp::__git_dependency_impl,$($(__dep_name).path),$($(__dep_name).url),$($(__dep_name).branch),$($(__dep_name).revision),$($(__dep_name).entry)))
endef

# bowerbird::temp::__git_dependency_impl
#
#	Internal implementation that clones a git dependency.
#	Do not call directly - use bowerbird::temp::git-dependency instead.
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
define bowerbird::temp::__git_dependency_impl
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
		test -n "$1" && \
		\rm -rf "$1" && \
		>&2 echo "ERROR: Expected entry point not found: $$@" && \
		exit 1\
	)

include $1/$5
endef
endif
