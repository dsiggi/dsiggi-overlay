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
IUSE=""

RDEPEND="dev-libs/wiringpi-libs"
DEPEND="${RDEPEND}"

S="${WORKDIR}/wiringPi-78b5c32"

pkg_setup() {

	ewarn "If you use the FEATURES \"distcc\" and/or \"distcc-pump\""
	ewarn "please disable this FEATURES!"
	ewarn "The compiling of the libs wan't work with thes"
}

src_prepare() {
		epatch "${FILESDIR}/gpio_Makefile.patch"
}

src_compile() {
	cd "${S}/gpio"
	einfo "Compiling gpio"
	emake || die
}

src_install() {
	cd "${S}/gpio"
	einfo "Installing gpio"
	emake DESTDIR="${D}/usr/" PREFIX="" install || die
}
