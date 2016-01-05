EAPI=5

inherit git-r3

EGIT_REPO_URI="git://github.com/hardkernel/wiringPi.git"

DESCRIPTION="A 'wiring' like library for the odroid c1+"
HOMEPAGE="https://github.com/hardkernel/wiringPi"

SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

S=${WORKDIR}/${P}

MAKEDIRS="wiringPi devLib gpio"

src_prepare() {
	epatch "${FILESDIR}/wiringPi_Makefile.patch"
	epatch "${FILESDIR}/devLib_Makefile.patch"
}

src_compile() {
	for d in ${MAKEDIRS}; do
		cd "${WORKDIR}/${P}/${d}"	
		emake 
	done
}

src_install() {
	for d in ${MAKEDIRS}; do
		if [ ! "$d" = "gpio" ]; then 
			cd "${WORKDIR}/${P}/${d}"	
			emake DESTDIR="${D}/usr/" PREFIX="" install
		else
			cd "${WORKDIR}/${P}/${d}"
			exeinto /usr/bin
			exeopts -m4755
			doexe gpio

			doman gpio.1
		fi
	done
}
