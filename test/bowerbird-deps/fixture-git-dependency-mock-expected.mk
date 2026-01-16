# Shared test fixtures for git-dependency mock tests
#
# Provides template macro to generate expected git clone command output.
# This centralizes the expected format so changes only need to be made here.
#
# Naming convention:
#   - Test files: test-*.mk (discovered and run by test suite)
#   - Fixture files: fixture-*.mk (shared helpers, not run directly)

# Shell escape sequence for single quote within single-quoted string: '\''
__SQUOTE := '\''

# bowerbird::core::test-fixture::expected-git-dependency
#
#   Generates expected output for git clone commands.
#
#   Args:
#       $1: Mode - one of: branch, revision, dev-mode
#       $2: URL
#       $3: Path
#       $4: Branch or Revision (depending on mode)
#       $5: Entry file (relative path)
#
#   Examples:
#       $(call bowerbird::core::test-fixture::expected-git-dependency,branch,https://github.com/example/repo.git,/path/to/dep,main,bowerbird.mk)
#       $(call bowerbird::core::test-fixture::expected-git-dependency,revision,https://github.com/example/repo.git,/path/to/dep,abc123,lib.mk)
#       $(call bowerbird::core::test-fixture::expected-git-dependency,dev-mode,https://github.com/example/repo.git,/path/to/dep,main,bowerbird.mk)
#
define bowerbird::core::test-fixture::expected-git-dependency
$(if $(filter dev-mode,$1),echo "INFO: Cloning dependency in DEV mode: $2"
)git clone --config advice.detachedHead=false --config http.lowSpeedLimit=1000 --config http.lowSpeedTime=60 $(if $(filter dev-mode,$1),,--depth 1 )$(if $(filter revision,$1),--revision,--branch) $4 $2 $3 || (>&2 echo "ERROR: Failed to clone dependency $(__SQUOTE)$2$(__SQUOTE)" && exit 1)
test -n "$3"
test -d "$3/.git"
$(if $(filter dev-mode,$1),,rm -rfv -- "$3/.git"
)mkdir -p $(dir $3/$5)
touch $3/$5$(if $(filter dev-mode,$1),
:)
endef
