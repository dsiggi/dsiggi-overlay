# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit cmake-utils

DESCRIPTION="Platform support library used by libCEC and binary add-ons for Kodi."
HOMEPAGE="https://github.com/Pulse-Eight/platform"
SRC_URI="https://github.com/Pulse-Eight/platform/archive/p8-platform-${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~arm"
IUSE=""

S="${WORKDIR}"/"platform-p8-platform-${PV}"

src_configure() {
	cd $S
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=1
	)
	cmake-utils_src_configure
}
