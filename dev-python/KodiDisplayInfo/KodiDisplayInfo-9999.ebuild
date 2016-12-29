# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PYTHON_COMPAT=( python2_7 )

inherit eutils python-r1 git-r3 linux-info

DESCRIPTION="A little Python/Pygame tool for small LCD TFT displays."
HOMEPAGE="https://github.com/bjoern-reichert/KodiDisplayInfo"

EGIT_REPO_URI="https://github.com/bjoern-reichert/${PN}"
KEYWORDS="arm"
S="${WORKDIR}/${P}"

LICENSE="GPL-3"
SLOT="0"
IUSE=""

DEPEND="
	${PYTHON_DEPS}
	dev-python/pygame[fbcon]
	dev-python/urllib3
	dev-python/JSON
"
RDEPEND="${DEPEND}"


CONFIG_CHECK="~FB_TFT"
ERROR_IP_MULTICAST="
KodiDisplayInfo needs CONFIG_FB_TFT build as module or in the kernel.
"


pkg_setup() {
	check_extra_config
}

src_prepare(){
	eapply_user

	#KodiDisplayInfo only running with python2, so change the first line
	sed -i "s/env python/env python2/g" "${S}"/displayinfo.py || die
}

src_install(){
	insinto /opt/${PN}
	doins -r ${S}/*
}

