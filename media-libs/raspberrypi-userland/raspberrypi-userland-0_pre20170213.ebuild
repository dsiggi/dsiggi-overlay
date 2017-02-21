# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit cmake-utils git-r3

DESCRIPTION="Raspberry Pi userspace tools and libraries"
HOMEPAGE="https://github.com/raspberrypi/userland"

EGIT_REPO_URI="https://github.com/raspberrypi/userland.git"
EGIT_COMMIT="40be8d4ea5eb08d77ba06617b0b49b0314c4b43c"
SRC_URI=""
KEYWORDS="~arm"
LICENSE="BSD"
SLOT="0"

src_prepare() {
	epatch "${FILESDIR}"/"${P}".patch

	# init script for Debian, not useful on Gentoo
	sed -i "/DESTINATION \/etc\/init.d/,+2d" interface/vmcs_host/linux/vcfiled/CMakeLists.txt || die
}

src_configure() {
	# toolchain file not needed, but build fails if it is not specified
	local mycmakeargs="-DCMAKE_TOOLCHAIN_FILE=/dev/null"
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	links="libEGL.so libEGL_static.a libGLESv2.so libGLESv2_static.a"

	dodir /usr/lib/opengl/${PN}
	for f in $links; do
		dosym ../../$f /usr/lib/opengl/${PN}/$f
	done

	touch "${ED}"/usr/lib/opengl/${PN}/.gles-only
}
