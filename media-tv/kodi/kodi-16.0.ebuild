# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"

# Does not work with py3 here
# It might work with py:2.5 but I didn't test that
PYTHON_COMPAT=( python2_7 )
PYTHON_REQ_USE="sqlite"

inherit eutils linux-info python-single-r1 multiprocessing autotools toolchain-funcs flag-o-matic

DESCRIPTION="Kodi is a free and open source media-player and entertainment hub (Special ebuild for raspberrypi/odroidc1"
HOMEPAGE="http://kodi.tv/ http://kodi.wiki/"
LICENSE="GPL-2"

CODENAME="Jarvis"
KEYWORDS="~arm"

S=${WORKDIR}/xbmc-${PV}

SRC_URI="http://ftp.uni-erlangen.de/pub/mirrors/gentoo/distfiles/${P}.tar.gz
		 http://mirrors.kodi.tv/releases/source/${PV}-${CODENAME}.tar.gz -> ${P}.tar.gz"

SLOT="0"
IUSE="airplay alsa avahi bluetooth bluray caps cec css dbus debug joystick midi mysql nfs odroidc1 profile pulseaudio raspberrypi +samba sftp spectrum test texturepacker udisks upnp upower +usb waveform webserver"

REQUIRED_USE="
	udisks? ( dbus )
	upower? ( dbus )
	^^ ( raspberrypi odroidc1 )
"

COMMON_DEPEND="${PYTHON_DEPS}
	app-arch/bzip2
	app-arch/unzip
	app-arch/zip
	app-i18n/enca
	airplay? ( app-pda/libplist )
	dev-libs/boost
	dev-libs/expat
	dev-libs/fribidi
	dev-libs/libcdio[-minimal]
	cec? ( >=dev-libs/libcec-3.0 )
	dev-libs/libpcre[cxx]
	dev-libs/libxml2
	dev-libs/libxslt
	>=dev-libs/lzo-2.04
	dev-libs/tinyxml[stl]
	dev-libs/yajl
	dev-python/simplejson[${PYTHON_USEDEP}]
	media-fonts/corefonts
	media-fonts/roboto
	alsa? ( media-libs/alsa-lib )
	media-libs/flac
	media-libs/fontconfig
	media-libs/freetype
	media-libs/jasper
	media-libs/jbigkit
	>=media-libs/libass-0.9.7
	bluray? ( media-libs/libbluray )
	css? ( media-libs/libdvdcss )
	media-libs/libmad
	media-libs/libmodplug
	media-libs/libmpeg2
	media-libs/libogg
	media-libs/libpng:0=
	media-libs/libsamplerate
	joystick? ( media-libs/libsdl2 )
	>=media-libs/taglib-1.8
	media-libs/libvorbis
	media-libs/tiff:0=
	pulseaudio? ( media-sound/pulseaudio )
	media-sound/wavpack
	>=media-video/ffmpeg-2.6:=[encode]
	avahi? ( net-dns/avahi )
	nfs? ( net-fs/libnfs:= )
	webserver? ( net-libs/libmicrohttpd[messages] )
	sftp? ( net-libs/libssh[sftp] )
	net-misc/curl
	samba? ( >=net-fs/samba-3.4.6[smbclient(+)] )
	bluetooth? ( net-wireless/bluez )
	dbus? ( sys-apps/dbus )
	caps? ( sys-libs/libcap )
	sys-libs/zlib
	virtual/jpeg:0=
	usb? ( virtual/libusb:1 )
	mysql? ( virtual/mysql )
	media-sound/dcadec
	raspberrypi? ( media-video/ffmpeg[mmal] media-libs/raspberrypi-userland )
	odroidc1? ( media-libs/aml-odroidc1 media-libs/odroidc1-mali-fb )
	dev-libs/crossguid
	"
RDEPEND="${COMMON_DEPEND}
	udisks? ( sys-fs/udisks:0 )
	upower? ( || ( sys-power/upower sys-power/upower-pm-utils ) )"
DEPEND="${COMMON_DEPEND}
	app-arch/xz-utils
	dev-lang/swig
	dev-util/gperf
	texturepacker? ( media-libs/giflib )
	dev-util/cmake
	virtual/jre
	test? ( dev-cpp/gtest )
	"

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
	#If raspberrypi-userland is installed in /opt/vc, we have to add some flags
	if use raspberrypi; then
		if [ -d /opt/vc ]; then
			append-flags "-I/opt/vc/include/ -I/opt/vc/include/interface/vcos/pthreads -I/opt/vc/include/interface/vmcs_host/linux -I/opt/vc/include/interface/IL"
			append-ldflags "-L/opt/vc/lib"
		else
			append-flags "-I/usr/include/interface/vcos/pthreads -I/usr/include/interface/vmcs_host/linux -I/usr/include/interface/IL"
		fi
	fi

	check_extra_config
	python-single-r1_pkg_setup
}

src_unpack() {
	default
}

