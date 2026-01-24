# Bowerbird Keyword Arguments Library (Temp variant)
#
# Provides a general-purpose keyword argument parsing system for Make macros.
# This allows macros to accept named parameters in key=value format with flexible spacing.
#
ifndef __BOWERBIRD_TEMP_KWARGS_MK_INCLUDED
__BOWERBIRD_TEMP_KWARGS_MK_INCLUDED := 1
# Usage:
#   Call bowerbird::temp::kwargs-parse with arguments and use helper functions to access
#   and validate keyword arguments
#
# Example:
#   $(call bowerbird::temp::kwargs-parse,$1,$2,$3,$4,$5)
#   $(call bowerbird::temp::kwargs-require,name,'name' parameter is required)
#   $(call bowerbird::temp::kwargs-default,branch,main)
#   $(eval my_name := $(call bowerbird::temp::kwargs,name))

# Define comma and space variables (needed for substitution)
__BOWERBIRD_LIB_KWARGS_COMMA := ,
__BOWERBIRD_LIB_KWARGS_EMPTY :=
__BOWERBIRD_LIB_KWARGS_SPACE := $(__BOWERBIRD_LIB_KWARGS_EMPTY) $(__BOWERBIRD_LIB_KWARGS_EMPTY)

# Prefix for storing parsed keyword argument values
__BOWERBIRD_LIB_KWARGS_VALUE_PREFIX := __BOWERBIRD_LIB_KWARGS_VALUE

# Keyword arguments limit (we support one less than this value)
__BOWERBIRD_LIB_KWARGS_ARGS_LIMIT := 26

# Helper for building argument list (excludes position 1 and ARGS_LIMIT)
# Stored as immediate value to avoid re-executing shell command on each use
__BOWERBIRD_LIB_KWARGS_ARG_NUMS := $(filter-out $(__BOWERBIRD_LIB_KWARGS_ARGS_LIMIT),$(shell seq 1 $(__BOWERBIRD_LIB_KWARGS_ARGS_LIMIT)))

# bowerbird::temp::kwargs-parse
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
#		$(call bowerbird::temp::kwargs-parse,name=foo,path=bar,url=baz)
#		$(call bowerbird::temp::kwargs,name)  # Returns: foo
#
#	Example (recipe, target-specific scope via eval):
#		target:
#			$(eval $(call bowerbird::temp::kwargs-parse,name=foo,path=bar))
#			$(call bowerbird::temp::kwargs,name)  # Returns: foo
#
define bowerbird::temp::kwargs-parse
$(eval __BOWERBIRD_LIB_KWARGS_PREFIX := $(__BOWERBIRD_LIB_KWARGS_VALUE_PREFIX))
$(foreach v,$(filter $(__BOWERBIRD_LIB_KWARGS_VALUE_PREFIX).%,$(.VARIABLES)),$(eval $v :=))
$(eval __BOWERBIRD_LIB_KWARGS_ACTIVE :=)
$(eval __KWARG_COUNT := 0)
$(foreach n,$(__BOWERBIRD_LIB_KWARGS_ARG_NUMS),\
    $(if $(filter undefined,$(origin $n)),\
    ,\
        $(eval __KWARG_ARG := $(strip $($n)))\
        $(if $(__KWARG_ARG),\
            $(eval __KWARG_COUNT := $(words x $(__KWARG_COUNT)))\
            $(if $(findstring =,$(__KWARG_ARG)),\
                $(eval __KWARG_KEY := $(strip $(word 1,$(subst =, ,$(__KWARG_ARG)))))\
                $(eval __KWARG_VAL := $(strip $(word 2,$(subst =, ,$(__KWARG_ARG)))))\
                $(eval $(__BOWERBIRD_LIB_KWARGS_PREFIX).$(__KWARG_KEY) := $(__KWARG_VAL))\
                $(eval __BOWERBIRD_LIB_KWARGS_ACTIVE += $(__KWARG_KEY))\
            )\
        )\
    )\
)
endef


# bowerbird::temp::kwargs
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
#		$(call bowerbird::temp::kwargs,name)
#
define bowerbird::temp::kwargs
$($(__BOWERBIRD_LIB_KWARGS_VALUE_PREFIX).$1)
endef

# bowerbird::temp::kwargs-defined
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
#		$(if $(call bowerbird::temp::kwargs-defined,branch),...)
#
define bowerbird::temp::kwargs-defined
$(filter $1,$(__BOWERBIRD_LIB_KWARGS_ACTIVE))
endef

# bowerbird::temp::kwargs-default
#
#	Sets a default value for a keyword argument if not already defined.
#
#	Args:
#		$1: Key name
#		$2: Default value
#
#	Example:
#		$(call bowerbird::temp::kwargs-default,branch,main)
#
define bowerbird::temp::kwargs-default
$(if $(call bowerbird::temp::kwargs-defined,$1),,$(eval $(__BOWERBIRD_LIB_KWARGS_VALUE_PREFIX).$1 := $2))
endef

# bowerbird::temp::kwargs-require
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
#		$(call bowerbird::temp::kwargs-require,name)
#		$(call bowerbird::temp::kwargs-require,name,'name' parameter is required)
#
define bowerbird::temp::kwargs-require
$(if $(call bowerbird::temp::kwargs,$1),,$(error $(if $2,$2,ERROR: '$1' keyword is required)))
endef
endif
