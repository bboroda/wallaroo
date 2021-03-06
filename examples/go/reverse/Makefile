# include root makefile
ifndef ROOT_MAKEFILE_MK
include ../../../Makefile
endif

# prevent rules from being evaluated/included multiple times
ifndef $(abspath $(lastword $(MAKEFILE_LIST)))_MK
$(abspath $(lastword $(MAKEFILE_LIST)))_MK := 1


# The following are control variables that determine what logic from `rules.mk` is enabled

# `true`/`false` to enable/disable the actual unit test command so it can be overridden (the targets are still created)
# applies to both the pony and elixir test targets
$(abspath $(lastword $(MAKEFILE_LIST)))_UNIT_TEST_COMMAND := false

# `true`/`false` to enable/disable generate pony related targets (build/test/clean) for pony sources in this directory
# otherwise targets only get created if there are pony sources (*.pony) in this directory.
$(abspath $(lastword $(MAKEFILE_LIST)))_PONY_TARGET := false

# `true`/`false` to enable/disable generate final file build target using ponyc command for the pony build target so
# it can be overridden manually
$(abspath $(lastword $(MAKEFILE_LIST)))_PONYC_TARGET := false

# `true`/`false` to enable/disable generate exs related targets (build/test/clean) for elixir sources in this directory
# otherwise targets only get created if there are elixir sources (*.exs) in this directory.
$(abspath $(lastword $(MAKEFILE_LIST)))_EXS_TARGET := false

# `true`/`false` to enable/disable generate docker related targets (build/push) for a Dockerfile in this directory
# otherwise targets only get created if there is a Dockerfile in this directory
$(abspath $(lastword $(MAKEFILE_LIST)))_DOCKER_TARGET := false

# `true`/`false` to enable/disable recursing into Makefiles of subdirectories if they exist
# (and by recursion every makefile in the tree that is referenced)
$(abspath $(lastword $(MAKEFILE_LIST)))_RECURSE_SUBMAKEFILES := false

REVERSE_GO_PATH := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
GO_PONY_LIB := $(wallaroo_path)/go_api/go
REVERSE_GOPATH := $(REVERSE_GO_PATH)/go:$(GO_PONY_LIB)

# standard rules generation makefile
include $(rules_mk_path)

build-examples-go-reverse: reverse_go_build
unit-tests-examples-go-reverse: build-examples-go-reverse
integration-tests-examples-go-reverse: build-examples-go-reverse
integration-tests-examples-go-reverse: reverse_go_test
clean-examples-go-reverse: reverse_go_clean

reverse_go_build: $(REVERSE_GO_PATH)/reverse

reverse_go_clean:
	$(QUIET)rm -rf $(REVERSE_GO_PATH)/lib $(REVERSE_GO_PATH)/.deps $(REVERSE_GO_PATH)/reverse $(REVERSE_GO_PATH)/reverse.d

-include $(REVERSE_GO_PATH)/reverse.d
$(REVERSE_GO_PATH)/reverse: $(REVERSE_GO_PATH)/lib/libwallaroo.a
	$(call PONYC,$(abspath $(REVERSE_GO_PATH:%/=%)))

$(REVERSE_GO_PATH)/lib/libwallaroo.a: $(REVERSE_GO_PATH)/go/src/reverse/reverse.go
	$(QUIET)export GOPATH=$(REVERSE_GOPATH) && go build -buildmode=c-archive -o $(REVERSE_GO_PATH)lib/libwallaroo.a reverse

reverse_go_test:
	cd $(REVERSE_GO_PATH) && \
	integration_test --csv-sender '1234,5678,1212,1111' \
	  --validation-cmp \
		--sink-mode 'newlines' \
		--expected-csv '4321,8765,2121,1111' \
		--log-level error \
		--command './reverse' \
		--sink-expect 4

# end of prevent rules from being evaluated/included multiple times
endif
