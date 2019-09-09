EAPI=5

inherit git-r3 eutils flag-o-matic

EGIT_REPO_URI="https://github.com/mdrjr/c1_mali_ddx.git"

DESCRIPTION="Closed source drivers for Mali-400 Odroid-C1"
HOMEPAGE="https://github.com/mdrjr/c1_mali_ddx.git"

SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND="x11-base/xorg-server
	x11-libs/odroidc1-mali"
RDEPEND="${DEPEND}
	media-libs/mesa[gles1,gles2]"

src_configure() {
	append-flags -I/usr/lib/opengl/mali/include
	default
}

src_compile() {
	#epatch ${FILESDIR}/Makefile.patch
	emake
}

src_install() {
	insinto /usr/lib/xorg/modules/drivers
	doins ${WORKDIR}/${PF}/ src/.libs/mali_drv.so

	insinto /etc/X11
	newins ${WORKDIR}/${PF}/src/xorg.conf xorg.conf.mali 
}

src_postinst() {
	elog "A example xorg.conf has installed to: /etc/X11/xorg.conf.mali"
}
