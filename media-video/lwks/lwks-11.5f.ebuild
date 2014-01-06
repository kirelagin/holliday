# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit versionator unpacker gnome2-utils

VERSION=($(get_all_version_components))
MY_PNV="${PN}-${VERSION[0]}.${VERSION[2]}.$(echo ${VERSION[3]} | tr 'a-z' 'A-Z')"

DESCRIPTION="LightWorks video editor software"
HOMEPAGE="http://www.lwks.com/"
SRC_URI="${MY_PNV}-amd64.deb"

RESTRICT="fetch mirror"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="
	media-libs/tiff
	gnome-extra/libgsf
"

S="${WORKDIR}/"

src_install() {
	cp -R . ${D}

	rm ${D}/usr/bin/lightworks
	newbin ${FILESDIR}/lightworks lightworks

	fperms a+rw /usr/share/lightworks/{Preferences,"Audio Mixes"}

	rm ${D}/control.tar.gz ${D}/data.tar.gz ${D}/debian-binary

	echo $((`cat /dev/urandom|od -N1 -An -i` % 2500)) >> ${D}/usr/share/lightworks/machine.num
}
