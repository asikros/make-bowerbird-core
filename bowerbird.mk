_PATH := $(dir $(lastword $(MAKEFILE_LIST)))
include $(_PATH)/src/bowerbird-kwargs/bowerbird-kwargs.mk
include $(_PATH)/src/bowerbird-deps/bowerbird-deps.mk
