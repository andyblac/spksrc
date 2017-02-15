SPK_NAME = plexpy
SPK_VERS = 1.4.8
SPK_REV = 2
SPK_ICON = src/plexpy.png
DSM_UI_DIR = app
BETA = 1

DEPENDS  = 
SPK_DEPENDS = "python>=2.7.6-8"

MAINTAINER = JonnyWong16
DESCRIPTION = A python based web application for monitoring, analytics and notifications for Plex Media Server.
ADMIN_PORT = 8181
RELOAD_UI = yes
DISPLAY_NAME = plexpy

HOMEPAGE   = https://github.com/drzoidberg33/plexpy
LICENSE    = GPL

INSTALLER_SCRIPT = src/installer.sh
SSS_SCRIPT       = src/dsm-control.sh
FWPORTS          = src/${SPK_NAME}.sc

INSTALL_PREFIX = /usr/local/$(SPK_NAME)
COPY_TARGET = nop

POST_STRIP_TARGET = plexpy_extra_install

# Pure Python package, make sure ARCH is not defined
override ARCH=

include ../../mk/spksrc.spk.mk

.PHONY: plexpy_extra_install
plexpy_extra_install: 
	install -m 755 -d $(STAGING_DIR)/var
	install -m 755 -d $(STAGING_DIR)/app
	install -m 755 -d $(STAGING_DIR)/app/images
	for size in 16 24 32 48 72; do \
		convert $(SPK_ICON) -thumbnail $${size}x$${size} \
		        $(STAGING_DIR)/app/images/$(SPK_NAME)-$${size}.png ; \
	done

