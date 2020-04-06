# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python2_7 )
PYTHON_REQ_USE="libressl?,sqlite,ssl"
LIBDVDCSS_VERSION="1.4.2-Leia-Beta-5"
LIBDVDREAD_VERSION="6.0.0-Leia-Alpha-3"
LIBDVDNAV_VERSION="6.0.0-Leia-Alpha-3"
FFMPEG_VERSION="4.0.4"
CODENAME="Leia"
FFMPEG_KODI_VERSION="18.4"
MY_PV=${PV/_p/_r}
MY_PV=${MY_PV/_alpha/a}
MY_PV=${MY_PV/_beta/b}
MY_PV=${MY_PV/_rc/rc}
MY_P="${PN}-${MY_PV}"
KEYWORDS="~arch"
SRC_URI="https://github.com/xbmc/xbmc/archive/${MY_PV}-${CODENAME}.tar.gz -> ${MY_P}.tar.gz
	https://github.com/xbmc/libdvdcss/archive/${LIBDVDCSS_VERSION}.tar.gz -> libdvdcss-${LIBDVDCSS_VERSION}.tar.gz
	https://github.com/xbmc/libdvdread/archive/${LIBDVDREAD_VERSION}.tar.gz -> libdvdread-${LIBDVDREAD_VERSION}.tar.gz
	https://github.com/xbmc/libdvdnav/archive/${LIBDVDNAV_VERSION}.tar.gz -> libdvdnav-${LIBDVDNAV_VERSION}.tar.gz
	!system-ffmpeg? ( https://github.com/xbmc/FFmpeg/archive/${FFMPEG_VERSION}-${CODENAME}-${FFMPEG_KODI_VERSION}.tar.gz -> ffmpeg-${PN}-${FFMPEG_VERSION}-${CODENAME}-${FFMPEG_KODI_VERSION}.tar.gz )"
PATCHES=(
	"${FILESDIR}/${PN}-18.5-cassert.patch"
)
	
S=${WORKDIR}/xbmc-${MY_PV}-${CODENAME}

inherit autotools cmake desktop linux-info pax-utils python-single-r1 xdg

DESCRIPTION="A free and open source media-player and entertainment hub (Special ebuild to crosscompile for raspberrypi)"
HOMEPAGE="https://kodi.tv/ https://kodi.wiki/"

LICENSE="GPL-2+"
SLOT="0"
# use flag is called libusb so that it doesn't fool people in thinking that
# it is _required_ for USB support. Otherwise they'll disable udev and
# that's going to be worse.
IUSE="airplay alsa bluetooth bluray caps cec +css dbus dvd lcms libressl libusb lirc mariadb mysql nfs pulseaudio samba systemd +system-ffmpeg test +udev udisks upnp upower webserver +xslt zeroconf"
REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
	?? ( mariadb mysql )
	udev? ( !libusb )
	udisks? ( dbus )
	upower? ( dbus )
"
RESTRICT="!test? ( test )"

COMMON_DEPEND="${PYTHON_DEPS}
	airplay? (
		>=app-pda/libplist-2.0.0
		net-libs/shairplay
	)
	alsa? ( >=media-libs/alsa-lib-1.1.4.1 )
	bluetooth? ( net-wireless/bluez )
	bluray? ( >=media-libs/libbluray-1.0.2 )
	caps? ( sys-libs/libcap )
	dbus? ( sys-apps/dbus )
	dev-db/sqlite
	dev-libs/expat
	dev-libs/flatbuffers
	>=dev-libs/fribidi-0.19.7
	cec? ( >=dev-libs/libcec-4.0[raspberry-pi] )
	dev-libs/libpcre[cxx]
	>=dev-libs/libinput-1.10.5
	>=dev-libs/libxml2-2.9.4
	>=dev-libs/lzo-2.04
	dev-libs/tinyxml[stl]
	$(python_gen_cond_dep 'dev-python/pillow[${PYTHON_MULTI_USEDEP}]')
	$(python_gen_cond_dep 'dev-python/pycryptodome[${PYTHON_MULTI_USEDEP}]' 'python3*')
	>=dev-libs/libcdio-0.94
	>=dev-libs/libfmt-3.0.1
	dev-libs/libfstrcmp
	lcms? ( media-libs/lcms:2 )
	libusb? ( virtual/libusb:1 )
	virtual/ttf-fonts
	media-fonts/roboto
	>=media-libs/fontconfig-2.12.4
	>=media-libs/freetype-2.8
	>=media-libs/libass-0.13.4
	>=media-libs/taglib-1.11.1
	system-ffmpeg? (
		>=media-video/ffmpeg-${FFMPEG_VERSION}:=[encode,postproc,mmal]
		libressl? ( media-video/ffmpeg[libressl,-openssl] )
		!libressl? ( media-video/ffmpeg[-libressl,openssl] )
	)
	mysql? ( dev-db/mysql-connector-c:= )
	mariadb? ( dev-db/mariadb-connector-c:= )
	>=net-misc/curl-7.56.1[http2]
	nfs? ( >=net-fs/libnfs-2.0.0:= )
	!libressl? ( >=dev-libs/openssl-1.0.2l:0= )
	libressl? ( dev-libs/libressl:0= )
	pulseaudio? ( media-sound/pulseaudio )
	samba? ( >=net-fs/samba-3.4.6[smbclient(+)] )
	>=sys-libs/zlib-1.2.11
	udev? ( virtual/udev )
	virtual/libiconv
	webserver? ( >=net-libs/libmicrohttpd-0.9.55[messages(+)] )
	x11-libs/libdrm
	>=x11-libs/libxkbcommon-0.4.1
	xslt? ( dev-libs/libxslt )
	zeroconf? ( net-dns/avahi[dbus] )
	>=media-libs/raspberrypi-userland-0_pre20190115
"
RDEPEND="${COMMON_DEPEND}
	lirc? ( app-misc/lirc )
	!media-tv/xbmc
	udisks? ( sys-fs/udisks:2 )
	upower? ( sys-power/upower )
"
DEPEND="${COMMON_DEPEND}
	app-arch/bzip2
	app-arch/xz-utils
	dev-lang/swig
	dev-libs/crossguid
	dev-libs/rapidjson
	dev-util/cmake
	dev-util/gperf
	media-libs/giflib
	>=media-libs/libjpeg-turbo-1.5.1:=
	>=media-libs/libpng-1.6.26:0=
	test? ( dev-cpp/gtest )
	virtual/pkgconfig
	virtual/jre
"

CONFIG_CHECK="~IP_MULTICAST"
ERROR_IP_MULTICAST="
In some cases Kodi needs to access multicast addresses.
Please consider enabling IP_MULTICAST under Networking options.
"

pkg_setup() {
	check_extra_config
	python-single-r1_pkg_setup
}

src_unpack() {
	default
}

src_prepare() {
	cmake_src_prepare

	# avoid long delays when powerkit isn't running #348580
	sed -i \
		-e '/dbus_connection_send_with_reply_and_block/s:-1:3000:' \
		xbmc/platform/linux/*.cpp || die

	# Prepare tools and libs witch are configured with autotools during compile time
	AUTOTOOLS_DIRS=(
		"${S}"/lib/cpluff
		"${S}"/tools/depends/native/TexturePacker/src
		"${S}"/tools/depends/native/JsonSchemaBuilder/src
	)

	local d
	for d in "${AUTOTOOLS_DIRS[@]}" ; do
		pushd ${d} >/dev/null || die
		AT_NOELIBTOOLIZE="yes" AT_TOPLEVEL_EAUTORECONF="yes" eautoreconf
		popd >/dev/null || die
	done
	elibtoolize

	# Prevent autoreconf rerun
	sed -e 's/autoreconf -vif/echo "autoreconf already done in src_prepare()"/' -i \
		"${S}"/cmake/modules/FindCpluff.cmake \
		"${S}"/tools/depends/native/TexturePacker/src/autogen.sh \
		"${S}"/tools/depends/native/JsonSchemaBuilder/src/autogen.sh \
		|| die
}

src_configure() {
	local mycmakeargs=(
		-Ddocdir="${EPREFIX}/usr/share/doc/${PF}"
		-DENABLE_LDGOLD=OFF # https://bugs.gentoo.org/show_bug.cgi?id=606124
		-DENABLE_ALSA=$(usex alsa)
		-DENABLE_AIRTUNES=$(usex airplay)
		-DENABLE_AVAHI=$(usex zeroconf)
		-DENABLE_BLUETOOTH=$(usex bluetooth)
		-DENABLE_BLURAY=$(usex bluray)
		-DENABLE_CCACHE=OFF
		-DENABLE_CEC=$(usex cec)
		-DENABLE_DBUS=$(usex dbus)
		-DENABLE_DVDCSS=$(usex css)
		-DENABLE_INTERNAL_CROSSGUID=OFF
		-DENABLE_INTERNAL_FFMPEG="$(usex !system-ffmpeg)"
		-DENABLE_INTERNAL_FSTRCMP=OFF
		-DENABLE_CAP=$(usex caps)
		-DENABLE_LCMS2=$(usex lcms)
		-DENABLE_LIRCCLIENT=$(usex lirc)
		-DENABLE_MARIADBCLIENT=$(usex mariadb)
		-DENABLE_MICROHTTPD=$(usex webserver)
		-DENABLE_MYSQLCLIENT=$(usex mysql)
		-DENABLE_NFS=$(usex nfs)
		-DENABLE_OPTICAL=$(usex dvd)
		-DENABLE_PLIST=$(usex airplay)
		-DENABLE_PULSEAUDIO=$(usex pulseaudio)
		-DENABLE_SMBCLIENT=$(usex samba)
		-DENABLE_UDEV=$(usex udev)
		-DENABLE_UPNP=$(usex upnp)
		-DENABLE_XSLT=$(usex xslt)
		-DCORE_PLATFORM_NAME="rbpi"
		-DCMAKE_PREFIX_PATH=/opt/vc
		-Dlibdvdread_URL="${DISTDIR}/libdvdread-${LIBDVDREAD_VERSION}.tar.gz"
		-Dlibdvdnav_URL="${DISTDIR}/libdvdnav-${LIBDVDNAV_VERSION}.tar.gz"
		-Dlibdvdcss_URL="${DISTDIR}/libdvdcss-${LIBDVDCSS_VERSION}.tar.gz"
	)

	use libusb && mycmakeargs+=( -DENABLE_LIBUSB=$(usex libusb) )

	if use system-ffmpeg; then
		mycmakeargs+=( -DWITH_FFMPEG="yes" )
	else
		mycmakeargs+=( -DFFMPEG_URL="${DISTDIR}/ffmpeg-${PN}-${FFMPEG_VERSION}-${CODENAME}-${FFMPEG_KODI_VERSION}.tar.gz" )
	fi

	cmake_src_configure
}

src_compile() {
	cmake_src_compile all
}

src_test() {
	cmake_build check
}

src_install() {
	cmake_src_install

	pax-mark Em "${ED}"/usr/$(get_libdir)/${PN}/${PN}.bin

	rm "${ED}"/usr/share/kodi/addons/skin.estuary/fonts/Roboto-Thin.ttf || die
	dosym ../../../../fonts/roboto/Roboto-Thin.ttf \
		usr/share/kodi/addons/skin.estuary/fonts/Roboto-Thin.ttf

	python_domodule tools/EventClients/lib/python/xbmcclient.py
	python_newscript "tools/EventClients/Clients/KodiSend/kodi-send.py" kodi-send

	#Now install some stuff

        #Initd-script and config file
        dodir /etc/init.d
        newinitd ${FILESDIR}/kodi-initd kodi

        dodir /etc/conf.d
        newconfd ${FILESDIR}/kodi-confd kodi

        #polkit rules
        if use upower; then
                dodir /usr/share/kodi/polkit-configs
                insinto /usr/share/kodi/polkit-configs
                doins ${FILESDIR}/60-kodi.rules
        fi

        #udev related stuff
        dodir /usr/share/kodi/udev-configs
        insinto /usr/share/kodi/udev-configs
        doins ${FILESDIR}/99-input.rules
        doins ${FILESDIR}/10-vchiq-permissions.rules
}
