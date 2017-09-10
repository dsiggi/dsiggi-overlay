# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="6"

inherit eutils

DESCRIPTION="A 'wiring' like library for the Raspberry Pi"
HOMEPAGE="http://wiringpi.com/"
SRC_URI="http://git.drogon.net/?p=wiringPi;a=snapshot;h=96344ff7125182989f98d3be8d111952a8f74e15;sf=tgz -> ${P}.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~arm"
IUSE=""

RDEPEND="=dev-libs/wiringpi-libs-${PV}"

S="${WORKDIR}/wiringPi-96344ff"

src_prepare() {
		epatch "${FILESDIR}/gpio_Makefile.patch"
		eapply_user
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