src_prepare() {
	epatch "${FILESDIR}"/kodi-15.2-no-arm-flags.patch #400617
	epatch "${FILESDIR}"/kodi-15.2-texturepacker.patch
	epatch_user #293109

	# some dirs ship generated autotools, some dont
	multijob_init
	local d dirs=(
		tools/depends/native/TexturePacker/src/configure
		$(printf 'f:\n\t@echo $(BOOTSTRAP_TARGETS)\ninclude bootstrap.mk\n' | emake -f - f)
	)
	for d in "${dirs[@]}" ; do
		[[ -e ${d} ]] && continue
		pushd ${d/%configure/.} >/dev/null || die
		AT_NOELIBTOOLIZE="yes" AT_TOPLEVEL_EAUTORECONF="yes" \
		multijob_child_init eautoreconf
		popd >/dev/null
	done
	multijob_finish
	elibtoolize
	
	#Java related stuff
	tc-env_build emake -f codegenerator.mk

	# Disable internal func checks as our USE/DEPEND
	# stuff handles this just fine already #408395
	export ac_cv_lib_avcodec_ff_vdpau_vc1_decode_picture=yes

	# Fix the final version string showing as "exported"
	# instead of the SVN revision number.
	export HAVE_GIT=no GIT_REV=${EGIT_VERSION:-exported}

	# avoid long delays when powerkit isn't running #348580
	sed -i \
		-e '/dbus_connection_send_with_reply_and_block/s:-1:3000:' \
		xbmc/linux/*.cpp || die

	# Tweak autotool timestamps to avoid regeneration
	find . -type f -exec touch -r configure {} +
}

src_configure() {
	# Disable documentation generation
	export ac_cv_path_LATEX=no
	# Avoid help2man
	export HELP2MAN=$(type -P help2man || echo true)
	# No configure flage for this #403561
	export ac_cv_lib_bluetooth_hci_devid=$(usex bluetooth)
	# Requiring java is asine #434662
	export ac_cv_path_JAVA_EXE=$(which java)

	if use raspberrypi; then
		MY_ECONF="--with-platform=raspberry-pi --enable-player=omxplayer"
	elif use odroidc1; then
		MY_ECONF="--enable-codec=amcodec"
	fi

	econf \
		--docdir=/usr/share/doc/${PF} \
		--disable-ccache \
		--enable-optimizations \
		--with-ffmpeg=shared \
		--enable-gles \
		--disable-x11 \
		--disable-gl \
		--disable-rtmp \
		--disable-vtbdecoder \
		${MY_ECONF} \
		$(use_enable alsa) \
		$(use_enable airplay) \
		$(use_enable avahi) \
		$(use_enable bluray libbluray) \
		$(use_enable caps libcap) \
		$(use_enable cec libcec) \
		$(use_enable css dvdcss) \
		$(use_enable dbus) \
		$(use_enable debug) \
		$(use_enable joystick) \
		$(use_enable midi mid) \
		$(use_enable mysql) \
		$(use_enable nfs) \
		$(use_enable profile profiling) \
		$(use_enable pulseaudio pulse) \
		$(use_enable samba) \
		$(use_enable sftp ssh) \
		$(use_enable usb libusb) \
		$(use_enable test gtest) \
		$(use_enable texturepacker) \
		$(use_enable upnp) \
		$(use_enable webserver)
}

src_compile() {
	emake
}

src_install() {
	default
	rm "${ED}"/usr/share/doc/*/{LICENSE.GPL,copying.txt}*

	# Remove optional addons (platform specific).
	local disabled_addons=(
		repository.pvr-{android,ios,osx{32,64},win32}.xbmc.org
		visualization.dxspectrum
		visualization.vortex
	)
	rm -rf "${disabled_addons[@]/#/${ED}/usr/share/kodi/addons/}"

	# Remove fonconfig settings that are used only on MacOSX.
	# Can't be patched upstream because they just find all files and install
	# them into same structure like they have in git.
	rm -rf "${ED}"/usr/share/kodi/system/players/dvdplayer/etc

	# Replace bundled fonts with system ones
	# teletext.ttf: unknown
	# bold-caps.ttf: unknown
	# roboto: roboto-bold, roboto-regular
	# arial.ttf: font mashed from droid/roboto, not removed wrt bug#460514
	rm -rf "${ED}"/usr/share/kodi/addons/skin.confluence/fonts/Roboto-*
	dosym /usr/share/fonts/roboto/Roboto-Regular.ttf \
		/usr/share/kodi/addons/skin.confluence/fonts/Roboto-Regular.ttf
	dosym /usr/share/fonts/roboto/Roboto-Bold.ttf \
		/usr/share/kodi/addons/skin.confluence/fonts/Roboto-Bold.ttf

	python_domodule tools/EventClients/lib/python/xbmcclient.py
	python_newscript "tools/EventClients/Clients/Kodi Send/kodi-send.py" kodi-send

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
		doins ${FILESDIR}/10-mali-permissions.rules
		dodir /usr/share/kodi/local.d
		exeinto /usr/share/kodi/local.d
		doexe ${FILESDIR}/kodi-permissions.start
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
	elog "If you wish to use kodi as an non root user, install sys-fs/udev an copy the rules to"
	elog "/etc/udev/rules.d"
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
