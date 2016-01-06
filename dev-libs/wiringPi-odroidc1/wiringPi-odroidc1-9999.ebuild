# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

inherit eutils git-r3


DESCRIPTION="A 'wiring' like library for the odroid c1+"
HOMEPAGE="http://wiringpi.com/"
EGIT_REPO_URI="git://github.com/hardkernel/wiringPi.git"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~arm"
IUSE="+util"

RDEPEND=""
DEPEND="${RDEPEND}"

S="${WORKDIR}/${P}"

src_prepare() {
	MAKEDIRS="wiringPi devLib"
	use util && MAKEDIRS="$MAKEDIRS gpio"

	cd ${S}
	epatch "${FILESDIR}/wiringPi_Makefile.patch"
	epatch "${FILESDIR}/devLib_Makefile.patch"
	use util && epatch "${FILESDIR}/gpio_Makefile.patch"
}

src_compile() {
	for d in ${MAKEDIRS}; do
		cd "${S}/${d}"
		einfo "Compiling $d"
		emake || die
	done
}

src_install() {
	for d in ${MAKEDIRS}; do
		cd "${S}/${d}"
		einfo "Installing $d"
		emake DESTDIR="${D}/usr/" PREFIX="" install || die
	done
}
