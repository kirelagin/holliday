# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/kde-base/kdemultimedia-meta/kdemultimedia-meta-4.12.5.ebuild,v 1.5 2014/05/08 07:32:01 ago Exp $

EAPI=5
inherit kde4-meta-pkg

DESCRIPTION="kdemultimedia - merge this to pull in all kdemultimedia-derived packages"
HOMEPAGE="
	http://www.kde.org/applications/multimedia/
	http://multimedia.kde.org/
"
KEYWORDS="amd64 ~arm ppc ppc64 x86 ~amd64-linux ~x86-linux"
IUSE="+dragon +juk ffmpeg +kscd mplayer"

RDEPEND="
	dragon? ( $(add_kdebase_dep dragon) )
	juk? ( $(add_kdebase_dep juk) )
	$(add_kdebase_dep audiocd-kio)
	$(add_kdebase_dep kmix)
	kscd? ( $(add_kdebase_dep kscd) )
	$(add_kdebase_dep libkcddb)
	$(add_kdebase_dep libkcompactdisc)
	mplayer? ( $(add_kdebase_dep mplayerthumbs) )
	ffmpeg? ( $(add_kdebase_dep ffmpegthumbs) )
"
