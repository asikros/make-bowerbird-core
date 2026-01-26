# bowerbird::core::clean-paths
#
#	Shared cleaning recipe with safety checks.
#
#	Validates each path before deletion to prevent accidental removal of:
#		Root directory (/).
#		Home directory ($HOME).
#		Directories outside the project.
#		Empty paths.
#
#	Parameters:
#		$1 - Space-separated list of paths to clean
#
define bowerbird::core::clean-paths
	@echo "INFO: Cleaning directories"
	$(foreach path,$(1),\
		$(if $(wildcard $(path)),\
			test -n "$(path)" || (>&2 echo "ERROR: Empty path in cleanup" && exit 1); \
			test "$(path)" != "/" || (>&2 echo "ERROR: Cannot delete root" && exit 1); \
			test "$(path)" != "$(HOME)" || (>&2 echo "ERROR: Cannot delete HOME" && exit 1); \
			echo "$(path)" | grep -q "$(CURDIR)" || (>&2 echo "ERROR: Path must be under project dir: $(path)" && exit 1); \
			\rm -rfv -- "$(path)";)\
	)
	@echo "INFO: Cleaning complete"
	@echo
endef
