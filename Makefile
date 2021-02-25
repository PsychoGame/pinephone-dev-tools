VERSION = 0.1
PN = pinephone-dev-tools

PREFIX ?= /usr
INITDIR_SYSTEMD = /usr/lib/systemd/system
BINDIR = $(PREFIX)/bin

RM = rm
INSTALL = install -p
INSTALL_PROGRAM = $(INSTALL) -m755
INSTALL_DATA = $(INSTALL) -m644
INSTALL_DIR = $(INSTALL) -d
Q = @

install-bin: common/$(PN)
	$(Q)echo -e '\033[1;32mInstalling main script...\033[0m'
	$(INSTALL_DIR) "$(DESTDIR)$(BINDIR)"
	$(INSTALL_PROGRAM) common/pinephone-setup-usb-network "$(DESTDIR)$(BINDIR)/pinephone-setup-usb-network"
	$(INSTALL_PROGRAM) common/pinephone-usb-gadget "$(DESTDIR)$(BINDIR)/pinephone-usb-gadget"

install-systemd:
	$(Q)echo -e '\033[1;32mInstalling systemd files...\033[0m'
	$(INSTALL_DIR) "$(DESTDIR)$(INITDIR_SYSTEMD)"
	$(INSTALL_DATA) init/pinephone-setup-usb-network.service "$(DESTDIR)$(INITDIR_SYSTEMD)/pinephone-setup-usb-network.service"
	$(INSTALL_DATA) init/pinephone-usb-gadget.service "$(DESTDIR)$(INITDIR_SYSTEMD)/pinephone-usb-gadget.service"

install: install-bin install-systemd

uninstall-bin:
	$(RM) "$(DESTDIR)$(BINDIR)/pinephone-setup-usb-network"
	$(RM) "$(DESTDIR)$(BINDIR)/pinephone-usb-gadget"

uninstall-systemd:
	$(RM) "$(DESTDIR)$(INITDIR_SYSTEMD)/pinephone-setup-usb-network.service"
	$(RM) "$(DESTDIR)$(INITDIR_SYSTEMD)/pinephone-usb-gadget.service"

uninstall: uninstall-bin uninstall-systemd

clean:
	$(RM) -f common/$(PN)

.PHONY: install-bin install-systemd install uninstall-bin uninstall-systemd uninstall clean

