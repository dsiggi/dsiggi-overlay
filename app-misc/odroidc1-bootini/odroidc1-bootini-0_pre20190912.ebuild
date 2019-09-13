# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="6"

inherit eutils


DESCRIPTION="Bootscripts for odroidC1"
HOMEPAGE="https://github.com/mdrjr/c1_bootini"
COMMIT=ef9cc1cef4817a6cd899d6f885bdfad08e103238
SRC_URI="https://github.com/mdrjr/c1_bootini/archive/${COMMIT}.tar.gz -> ${PF}.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~arm"
IUSE="openrc -systemd"

REQUIRED_USE="^^ ( openrc systemd )"

DEPEND="sys-apps/fbset"

S=${WORKDIR}/c1_bootini-${COMMIT}

src_compile() {
	rm "${S}"/Makefile
}

src_install() {
        into /usr/bin
	dobin ${S}/c1_init.sh

	insinto /usr/share/${PN}
	doins ${S}/boot.ini

	insinto /etc/sysctl.d
	doins ${S}/99-c1-network.conf

	insinto /lib/udev/rules.d
	doins ${S}/99-gpiomem.rules

	if use openrc; then
		insinto /etc/init.d
		doins ${FILESDIR}/c1_init
	elif use systemd; then
		insinto /etc/systemd/systemd
		doins ${FILESDIR}/c1_boot.service
	fi
}

pkg_postinst() {
	if use openrc; then
		elog "The c1_init-script has installed for openrc."
		elog "Please add it to runleven by:"
		elog "	rc-update add c1_init default"
	elif use systemd; then
		elog "The c1_init-service has installed for systemd."
		elog "Please add it to runlevel by:"
		elog "	systemctl enable c1_init.service"
	fi
	
	elog "A example boot.ini is installed to \"/usr/share/${PN}/boot.ini\""
}
