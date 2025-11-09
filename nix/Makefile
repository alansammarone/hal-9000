.PHONY: apply update check-stale

check-stale:
	@days=$$(( ($$(date +%s) - $$(stat -f %m flake.lock)) / 86400 )); \
	echo "Lock file last updated $$days days ago"

apply: check-stale
	sudo darwin-rebuild switch --flake /Users/alan/Code/ClaudeAutomation/Shell/nix

update:
	nix flake update
	sudo darwin-rebuild switch --flake /Users/alan/Code/ClaudeAutomation/Shell/nix
