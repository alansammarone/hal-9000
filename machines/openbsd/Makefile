.POSIX:
.PHONY: start stop ssh logs status reset clean install-help post-install

VM_DIR := $(HOME)/Code/VMs/openbsd-qemu
PID_FILE := $(VM_DIR)/qemu.pid
CONSOLE_LOG := $(VM_DIR)/vm-console.log
SSH_KEY := $(HOME)/.ssh/personal/qemu_openbsd
SSH_PORT := 2223
SSH_USER := $(USER)
OPENBSD_VERSION := 7.8

start:
	@if [ -f "$(PID_FILE)" ] && kill -0 $$(cat "$(PID_FILE)") 2>/dev/null; then \
		echo "VM already running (PID $$(cat "$(PID_FILE)"))"; \
		exit 1; \
	fi
	@if [ ! -f "$(VM_DIR)/openbsd-$(OPENBSD_VERSION).qcow2" ]; then \
		echo "Error: Disk not found. Run ./setup.sh first, then complete installation."; \
		exit 1; \
	fi
	@echo "Starting OpenBSD VM..."
	@$(VM_DIR)/run-vm.sh
	@echo "VM started. Check status with 'make status'"

stop:
	@if [ ! -f "$(PID_FILE)" ]; then \
		echo "VM not running"; \
		exit 1; \
	fi
	@echo "Stopping VM (PID $$(cat "$(PID_FILE)"))..."
	@kill $$(cat "$(PID_FILE)") 2>/dev/null || true
	@rm -f "$(PID_FILE)"
	@echo "VM stopped"

ssh:
	@if [ ! -f "$(PID_FILE)" ] || ! kill -0 $$(cat "$(PID_FILE)") 2>/dev/null; then \
		echo "VM not running. Start with 'make start'"; \
		exit 1; \
	fi
	@ssh -p $(SSH_PORT) -i $(SSH_KEY) $(SSH_USER)@127.0.0.1

logs:
	@if [ ! -f "$(CONSOLE_LOG)" ]; then \
		echo "No console logs yet"; \
		exit 1; \
	fi
	@tail -f "$(CONSOLE_LOG)"

status:
	@if [ -f "$(PID_FILE)" ] && kill -0 $$(cat "$(PID_FILE)") 2>/dev/null; then \
		echo "Running (PID $$(cat "$(PID_FILE)"))"; \
	else \
		echo "Stopped"; \
	fi

reset:
	@echo "==> This will discard all changes and reset to pristine base image"
	@echo "==> Press Ctrl-C to cancel, Enter to continue"
	@read dummy
	@if [ -f "$(PID_FILE)" ] && kill -0 $$(cat "$(PID_FILE)") 2>/dev/null; then \
		echo "==> Stopping VM"; \
		kill $$(cat "$(PID_FILE)") 2>/dev/null || true; \
		rm -f "$(PID_FILE)"; \
	fi
	@echo "==> Removing overlay disk"
	@rm -f "$(VM_DIR)/openbsd-$(OPENBSD_VERSION).qcow2"
	@if [ ! -f "$(VM_DIR)/openbsd-$(OPENBSD_VERSION)-base.qcow2" ]; then \
		echo "Error: Base image not found. Complete initial installation first."; \
		exit 1; \
	fi
	@echo "==> Recreating overlay from base"
	@qemu-img create -f qcow2 -F qcow2 \
		-b "$(VM_DIR)/openbsd-$(OPENBSD_VERSION)-base.qcow2" \
		"$(VM_DIR)/openbsd-$(OPENBSD_VERSION).qcow2"
	@rm -f "$(CONSOLE_LOG)"
	@echo "==> Reset complete. Start VM with 'make start'"

clean:
	@echo "==> WARNING: This will delete ALL VM data including base image"
	@echo "==> Press Ctrl-C to cancel, Enter to continue"
	@read dummy
	@if [ -f "$(PID_FILE)" ] && kill -0 $$(cat "$(PID_FILE)") 2>/dev/null; then \
		echo "==> Stopping VM"; \
		kill $$(cat "$(PID_FILE)") 2>/dev/null || true; \
	fi
	@echo "==> Deleting $(VM_DIR)"
	@rm -rf "$(VM_DIR)"
	@echo "==> Clean complete. Run ./setup.sh to start fresh"

install-help:
	@echo "OpenBSD VM Initial Installation"
	@echo ""
	@echo "1. Run setup script:"
	@echo "   ./setup.sh"
	@echo ""
	@echo "2. Run installer (interactive, one-time):"
	@echo "   $(VM_DIR)/run-install.sh"
	@echo ""
	@echo "3. At OpenBSD installer:"
	@echo "   - Press 'I' to start autoinstall, then 'A' to proceed"
	@echo "   - Or answer questions manually (see install.conf for reference)"
	@echo "   - Wait for installation (~5 minutes)"
	@echo "   - When VM reboots, press Ctrl-C to exit"
	@echo ""
	@echo "4. First boot and SSH setup:"
	@echo "   make start"
	@echo "   make post-install"
	@echo ""
	@echo "5. Create base snapshot:"
	@echo "   cd $(VM_DIR)"
	@echo "   mv openbsd-$(OPENBSD_VERSION).qcow2 openbsd-$(OPENBSD_VERSION)-base.qcow2"
	@echo "   qemu-img create -f qcow2 -F qcow2 \\"
	@echo "     -b openbsd-$(OPENBSD_VERSION)-base.qcow2 \\"
	@echo "     openbsd-$(OPENBSD_VERSION).qcow2"
	@echo ""
	@echo "6. Daily use:"
	@echo "   make start  # Start VM"
	@echo "   make ssh    # SSH into VM"
	@echo "   make reset  # Reset to pristine state"
	@echo ""
	@echo "See README.md for detailed documentation"

post-install:
	@echo "==> Copying post-install script to VM"
	@scp -P $(SSH_PORT) -i $(SSH_KEY) \
		"$(VM_DIR)/post-install-config.sh" \
		"$(SSH_USER)@127.0.0.1:/tmp/"
	@echo ""
	@echo "==> Now SSH into the VM and run:"
	@echo "    doas sh /tmp/post-install-config.sh"
	@echo ""
	@echo "==> Then shut down the VM:"
	@echo "    doas halt -p"
	@echo ""
	@echo "==> After shutdown, create base snapshot (see 'make install-help')"
