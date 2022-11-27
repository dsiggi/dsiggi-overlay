# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=7

inherit cmake flag-o-matic udev

DESCRIPTION="Raspberry Pi userspace tools and libraries"
HOMEPAGE="https://github.com/raspberrypi/userland"

GIT_COMMIT="54fd97ae4066a10b6b02089bc769ceed328737e0"
SRC_URI="https://github.com/raspberrypi/userland/archive/${GIT_COMMIT}.tar.gz -> ${P}.tar.gz"
KEYWORDS="~arm"
S="${WORKDIR}/userland-${GIT_COMMIT}"

DEPEND=""
RDEPEND="acct-group/video
	!media-libs/raspberrypi-userland-bin"

LICENSE="BSD"
SLOT="0"

src_prepare() {
	cmake_src_prepare
	eapply_user
}

src_configure() {
	append-ldflags $(no-as-needed)

	cmake_src_configure
}

src_install() {
	cmake_src_install

	doenvd "${FILESDIR}"/04${PN}

	udev_dorules "${FILESDIR}"/92-local-vchiq-permissions.rules

	#insinto /opt/vc/lib/pkgconfig
	#doins "${FILESDIR}"/bcm_host.pc
	#doins "${FILESDIR}"/egl.pc
	#doins "${FILESDIR}"/glesv2.pc
}
