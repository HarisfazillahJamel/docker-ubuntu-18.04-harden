#!/bin/bash
# Harisfazillah Jamel
# 21 July 2015
# Origin: https://github.com/HarisfazillahJamel/docker-ubuntu-14.04-harden

#
# Copyright (c) 2015-2020 Harisfazillah Jamel <linuxmalaysia@gmail.com>
#

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# This is my development scripts to harden server. Im using this docker to
# applied hardening scripts. Use this Dockerfile and scripts related at your own risk.
# Harisfazillah Jamel - Kuala Lumpur - Malaysia - 25 Jan 2015 - 25 Jan 2020

### part of this script from /usr/local/sbin/unminimize in docker image

set -e

if [ -f /etc/dpkg/dpkg.cfg.d/excludes ] || [ -f /etc/dpkg/dpkg.cfg.d/excludes.dpkg-tmp ]; then
    echo "Re-enabling installation of all documentation in dpkg..."
    if [ -f /etc/dpkg/dpkg.cfg.d/excludes ]; then
        mv /etc/dpkg/dpkg.cfg.d/excludes /etc/dpkg/dpkg.cfg.d/excludes.dpkg-tmp
    fi
    echo "Updating package list and upgrading packages..."
    apt-get update
    # apt-get upgrade asks for confirmation before upgrading packages to let the user stop here
    apt-get upgrade
    echo "Restoring system documentation..."
    echo "Reinstalling packages with files in /usr/share/man/ ..."
    # Reinstallation takes place in two steps because a single dpkg --verified
    # command generates very long parameter list for "xargs dpkg -S" and may go
    # over ARG_MAX. Since many packages have man pages the second download
    # handles a much smaller amount of packages.
    dpkg -S /usr/share/man/ |sed 's|, |\n|g;s|: [^:]*$||' | DEBIAN_FRONTEND=noninteractive xargs apt-get install --reinstall -y
    echo "Reinstalling packages with system documentation in /usr/share/doc/ .."
    # This step processes the packages which still have missing documentation
    dpkg --verify --verify-format rpm | awk '/..5......   \/usr\/share\/doc/ {print $2}' | sed 's|/[^/]*$||' | sort |uniq \
         | xargs dpkg -S | sed 's|, |\n|g;s|: [^:]*$||' | uniq | DEBIAN_FRONTEND=noninteractive xargs apt-get install --reinstall -y
    echo "Restoring system translations..."
    # This step processes the packages which still have missing translations
    dpkg --verify --verify-format rpm | awk '/..5......   \/usr\/share\/locale/ {print $2}' | sed 's|/[^/]*$||' | sort |uniq \
         | xargs dpkg -S | sed 's|, |\n|g;s|: [^:]*$||' | uniq | DEBIAN_FRONTEND=noninteractive xargs apt-get install --reinstall -y
    if dpkg --verify --verify-format rpm | awk '/..5......   \/usr\/share\/doc/ {exit 1}'; then
        echo "Documentation has been restored successfully."
        rm /etc/dpkg/dpkg.cfg.d/excludes.dpkg-tmp
    else
        echo "There are still files missing from /usr/share/doc/:"
        dpkg --verify --verify-format rpm | awk '/..5......   \/usr\/share\/doc/ {print " " $2}'
        echo "You may want to try running this script again or you can remove"
        echo "/etc/dpkg/dpkg.cfg.d/excludes.dpkg-tmp and restore the files manually."
    fi
fi

if ! dpkg-query --show --showformat='${db:Status-Status}\n' ubuntu-minimal 2> /dev/null | grep -q '^installed$'; then
    echo "Installing ubuntu-minimal package to provide the familiar Ubuntu minimal system..."
    DEBIAN_FRONTEND=noninteractive apt-get install -y ubuntu-minimal ubuntu-standard
fi

if dpkg-query --show --showformat='${db:Status-Status}\n' ubuntu-server 2> /dev/null | grep -q '^installed$' \
   && ! dpkg-query --show --showformat='${db:Status-Status}\n' landscape-common 2> /dev/null | grep -q '^installed$'; then
    echo "Installing ubuntu-server recommends..."
    DEBIAN_FRONTEND=noninteractive apt-get install -y landscape-common
fi



# need to restart rsyslog

service rsyslog stop
service rsyslog start

logger -it ujian "test the logger"

# Need to restart cron

service cron restart

# Need to restart fail2ban
# fail2ban.sock need to be deleted

service fail2ban stop
rm /var/run/fail2ban/fail2ban.sock
service fail2ban start

# Need to restart ssh and stop to initalize files

service ssh restart
service ssh stop

# docker run --privileged=true need to be used for iptables related.
# ufw remove for this version. 

#ufw allow 22/tcp
#ufw enable
#ufw status
#ufw default deny

# Crete SSH Key

ssh-keygen -t rsa -f ~/.ssh/id_rsa -q -N ""

exit 0
