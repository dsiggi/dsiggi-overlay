# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="6"

inherit eutils

DESCRIPTION="A 'wiring' like library for the Raspberry Pi"
HOMEPAGE="http://wiringpi.com/"
SRC_URI="https://git.drogon.net/?p=wiringPi;a=snapshot;h=96344ff7125182989f98d3be8d111952a8f74e15;sf=tgz -> ${P}.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~arm"
IUSE="+util"

RDEPEND=""
DEPEND="${RDEPEND}"
PDEPEND="util? ( =dev-libs/wiringpi-util-${PV} )"

S="${WORKDIR}/wiringPi-96344ff"

src_prepare() {
	MAKEDIRS="wiringPi devLib"

	epatch "${FILESDIR}/wiringPi_Makefile-${PV}.patch"
	epatch "${FILESDIR}/devLib_Makefile-${PV}.patch"
	eapply_user
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
