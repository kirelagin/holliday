# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=4
inherit kde4-meta-pkg

DESCRIPTION="kdemultimedia - merge this to pull in all kdemultimedia-derived packages"
KEYWORDS="amd64 x86 ~amd64-linux ~x86-linux"
IUSE="+dragon +juk ffmpeg +kscd +mplayer"

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
