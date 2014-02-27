# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

DESCRIPTION="Graphical wine frontend, that makes it easy to install and run Windows software on Linux systems"
HOMEPAGE="http://www.swine-tool.de"
SRC_URI="https://github.com/dswd/Swine/releases/download/${PV}/${PNV}-src.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="
	>=app-arch/cabextract-1.4
    >=app-emulation/wine-1.3.23
	>=dev-python/PyQt4-4.8.5
	>=dev-qt/qtcore-4.7.4:4
	>=dev-qt/qtgui-4.7.4:4
	>=media-gfx/icoutils-0.29.1
"
RDEPEND="${DEPEND}"
