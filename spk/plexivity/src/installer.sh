#!/bin/sh

# Package
PACKAGE="plexivity"
DNAME="plexivity"

# Others
INSTALL_DIR="/usr/local/${PACKAGE}"
SSS="/var/packages/${PACKAGE}/scripts/start-stop-status"
PYTHON_DIR="/usr/local/python"
GIT_DIR="/usr/local/git"
PATH="${INSTALL_DIR}/bin:${INSTALL_DIR}/env/bin:${PYTHON_DIR}/bin:${GIT_DIR}/bin:${PATH}"
USER="plexivity"
GROUP="nobody"
CFG_FILE="/var/services/homes/${USER}/config.ini"
VIRTUALENV="${PYTHON_DIR}/bin/virtualenv"
TMP_DIR="${SYNOPKG_PKGDEST}/../../@tmp"

SERVICETOOL="/usr/syno/bin/servicetool"
FWPORTS="/var/packages/${PACKAGE}/scripts/${PACKAGE}.sc"

preinst ()
{
    # Create user
    synouser --get ${USER}
    if [ $? -ne 0 ]; then
        # create user with random password
        synouser --add ${USER} `uuidgen | cut -c-8` 'Plexivity User' '' '' ''
    fi

    exit 0
}

postinst ()
{
    # Link
    ln -s ${SYNOPKG_PKGDEST} ${INSTALL_DIR}

    # Create a Python virtualenv
    ${VIRTUALENV} ${INSTALL_DIR}/env > /dev/null

    # Install the wheels
    ${INSTALL_DIR}/env/bin/pip install --no-deps --no-index -U --force-reinstall -f ${INSTALL_DIR}/share/wheelhouse ${INSTALL_DIR}/share/wheelhouse/*.whl > /dev/null 2>&1

    # Install config
    if [ ! -f "${CFG_FILE}" ]; then
        cp ${INSTALL_DIR}/var/config.ini ${CFG_FILE}
    fi

    # Correct the files ownership
    chown -R ${USER}:root ${SYNOPKG_PKGDEST}

    # Add firewall config
    ${SERVICETOOL} --install-configure-file --package ${FWPORTS} >> /dev/null

    exit 0
}

preuninst ()
{
    # Stop the package
    ${SSS} stop > /dev/null

    # Remove the user (if not upgrading)
    if [ "${SYNOPKG_PKG_STATUS}" == "UNINSTALL" ]; then
        delgroup ${USER} ${GROUP}
        synouser --del ${USER}
    fi

    exit 0
}

postuninst ()
{
    # Remove link
    rm -f ${INSTALL_DIR}

    # Remove firewall config
    if [ "${SYNOPKG_PKG_STATUS}" == "UNINSTALL" ]; then
        ${SERVICETOOL} --remove-configure-file --package ${PACKAGE}.sc >> /dev/null
    fi

    exit 0
}

preupgrade ()
{
    # Stop the package
    ${SSS} stop > /dev/null

    # Save some stuff
    rm -fr ${TMP_DIR}/${PACKAGE}
    mkdir -p ${TMP_DIR}/${PACKAGE}
    mv ${INSTALL_DIR}/var ${TMP_DIR}/${PACKAGE}/

    exit 0
}

postupgrade ()
{
    # Restore some stuff
    rm -fr ${INSTALL_DIR}/var
    mv ${TMP_DIR}/${PACKAGE}/var ${INSTALL_DIR}/
    rm -fr ${TMP_DIR}/${PACKAGE}

    exit 0
}
