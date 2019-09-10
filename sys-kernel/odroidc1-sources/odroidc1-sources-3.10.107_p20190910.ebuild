# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

ETYPE=sources
K_DEFCONFIG="odroidc_defconfig"
K_SECURITY_UNSUPPORTED=1
EXTRAVERSION="-${PN}/-*"

inherit kernel-2 versionator

detect_version
detect_arch

COMMIT=bb2990d78682431ea704e389a0a24a95a57a1d0c
SRC_URI="https://github.com/hardkernel/linux/archive/${COMMIT}.tar.gz -> ${PF}.tar.gz"

DESCRIPTION="Linux source for Odroid devices"
HOMEPAGE="https://github.com/hardkernel/linux"

KEYWORDS="~arm"

RDEPEND="
	app-arch/lzop
	|| ( dev-embedded/u-boot-tools-odroidc1 dev-embedded/u-boot-tools )
	sys-devel/bc
	"
	
S=${WORKDIR}/linux-${COMMIT}

src_unpack()
{
	default
	unpack_set_extraversion
}

