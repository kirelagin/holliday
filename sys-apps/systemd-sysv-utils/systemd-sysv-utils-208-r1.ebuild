# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=4

DESCRIPTION="Sysvinit compatibility symlinks and manpages"
HOMEPAGE="http://www.freedesktop.org/wiki/Software/systemd"
SRC_URI="http://www.freedesktop.org/software/systemd/systemd-${PVR}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="!sys-apps/sysvinit
	sys-apps/systemd"

S=${WORKDIR}/systemd-${PV}
APP="halt poweroff reboot runlevel shutdown telinit"

src_compile() {
	for app in ${APP}; do
		emake man/${app}.8
	done
	emake man/init.1
}

src_install() {
	cd man
	for app in ${APP}; do
		doman ${app}.8
		dosym ../usr/bin/systemctl /sbin/${app}
	done

	doman init.1
	dosym ../usr/lib/systemd/systemd /sbin/init
}
