# Copyright 1999-2022 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

ETYPE=sources

inherit eutils git-r3

EGIT_REPO_URI=https://github.com/hardkernel/u-boot.git
EGIT_BRANCH="odroidc-v$(ver_cut 1-2)"
EGIT_CHECKOUT_DIR="$S"
EGIT_COMMIT="b7b8dc21b64b9494618325c9b4d2fbae728aeed6"

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
	eapply -p0 "${FILESDIR}"/000_change_abi_unknown.patch
	eapply -p1 "${FILESDIR}"/002-sd_fusing-tweaks.patch
	eapply -p1 "${FILESDIR}"/003-compiler_gcc-do-not-redefine-__gnu_attributes.patch
	eapply -p1 "${FILESDIR}"/004-compiler-.h-sync-include-linux-compiler-.h-with-Linu.patch
	eapply -p1 "${FILESDIR}"/005-compiler_gcc-prevent-redefining-attributes.patch
	eapply -p1 "${FILESDIR}"/006-compiler-.h-sync-include-linux-compiler-.h-with-Linu.patch
	eapply -p1 "${FILESDIR}"/007-ARM-asm-io.h-use-static-inline.patch
	eapply -p1 "${FILESDIR}"/008-arm-board-use-__weak.patch
	eapply -p1 "${FILESDIR}"/009-add-vframe_provider_s-definition.patch
	eapply -p1 "${FILESDIR}"/010-common-main.c-make-show_boot_progress-__weak.patch
	eapply -p1 "${FILESDIR}"/011-wait_ms-fix.patch
	eapply -p0 "${FILESDIR}"/fw_env_aml.c.patch
	eapply_user
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

