# bowerbird-loader.mk
#
#	Loader script for bootstrapping bowerbird-core.
#	This file is designed to be downloaded via curl and then clone the full repository.
#
#	The loader validates required variables set by the caller and uses them to clone
#	the complete bowerbird-core repository, making all functionality immediately available.
#
#	Required variables (must be set by caller):
#		bowerbird-core.url    - Git repository URL (e.g., https://github.com/asikros/make-bowerbird-core.git)
#		bowerbird-core.branch - Branch or tag to clone (e.g., main, 1.0.0)
#		bowerbird-core.path   - Local installation path (e.g., $(WORKDIR_DEPS)/bowerbird-core)
#		bowerbird-core.entry  - Entry point file to include (e.g., bowerbird.mk)
#
#	Example usage in your make/deps.mk:
#
#		WORKDIR_DEPS ?= $(error ERROR: Undefined variable WORKDIR_DEPS)
#
#		# Bootstrap bowerbird-core
#		bowerbird-core.path ?= $(WORKDIR_DEPS)/bowerbird-core
#		bowerbird-core.url ?= https://github.com/asikros/make-bowerbird-core.git
#		bowerbird-core.branch ?= main
#		bowerbird-core.entry ?= bowerbird.mk
#
#		$(WORKDIR_DEPS)/bowerbird-loader.mk:
#			@curl --silent --show-error --fail --create-dirs -o $@ -L \
#		https://raw.githubusercontent.com/asikros/make-bowerbird-core/$(bowerbird-core.branch)/bowerbird-loader.mk
#
#		include $(WORKDIR_DEPS)/bowerbird-loader.mk
#
#		# Now bowerbird::core::git-dependency is available!
#		$(call bowerbird::core::git-dependency, \
#			name=my-dep, \
#			url=https://github.com/org/my-dep.git, \
#			branch=main, \
#			entry=entry.mk)
#
#	Override examples:
#		make check bowerbird-core.branch=dev-branch
#		make test bowerbird-core.branch=v2.0.0
#		make build bowerbird-core.entry=alternative.mk
#

bowerbird-core.url ?= $(error ERROR: bowerbird-core.url must be set by caller)
bowerbird-core.branch ?= $(error ERROR: bowerbird-core.branch must be set by caller)
bowerbird-core.path ?= $(error ERROR: bowerbird-core.path must be set by caller)
bowerbird-core.entry ?= $(error ERROR: bowerbird-core.entry must be set by caller)

# Clone the repository
$(bowerbird-core.path)/.git:
	@echo "INFO: Cloning bowerbird-core from $(bowerbird-core.url) (branch: $(bowerbird-core.branch))"
	@git clone --config advice.detachedHead=false \
		--config http.lowSpeedLimit=1000 \
		--config http.lowSpeedTime=60 \
		--branch $(bowerbird-core.branch) \
		$(bowerbird-core.url) \
		$(bowerbird-core.path) || \
		(>&2 echo "ERROR: Failed to clone bowerbird-core from '$(bowerbird-core.url)'" && exit 1)

# Entry point depends on repository being cloned (order-only prerequisite)
$(bowerbird-core.path)/$(bowerbird-core.entry): | $(bowerbird-core.path)/.git
	@test -d $(bowerbird-core.path)/.git || (>&2 echo "ERROR: Repository .git directory not created" && exit 1)
	@test -f $@ || (>&2 echo "ERROR: Entry point $(bowerbird-core.entry) not found after cloning" && exit 1)

# Include the main bowerbird entry point from the cloned repository
include $(bowerbird-core.path)/$(bowerbird-core.entry)
