#!/bin/bash

#
# CIS Debian Hardening
#

#
# 2.3.3 Ensure talk client is not installed (Scored)
#

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=2
DESCRIPTION="Ensure talk client is not installed."

PACKAGES='talk inetutils-talk'

# This function will be called if the script status is on enabled / audit mode
audit () {
    for PACKAGE in $PACKAGES; do
        is_pkg_installed $PACKAGE
        if [ $FNRET = 0 ]; then
            crit "$PACKAGE is installed"
        else
            ok "$PACKAGE is absent"
        fi
    done
}

# This function will be called if the script status is on enabled mode
apply () {
    for PACKAGE in $PACKAGES; do
        is_pkg_installed $PACKAGE
        if [ $FNRET = 0 ]; then
            warn "$PACKAGE is installed, purging"
            apt-get purge $PACKAGE -y
            apt-get autoremove -y
        else
            ok "$PACKAGE is absent"
        fi
    done
}

# This function will check config parameters required
check_config() {
    :
}

# Source Root Dir Parameter
if [ -r /etc/default/cis-hardening ]; then
    . /etc/default/cis-hardening
fi
if [ -z "$CIS_ROOT_DIR" ]; then
     echo "There is no /etc/default/cis-hardening file nor cis-hardening directory in current environment."
     echo "Cannot source CIS_ROOT_DIR variable, aborting."
    exit 128
fi

# Main function, will call the proper functions given the configuration (audit, enabled, disabled)
if [ -r $CIS_ROOT_DIR/lib/main.sh ]; then
    . $CIS_ROOT_DIR/lib/main.sh
else
    echo "Cannot find main.sh, have you correctly defined your root directory? Current value is $CIS_ROOT_DIR in /etc/default/cis-hardening"
    exit 128
fi
