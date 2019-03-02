# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

: ${CMAKE_MAKEFILE_GENERATOR:=ninja}
PYTHON_COMPAT=( python2_7 )
PYTHON_REQ_USE="libressl?,sqlite,ssl"
LIBDVDCSS_VERSION="1.4.2-Leia-Beta-5"
LIBDVDREAD_VERSION="6.0.0-Leia-Alpha-3"
LIBDVDNAV_VERSION="6.0.0-Leia-Alpha-3"
CROSSGUID_VERSION="8f399e8bd4"
FFMPEG_VERSION="4.0.3"
FFMPEG_KODI_VERSION="RC5"
CODENAME="Leia"

SRC_URI="https://github.com/xbmc/libdvdcss/archive/${LIBDVDCSS_VERSION}.tar.gz -> libdvdcss-${LIBDVDCSS_VERSION}.tar.gz
        https://github.com/xbmc/libdvdread/archive/${LIBDVDREAD_VERSION}.tar.gz -> libdvdread-${LIBDVDREAD_VERSION}.tar.gz
        https://github.com/xbmc/libdvdnav/archive/${LIBDVDNAV_VERSION}.tar.gz -> libdvdnav-${LIBDVDNAV_VERSION}.tar.gz
        https://github.com/xbmc/crossguid/archive/${CROSSGUID_VERSION}.tar.gz -> crossguid-${CROSSGUID_VERSION}.tar.gz
        https://github.com/xbmc/xbmc/archive/${PV}-${CODENAME}.tar.gz -> ${P}.tar.gz
        !system-ffmpeg? ( https://github.com/xbmc/FFmpeg/archive/${FFMPEG_VERSION}-${CODENAME}-${FFMPEG_KODI_VERSION}.tar.gz -> ffmpeg-${PN}-${FFMPEG_VERSION}-${CODENAME}-${FFMPEG_KODI_VERSION}.tar.gz )"

DESCRIPTION="Kodi is a free and open source media-player and entertainment hub (Special ebuild for raspberrypi/odroidc1"
HOMEPAGE="http://kodi.tv/ http://kodi.wiki/"
LICENSE="GPL-2"
KEYWORDS="~arm"

inherit eutils linux-info python-single-r1 autotools cmake-utils flag-o-matic pax-utils versionator

S=${WORKDIR}/xbmc-${PV}-${CODENAME}
SLOT="0"

# use flag is called libusb so that it doesn't fool people in thinking that
# it is _required_ for USB support. Otherwise they'll disable udev and
# that's going to be worse.
IUSE="airplay alsa bluetooth bluray caps cec css dbus debug dvd joystick -libressl libusb lirc mariadb midi mysql nfs nonfree odroidc1 profile pulseaudio raspberrypi +samba sftp spectrum ssl +system-ffmpeg test texturepacker udisks upnp upower +udev waveform webserver zeroconf"

REQUIRED_USE="
        ${PYTHON_REQUIRED_USE}
        ?? ( mariadb mysql )
        udev? ( !libusb )
        udisks? ( dbus )
        upower? ( dbus )
        ^^ ( raspberrypi odroidc1 )
"

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
        cec? ( >=dev-libs/libcec-4.0 )
        dev-libs/libpcre[cxx]
        >=dev-libs/libinput-1.10.5
        >=dev-libs/libxml2-2.9.4
        >=dev-libs/lzo-2.04
        dev-libs/tinyxml[stl]
        dev-python/pillow[${PYTHON_USEDEP}]
        $(python_gen_cond_dep 'dev-python/pycryptodome[${PYTHON_USEDEP}]' 'python3*')
        >=dev-libs/libcdio-0.94
        dev-libs/libfmt
        dev-libs/libfstrcmp
        libusb? ( virtual/libusb:1 )
        virtual/ttf-fonts
        media-fonts/roboto
        >=media-libs/fontconfig-2.12.4
        >=media-libs/freetype-2.8
        >=media-libs/libass-0.13.4
        >=media-libs/taglib-1.11.1
        system-ffmpeg? (
                >=media-video/ffmpeg-${FFMPEG_VERSION}:=[encode,postproc]
                libressl? ( media-video/ffmpeg[libressl,-openssl] )
                !libressl? ( media-video/ffmpeg[-libressl,openssl] )
        )
        mysql? ( dev-db/mysql-connector-c:= )
        mariadb? ( dev-db/mariadv-conncector-c:= )
        >=net-misc/curl-7.56.1
        nfs? ( >=net-fs/libnfs-2.0.0:= )
        !libressl? ( >=dev-libs/openssl-1.0.2l:0= )
        libressl? ( dev-libs/libressl:0= )
        pulseaudio? ( media-sound/pulseaudio )
        samba? ( >=net-fs/samba-3.4.6[smbclient(+)] )
        >=sys-libs/zlib-1.2.11
        udev? ( virtual/udev )
        virtual/libiconv
        webserver? ( >=net-libs/libmicrohttpd-0.9.55[messages] )
        x11-libs/libdrm
        x11-libs/libxkbcommon
        zeroconf? ( net-dns/avahi[dbus] )
        raspberrypi? ( system-ffmpeg? ( >=media-video/ffmpeg-${FFMPEG_VERSION}:=[mmal] )
                       >=media-libs/raspberrypi-userland-0_pre20190115 )
        odroidc1? ( media-libs/aml-odroidc1 media-libs/odroidc1-mali-fb )
        "
RDEPEND="${COMMON_DEPEND}
        lirc? ( app-misc/lirc )
        udisks? ( sys-fs/udisks:2 )
        upower? ( sys-power/upower )"
DEPEND="${COMMON_DEPEND}
        app-arch/bzip2
        app-arch/xz-utils
        dev-lang/swig
        dev-libs/rapidjson
        dev-util/cmake
        dev-util/gperf
        media-libs/giflib
        >=media-libs/libjpeg-turbo-1.5.1:=
        >=media-libs/libpng-1.6.26:0=
        test? ( dev-cpp/gtest )
        virtual/pkgconfig
        virtual/jre"

PDEPEND="
        waveform? ( media-plugins/kodi-visualization-waveform )
        spectrum? ( media-plugins/kodi-visualization-spectrum )
        "

CONFIG_CHECK="~IP_MULTICAST"
ERROR_IP_MULTICAST="
In some cases Kodi needs to access multicast addresses.
Please consider enabling IP_MULTICAST under Networking options.
"

pkg_setup() {
        use raspberrypi && filter-flags -mcpu=cortex-a7
        use odroidc1 && filter-flags -mcpu=cortex-a5

        check_extra_config
        python-single-r1_pkg_setup
}

src_unpack() {
        default
}

src_prepare() {
        cmake-utils_src_prepare

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
                "${S}"/tools/depends/native/JsonSchemaBuilder/src/autogen.sh
}

src_configure() {
        local CMAKE_BUILD_TYPE=$(usex debug Debug RelWithDebInfo)

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
                -DENABLE_INTERNAL_CROSSGUID=ON
                -DENABLE_CAP=$(usex caps)
                -DENABLE_LIRC=$(usex lirc)
                -DENABLE_MICROHTTPD=$(usex webserver)
                -DENABLE_MYSQLCLIENT=$(usex mysql)
                -DENABLE_MARIADBCLIENT=$(usex mariadb)
                -DENABLE_NFS=$(usex nfs)
                -DENABLE_NONFREE=$(usex nonfree)
                -DENABLE_OPENSSL=$(usex ssl)
                -DENABLE_OPTICAL=$(usex dvd)
                -DENABLE_PLIST=$(usex airplay)
                -DENABLE_PULSEAUDIO=$(usex pulseaudio)
                -DENABLE_SMBCLIENT=$(usex samba)
                -DENABLE_SSH=$(usex sftp)
                -DENABLE_UDEV=$(usex udev)
                -DENABLE_UPNP=$(usex upnp)
                -DENABLE_OPENGL=OFF
                -DENABLE_VDPAU=OFF
                -DENABLE_VAAPI=OFF
                -DENABLE_X11=OFF
                -DENABLE_XSLT=OFF
                -Dlibdvdread_URL="${DISTDIR}/libdvdread-${LIBDVDREAD_VERSION}.tar.gz"
                -Dlibdvdnav_URL="${DISTDIR}/libdvdnav-${LIBDVDNAV_VERSION}.tar.gz"
                -Dlibdvdcss_URL="${DISTDIR}/libdvdcss-${LIBDVDCSS_VERSION}.tar.gz"
)               -DCROSSGUID_URL="${DISTDIR}/crossguid-${CROSSGUID_VERSION}.tar.gz"

        use libusb && mycmakeargs+=( -DENABLE_LIBUSB=$(usex libusb) )

        use raspberrypi && mycmakeargs+=( -DCORE_PLATFORM_NAME=rbpi -DWITH_CPU=cortex-a7 )
        use odroidc1 && mycmakeargs+=( -DCORE_PLATFORM_NAME=aml -DENABLE_AML=ON )

        if use raspberrypi; then
                if [ -d /opt/vc ]; then
                        mycmakeargs+=( -DCMAKE_PREFIX_PATH=/opt/vc )
                else
                        mycmakeargs+=( -DCMAKE_PREFIX_PATH=/usr/include/interface )
                fi
        fi

        if use system-ffmpeg; then
                mycmakeargs+=( -DENABLE_INTERNAL_FFMPEG=OFF)
        else
                mycmakeargs+=( -DENABLE_INTERNAL_FFMPEG=ON -DFFMPEG_URL="${DISTDIR}/ffmpeg-${PN}-${FFMPEG_VERSION}-${CODENAME}-${FFMPEG_KODI_VERSION}.tar.gz" )
        fi

        cmake-utils_src_configure
}

