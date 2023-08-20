EAPI=7

inherit git-r3

EGIT_REPO_URI="https://github.com/mdrjr/c1_aml_libs.git"

DESCRIPTION="ODROID-C1 Amlogic Libraries"
HOMEPAGE="https://github.com/mdrjr/c1_aml_libs.git"

SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}
	media-libs/alsa-lib"

S=${WORKDIR}/${P}

src_prepare() {
	sed -i 's!install -m 0644 include -d!install -m 0755 include -d!' ${S}/amcodec/Makefile || die
	sed -i 's!install -m 0644 include/amports -d!install -m 0755 include/amports -d!' ${S}/amcodec/Makefile || die
	sed -i 's!install -m 0644 include/ppmgr -d!install -m 0755 include/ppmgr -d!' ${S}/amcodec/Makefile || die

	sed -i 's!install -m 0644 include/cutils -d!install -m 0755 include/cutils -d!' ${S}/amavutils/Makefile || die
}

src_install() {
	dodir "/usr/include" "/etc/ld.so.conf.d"

	emake DESTDIR="${D}" install

	insinto /lib/udev/rules.d
	doins "${FILESDIR}"/99-amlogic.rules
}
