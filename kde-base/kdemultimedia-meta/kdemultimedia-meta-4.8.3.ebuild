# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/kde-base/kdemultimedia-meta/kdemultimedia-meta-4.8.1.ebuild,v 1.3 2012/04/19 04:22:07 maekke Exp $

EAPI=4
inherit kde4-meta-pkg

DESCRIPTION="kdemultimedia - merge this to pull in all kdemultimedia-derived packages"
KEYWORDS="amd64 ~ppc ~ppc64 ~x86 ~amd64-linux ~x86-linux"
IUSE="+dragonplayer ffmpeg +juk +mplayer"

RDEPEND="
	dragonplayer? ( $(add_kdebase_dep dragonplayer) )
	juk? ( $(add_kdebase_dep juk) )
	$(add_kdebase_dep kdemultimedia-kioslaves)
	$(add_kdebase_dep kmix)
	$(add_kdebase_dep kscd)
	$(add_kdebase_dep libkcddb)
	$(add_kdebase_dep libkcompactdisc)
	mplayer? ( $(add_kdebase_dep mplayerthumbs) )
	ffmpeg? ( $(add_kdebase_dep ffmpegthumbs) )
"