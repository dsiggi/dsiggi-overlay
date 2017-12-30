# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

ETYPE=sources

inherit eutils git-r3 versionator

EGIT_REPO_URI=https://github.com/hardkernel/u-boot.git
EGIT_BRANCH="odroidc-v$(get_version_component_range 1-2)"
EGIT_CHECKOUT_DIR="$S"

DESCRIPTION="Odroid C1 U-Boot"
HOMEPAGE="https://github.com/hardkernel/u-boot"
SLOT=0
LICENSE="GPL-2"

KEYWORDS="~arm"

src_unpack() {
	git-r3_src_unpack
}

src_prepare() {
	cd ${WORKDIR}/${P}
	epatch "${FILESDIR}"/000_change_abi.patch
	epatch "${FILESDIR}"/fw_env_aml.c.patch
	epatch "${FILESDIR}"/config.mk.patch
	cp "${FILESDIR}"/compiler-gcc5.h include/linux/
}

src_compile() {
	export ARCH=arm
	
	# remove LDFLAGS as ld is called directly
	unset LDFLAGS

    emake \
        HOSTSTRIP=: \
        HOSTCC="$(tc-getCC)" \
        HOSTCFLAGS="${CFLAGS} ${CPPFLAGS}"' $(HOSTCPPFLAGS)' \
        odroidc_config
    emake
    emake tools-all
}

src_install() {
    cd build/tools
    dobin bmp_logo easylogo/easylogo env/fw_printenv gen_eth_addr img2srec inca-swap-bytes mkimage ncb ubsha1 uclpack

    cd ../..
    dodir /opt/hardkernel
    cp -R sd_fuse ${D}/opt/hardkernel || die "could not copy sd_fuse directory"
}