src_compile() {
        cmake-utils_src_compile all $(usev test)
}

src_install() {
        cmake-utils_src_install

        pax-mark Em "${ED%/}"/usr/${get_libdir}/${PN}/${PN}.bin

        rm "${ED%/}"/usr/share/kodi/addons/skin.estuary/fonts/Roboto-Thin.ttf || die
        dosym ../../../../fonts/roboto/Roboto-Thin.ttf \
                usr/share/kodi/addons/skin.estuary/fonts/Roboto-Thin.ttf

        python_domodule tools/EventClients/lib/python/xbmcclient.py
        python_newscript "tools/EventClients/Clients/KodiSend/kodi-send.py" kodi-send11


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
        if use raspberrypi; then
                doins ${FILESDIR}/10-vchiq-permissions.rules
        elif use odroidc1; then
                doins ${FILESDIR}/10-odroid.rules
                #dodir /usr/share/kodi/local.d
                #exeinto /usr/share/kodi/local.d
                #doexe ${FILESDIR}/kodi-permissions.start
        fi
}

pkg_postinst() {
        if use upower; then
                elog "A polkit-rule was installed to /usr/share/kodi/polkit-rules"
                elog "If you want to shutdown from the kodi menu, copy it to"
                elog "/etc/polkit-1/rules.d/60-kodi.rules"
                elog "and replace \"YourUsernameHere\" with the username which is kodi running"
                elog ""
        else
                elog "If you would shutdown your computer from kodi as a non root user,"
                elog "please install kodi with the USE-Flag \"upower\" enabled"
                elog ""
        fi

        elog "Some udev-rules has installed in \"/usr/share/kodi/udev-configs\"."
        elog "If you wish to use kodi as an non root user, install media-tv/kodi with \"udev\" useflag enabled"
        elog "and copy the rules to /etc/udev/rules.d"
        elog "Also add your user to the group \"input\" to use a keyboard or mouse in kodi"
        elog "Also add your user to the group \"video\" that you can start kodi."
        elog ""

        if use odroidc1; then
                elog "A local.d-Script has installed in \"/usr/share/kodi/local.d\"."
                elog "Do adjust some permissions to start kodi as non root user"
                elog "copy this Script to \"/etc/local.d\"."
                elog ""
        fi

        elog "A init.d-Script called \"kodi\" has been installed."
        elog "Edit \"/etc/conf.d/kodi\" and add your username."
        elog "Then add the init.d-Script to a runlevel."
        elog "\$ rc-update add kodi default"
        elog ""
}
