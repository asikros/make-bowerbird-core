_PATH := $(dir $(lastword $(MAKEFILE_LIST)))
include $(_PATH)/src/bowerbird-core/bowerbird-kwargs.mk
include $(_PATH)/src/bowerbird-core/bowerbird-clean.mk
include $(_PATH)/src/bowerbird-core/bowerbird-deps.mk

