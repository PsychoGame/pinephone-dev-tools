VERSION = 0.91
PN = pinephone-dev-tools

PREFIX ?= /usr
INITDIR_SYSTEMD = /usr/lib/systemd/system
BINDIR = $(PREFIX)/bin

RM = rm
SED = sed
INSTALL = install -p
INSTALL_PROGRAM = $(INSTALL) -m755
INSTALL_DATA = $(INSTALL) -m644
INSTALL_DIR = $(INSTALL) -d
Q = @

common/$(PN): common/$(PN).in
	$(Q)echo -e '\033[1;32mSetting version\033[0m'
	$(Q)$(SED) 's/@VERSION@/'$(VERSION)'/' common/$(PN).in > common/$(PN)

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
	
enable-services:
	$(Q)echo -e '\033[1;32mEnabling USB-Gadget & USB Network services...\033[0m'
	# Try setting up USB networking directly; if it doesn't work (i.e. the NM
	# connection file isn't created), then we're probably creating an image and
	# need a systemd service running on first boot to setup USB networking
	"$(DESTDIR)$(BINDIR)/pinephone-setup-usb-network"
	if [ ! -e /etc/NetworkManager/system-connections/USB.nmconnection ]; then \
		systemctl enable pinephone-setup-usb-network; \
	fi
	systemctl enable pinephone-usb-gadget

install: install-bin install-systemd enable-services

disable-services:
	systemctl disable pinephone-usb-gadget
	systemctl disable pinephone-setup-usb-network
	$(RM) /etc/NetworkManager/system-connections/USB.nmconnection

uninstall-bin:
	$(RM) "$(DESTDIR)$(BINDIR)/pinephone-setup-usb-network"
	$(RM) "$(DESTDIR)$(BINDIR)/pinephone-usb-gadget"

uninstall-systemd:
	$(RM) "$(DESTDIR)$(INITDIR_SYSTEMD)/pinephone-setup-usb-network.service"
	$(RM) "$(DESTDIR)$(INITDIR_SYSTEMD)/pinephone-usb-gadget.service"

uninstall: disable-services uninstall-bin uninstall-systemd

clean:
	$(RM) -f common/$(PN)

.PHONY: install-bin install-systemd enable-services install disable-services uninstall-bin uninstall-systemd uninstall clean
