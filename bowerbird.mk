_PATH := $(dir $(lastword $(MAKEFILE_LIST)))
include $(_PATH)/src/bowerbird-core/bowerbird-kwargs.mk
include $(_PATH)/src/bowerbird-core/bowerbird-deps.mk
include $(_PATH)/src/bowerbird-core/bowerbird-temp-kwargs.mk
include $(_PATH)/src/bowerbird-core/bowerbird-temp-deps.mk

