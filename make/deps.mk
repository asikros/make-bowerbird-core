# Error Checking
WORKDIR_DEPS ?= $(error ERROR: Undefined variable WORKDIR_DEPS)

# Dependencies
$(eval $(call bowerbird::temp::git-dependency, \
	name=bowerbird-help, \
	path=$(WORKDIR_DEPS)/bowerbird-help, \
	url=https://github.com/asikros/make-bowerbird-help.git, \
	branch=main, \
	entry=bowerbird.mk))

$(eval $(call bowerbird::temp::git-dependency, \
	name=bowerbird-test, \
	path=$(WORKDIR_DEPS)/bowerbird-test, \
	url=https://github.com/asikros/make-bowerbird-test.git, \
	branch=main, \
	entry=bowerbird.mk))
