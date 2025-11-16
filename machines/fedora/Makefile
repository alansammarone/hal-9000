.POSIX:
.PHONY: start stop ssh logs status clean

VM_DIR := $(HOME)/Code/VMs/podman-builder
PID_FILE := $(VM_DIR)/qemu.pid
CONSOLE_LOG := $(VM_DIR)/vm-console.log
SSH_KEY := $(HOME)/.ssh/personal/qemu_fedora_builder
SSH_PORT := 2222
SSH_USER := root

start:
	@if [ -f "$(PID_FILE)" ] && kill -0 $$(cat "$(PID_FILE)") 2>/dev/null; then \
		echo "VM already running"; \
		exit 1; \
	fi
	@$(VM_DIR)/run-vm.sh

stop:
	@if [ ! -f "$(PID_FILE)" ]; then \
		echo "VM not running"; \
		exit 1; \
	fi
	@kill $$(cat "$(PID_FILE)") 2>/dev/null || true
	@rm -f "$(PID_FILE)"

ssh:
	@ssh -p $(SSH_PORT) -i "$(SSH_KEY)" $(SSH_USER)@127.0.0.1

logs:
	@if [ -f "$(CONSOLE_LOG)" ]; then \
		tail -f "$(CONSOLE_LOG)"; \
	else \
		echo "No logs yet"; \
	fi

status:
	@if [ -f "$(PID_FILE)" ] && kill -0 $$(cat "$(PID_FILE)") 2>/dev/null; then \
		echo "Running"; \
	else \
		echo "Stopped"; \
	fi

clean:
	@rm -rf "$(VM_DIR)"
