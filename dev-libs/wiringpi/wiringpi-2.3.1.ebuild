# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

inherit eutils

DESCRIPTION="A 'wiring' like library for the Raspberry Pi"
HOMEPAGE="http://wiringpi.com/"
SRC_URI="https://git.drogon.net/?p=wiringPi;a=snapshot;h=78b5c323b74de782df58ee558c249e4e4fadd25f;sf=tgz -> ${P}.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~arm"
IUSE="+util"

RDEPEND=""
DEPEND="${RDEPEND}"

S="${WORKDIR}/wiringPi-78b5c32"

pkg_setup() {

	ewarn "If you use the FEATURES \"distcc\" and/or \"distcc-pump\""
	ewarn "please disable this FEATURES!"
	ewarn "The compiling of the libs wan't work with thes"
	
	#The gpio-util can only be build, when the libs are installed in the system!!!
	if use util; then
		if ! [ -f /usr/lib/libwiringPi.so.2.0 ]; then
			eerror "The gpio-util can only be build, when the libs are installed in the system!!!"
			eerror "So please emerge this package the first time without the \"util\"-useflag."
			die
		fi
	fi
}

src_prepare() {
	MAKEDIRS="wiringPi devLib"
	use util && MAKEDIRS="$MAKEDIRS gpio"

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
