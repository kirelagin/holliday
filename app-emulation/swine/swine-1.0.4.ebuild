# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

DESCRIPTION="Graphical wine frontend, that makes it easy to install and run Windows software on Linux systems"
HOMEPAGE="http://www.swine-tool.de"
SRC_URI="https://github.com/dswd/Swine/releases/download/${PV}/${P}-src.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="
	dev-python/PyQt4
	dev-qt/linguist:4
"
RDEPEND="${DEPEND}
	app-arch/cabextract
	app-emulation/wine
	dev-lang/python:*
	dev-qt/qtcore:4
	dev-qt/qtgui:4
	media-gfx/icoutils
"
