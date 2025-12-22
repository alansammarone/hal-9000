.PHONY: apply update check-stale

FLAKE_DIR := $(shell pwd)

check-stale:
	@days=$$(( ($$(date +%s) - $$(stat -f %m flake.lock)) / 86400 )); \
	echo "Lock file last updated $$days days ago"

apply: check-stale
	sudo darwin-rebuild switch --flake $(FLAKE_DIR)

update:
	nix flake update
	sudo darwin-rebuild switch --flake $(FLAKE_DIR)
