# Copyright 2015 Daniel 'herrnst' Scheller, Team Kodi
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

EGIT_REPO_URI="https://github.com/xbmc/kodi-platform.git"
EGIT_BRANCH="master"
EGIT_COMMIT="45d6ad1984fdb1dc855076ff18484dbec33939d1"

inherit git-r3 cmake-utils

DESCRIPTION="Kodi platform support library"
HOMEPAGE="http://kodi.tv"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~arm"
IUSE=""

DEPEND="
	media-tv/kodi
	dev-libs/libplatform
	dev-libs/tinyxml
	"

RDEPEND="
	dev-libs/tinyxml
	"
