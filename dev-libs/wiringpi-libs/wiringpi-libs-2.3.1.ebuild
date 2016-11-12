# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

inherit eutils

DESCRIPTION="A 'wiring' like library for the Raspberry Pi"
HOMEPAGE="http://wiringpi.com/"
SRC_URI="http://git.drogon.net/?p=wiringPi;a=snapshot;h=78b5c323b74de782df58ee558c249e4e4fadd25f;sf=tgz -> ${P}.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~arm"
IUSE="+util"

RDEPEND=""
DEPEND="${RDEPEND}"
PDEPEND="util? ( dev-libs/wiringpi-util )"

S="${WORKDIR}/wiringPi-78b5c32"

pkg_setup() {

	ewarn "If you use the FEATURES \"distcc\" and/or \"distcc-pump\""
	ewarn "please disable this FEATURES!"
	ewarn "The compiling of the libs wan't work with thes"
}

src_prepare() {
	MAKEDIRS="wiringPi devLib"
	
	epatch "${FILESDIR}/wiringPi_Makefile.patch"
	epatch "${FILESDIR}/devLib_Makefile.patch"
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
