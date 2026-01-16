# Bowerbird Keyword Arguments Library
#
# Provides a general-purpose keyword argument parsing system for Make macros.
# This allows macros to accept named parameters in key=value format with flexible spacing.
#
ifndef __BOWERBIRD_KWARGS_MK_INCLUDED
__BOWERBIRD_KWARGS_MK_INCLUDED := 1
# Usage:
#   Call bowerbird::lib::kwargs-parse with arguments and use helper functions to access
#   and validate keyword arguments
#
# Example:
#   $(call bowerbird::lib::kwargs-parse,$1,$2,$3,$4,$5)
#   $(call bowerbird::lib::kwargs-require,name,'name' parameter is required)
#   $(call bowerbird::lib::kwargs-default,branch,main)
#   $(eval my_name := $(call bowerbird::lib::kwargs,name))

# Define comma and space variables (needed for substitution)
__BOWERBIRD_LIB_KWARGS_COMMA := ,
__BOWERBIRD_LIB_KWARGS_EMPTY :=
__BOWERBIRD_LIB_KWARGS_SPACE := $(__BOWERBIRD_LIB_KWARGS_EMPTY) $(__BOWERBIRD_LIB_KWARGS_EMPTY)

# Prefix for storing parsed keyword argument values
__BOWERBIRD_LIB_KWARGS_VALUE_PREFIX := __BOWERBIRD_LIB_KWARGS_VALUE

# Keyword arguments limit (we support one less than this value)
__BOWERBIRD_LIB_KWARGS_ARGS_LIMIT := 11

# Helper for building argument list (excludes position 1 and ARGS_LIMIT)
# Stored as immediate value to avoid re-executing shell command on each use
__BOWERBIRD_LIB_KWARGS_ARG_NUMS := $(filter-out $(__BOWERBIRD_LIB_KWARGS_ARGS_LIMIT),$(shell seq 1 $(__BOWERBIRD_LIB_KWARGS_ARGS_LIMIT)))

# bowerbird::lib::kwargs-parse
#
#	Parses keyword arguments with flexible spacing.
#
#	Args:
#		$1-$N: Keyword arguments in format key=value (flexible spacing supported).
#
#	Returns:
#		Sets $(__BOWERBIRD_LIB_KWARGS_VALUE_PREFIX).<key> variables for each parsed key=value pair.
#		Clears any existing variables to prevent leaking between calls.
#
#	Note:
#		This macro uses global scope, which is safe for sequential execution.
#		Values are cleared between calls to prevent leaking.
#		NOT parallel-safe: concurrent targets will clobber each other's kwargs values.
#
#	Example (parse-time, global scope):
#		$(call bowerbird::lib::kwargs-parse,name=foo,path=bar,url=baz)
#		$(call bowerbird::lib::kwargs,name)  # Returns: foo
#
#	Example (recipe, target-specific scope via eval):
#		target:
#			$(eval $(call bowerbird::lib::kwargs-parse,name=foo,path=bar))
#			$(call bowerbird::lib::kwargs,name)  # Returns: foo
#
define bowerbird::lib::kwargs-parse
# Use global scope - no automatic target detection to avoid undefined variable warnings
$(eval __BOWERBIRD_LIB_KWARGS_CURRENT_SCOPE :=)
$(eval __BOWERBIRD_LIB_KWARGS_PREFIX := $(__BOWERBIRD_LIB_KWARGS_VALUE_PREFIX))
# Clear all previous kwargs values AND active list to prevent leaking
$(foreach v,$(filter $(__BOWERBIRD_LIB_KWARGS_VALUE_PREFIX).%,$(.VARIABLES)),$(eval $v :=))
$(eval __BOWERBIRD_LIB_KWARGS_ACTIVE :=)
# Parse each argument directly (not as a word list) to handle spaces around =
$(eval __KWARG_COUNT := 0)
$(foreach n,$(__BOWERBIRD_LIB_KWARGS_ARG_NUMS),\
    $(if $(filter-out undefined,$(origin $n)),\
        $(eval __KWARG_COUNT := $(words x $(__KWARG_COUNT)))\
        $(eval __KWARG_ARG := $(strip $($n)))\
        $(if $(findstring =,$(__KWARG_ARG)),\
            $(eval __KWARG_KEY := $(strip $(word 1,$(subst =, ,$(__KWARG_ARG)))))\
            $(eval __KWARG_VAL := $(strip $(word 2,$(subst =, ,$(__KWARG_ARG)))))\
            $(eval $(__BOWERBIRD_LIB_KWARGS_PREFIX).$(__KWARG_KEY) := $(__KWARG_VAL))\
            $(eval __BOWERBIRD_LIB_KWARGS_ACTIVE += $(__KWARG_KEY))\
        )\
    )\
)
# Error if too many arguments (check if position ARGS_LIMIT is defined)
$(if $(filter-out undefined,$(origin $(__BOWERBIRD_LIB_KWARGS_ARGS_LIMIT))),\
    $(error ERROR: Keyword argument limit reached (max=$(words $(__BOWERBIRD_LIB_KWARGS_ARG_NUMS)) args)))
endef

# bowerbird::lib::kwargs
#
#	Retrieves a keyword argument value.
#
#	Args:
#		$1: Key name
#
#	Returns:
#		The value of $(__BOWERBIRD_LIB_KWARGS_VALUE_PREFIX).<key>, or empty if not set.
#
#	Example:
#		$(call bowerbird::lib::kwargs,name)
#
define bowerbird::lib::kwargs
$($(__BOWERBIRD_LIB_KWARGS_VALUE_PREFIX).$1)
endef

# bowerbird::lib::kwargs-defined
#
#	Tests if a keyword argument was explicitly set (even if set to empty).
#
#	Args:
#		$1: Key name
#
#	Returns:
#		Non-empty if the kwarg was explicitly passed, empty otherwise
#
#	Note:
#		Returns non-empty even if the kwarg value is empty, allowing distinction
#		between "not passed" and "passed with empty value".
#
#	Example:
#		$(if $(call bowerbird::lib::kwargs-defined,branch),...)
#
define bowerbird::lib::kwargs-defined
$(filter $1,$(__BOWERBIRD_LIB_KWARGS_ACTIVE))
endef

# bowerbird::lib::kwargs-default
#
#	Sets a default value for a keyword argument if not already defined.
#
#	Args:
#		$1: Key name
#		$2: Default value
#
#	Example:
#		$(call bowerbird::lib::kwargs-default,branch,main)
#
define bowerbird::lib::kwargs-default
$(if $(call bowerbird::lib::kwargs-defined,$1),,$(eval $(__BOWERBIRD_LIB_KWARGS_VALUE_PREFIX).$1 := $2))
endef

# bowerbird::lib::kwargs-require
#
#	Validates that a required keyword argument is present.
#
#	Args:
#		$1: Key name
#		$2: Error message (optional, defaults to "ERROR: '$1' keyword is required")
#
#	Raises:
#		Error if the keyword argument is not defined or empty.
#
#	Example:
#		$(call bowerbird::lib::kwargs-require,name)
#		$(call bowerbird::lib::kwargs-require,name,'name' parameter is required)
#
define bowerbird::lib::kwargs-require
$(if $(call bowerbird::lib::kwargs,$1),,$(error $(if $2,$2,ERROR: '$1' keyword is required)))
endef
endif
