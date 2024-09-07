#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root."
  exit 1
fi

FLYWAY_URL="https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/${VERSION}/flyway-commandline-${VERSION}-linux-x64.tar.gz"
FLYWAY_SHA1_URL="${FLYWAY_URL}.sha1"

. /etc/os-release

check_packages() {
    if [ ${INSTALL_CMD} = "apt-get" ]; then
        if ! dpkg -s "$@" > /dev/null 2>&1; then
            pkg_mgr_update
            ${INSTALL_CMD} -y install --no-install-recommends "$@"
        fi
    elif [ ${INSTALL_CMD} = "apk" ]; then
        ${INSTALL_CMD} add \
            --no-cache \
            "$@"
    elif [ ${INSTALL_CMD} = "dnf" ] || [ ${INSTALL_CMD} = "yum" ]; then
        _num_pkgs=$(echo "$@" | tr ' ' \\012 | wc -l)
        _num_installed=$(${INSTALL_CMD} -C list installed "$@" | sed '1,/^Installed/d' | wc -l)
        if [ ${_num_pkgs} != ${_num_installed} ]; then
            pkg_mgr_update
            ${INSTALL_CMD} -y install "$@"
        fi
    elif [ ${INSTALL_CMD} = "microdnf" ]; then
        ${INSTALL_CMD} -y install \
            --refresh \
            --best \
            --nodocs \
            --noplugins \
            --setopt=install_weak_deps=0 \
            "$@"
    else
        echo "Linux distro ${ID} not supported."
        exit 1
    fi
}

echo '- Activating feature flyway-cli...'

check_packages curl tar

EXPECTED_SHA1=`curl -sSL "$FLYWAY_SHA1_URL"`
if [ -z "$EXPECTED_SHA1" ]; then
  echo "[x] Could not download flyway tarball's sha1. Install failed.";
  exit 1;
fi

echo '- Downloading '"$FLYWAY_URL"'...'

curl -sSLf -# -o flyway.tar.gz "$FLYWAY_URL"
if [ ! -f "flyway.tar.gz" ]; then
  echo "[x] Could not download flyway tarball. Install failed.";
  exit 1;
fi

ACTUAL_SHA1=`sha1sum flyway.tar.gz | awk '{print $1;}'`
if [ "$EXPECTED_SHA1" -ne "$ACTUAL_SHA1" ]; then
  echo "$EXPECTED_SHA1 !== $ACTUAL_SHA1"
  echo "[x] Checksums don't match. Install failed.";
  exit 1;
fi

echo '- Extracting and installing flyway...';

mkdir "/usr/share/flyway"
mkdir flyway
tar xvf flyway.tar.gz -C flyway
rm flyway.tar.gz
mv flyway/*/* /usr/share/flyway
rmdir flyway/*
rmdir flyway

install -m0755 "/usr/share/flyway/flyway" "/usr/bin/flyway"

