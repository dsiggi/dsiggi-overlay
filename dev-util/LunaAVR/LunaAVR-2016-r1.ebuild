# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="6"

inherit eutils

DESCRIPTION="Luna ist eine objektorientierte, moderne Basic/Pascal-ähnliche Programmiersprache für Atmel AVR Mikrocontroller"
HOMEPAGE="http://http://avr.myluna.de/"
SRC_URI="http://avr.myluna.de/lib/exe/fetch.php?media=lunaavr-${PV}${PR}-linux.tar.gz -> ${PF}.tar.gz"
LANGUAGES="de en"
#URI for the Languafe Reference
R_URI="http://avr.myluna.de/lib/exe/fetch.php?media=lunaavr-2016-05-01"
#Filename of the Language Reference
LREFERENCE=${R_URI##*=}

IUSE="doc examples"

for lang in ${LANGUAGES}; do
			IUSE+=" l10n_${lang%:*}"
			reference="l10n_${lang%:*}? ( ${R_URI}-${lang}.pdf -> ${LREFERENCE}-${lang}.pdf )"
			SRC_URI_DOC+=" $reference"
done

#URI for the example projects
E_URI="http://avr.myluna.de/lib/exe/fetch.php?media=luna-examples-2016.r1-160501.zip"
E_FILE=${E_URI##*=}
E_VER=${E_URI##*examples-}
E_VER=${E_VER%%.zip}
SRC_URI+=" examples? ( $E_URI -> $E_FILE )
			doc? ( $SRC_URI_DOC )"

LICENSE="LunaAVR"
SLOT="0"
KEYWORDS="x86 amd64"


RDEPEND=""
DEPEND="${RDEPEND}"

S="${WORKDIR}/lunaavr-${PV}${PR}-linux"

src_unpack(){
	unpack ${A}
}

src_install() {
	#Install the package to /opt/LunaAVR
	dodir /opt/LunaAVR/
	cd "${S}"
	cp -R . "${D}/opt/LunaAVR/" || die "Install failed"

	#Install the bins
	bins="LunaAVR lavrc lavride"
	exeinto /opt/LunaAVR
	for b in $bins; do
		rm -f "${D}"/opt/LunaAVR/$b
		doexe "${S}"/$b
	done

	#Install the config to /etc an make a symlink
	dodir /etc/
	insinto /etc/
	insopts	-m666
	doins LunaAVR.cfg
	rm -f ${D}/opt/LunaAVR/LunaAVR.cfg
	dosym /etc/LunaAVR.cfg /opt/LunaAVR/LunaAVR.cfg

	#Install the icons
	icon_sizes="16 32 48 64 128"
	for s in $icon_sizes; do
		doicon -s $s "${S}"/Icons/Luna-Icon-"$s"x"$s".png
	done

	#Install a menuentry
	domenu "${FILESDIR}"/LunaAVR.desktop

	#Install documentation
	if use doc; then
		for lang in ${LANGUAGES}; do
			if [ -f "${DISTDIR}"/${LREFERENCE}-${lang}.pdf ]; then
				cp "${DISTDIR}"/${LREFERENCE}-${lang}.pdf "${D}/opt/LunaAVR/Language Reference/"
			fi
		done
	fi

	#Install examples
	if use examples; then
		cd "${WORKDIR}/luna-examples-$E_VER/"
		cp -R . "${D}"/opt/LunaAVR/Examples/
	fi
}

pkg_postinst(){
	if use doc; then
		version=${LREFERENCE##lunaavr-}
		elog "Installed Language Reference Version $version"
	fi

	if use examples; then
			elog "Installed examples Version $E_VER"
	fi
}
