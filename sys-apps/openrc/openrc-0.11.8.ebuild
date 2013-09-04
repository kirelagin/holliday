# Copyright 1999-2013 Gentoo Foundation
# Copyright 2013 Dimitry Ishenko <dimitry.ishenko@gmail.com>
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

DESCRIPTION="Fake OpenRC"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="
	sys-apps/systemd
"

RDEPEND="${DEPEND}"

S="${WORKDIR}"

src_install() {
	newinitd "${FILESDIR}/functions.sh" "functions.sh"
}
