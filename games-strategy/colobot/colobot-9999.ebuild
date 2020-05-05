# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=7

inherit eutils

PACKAGEAUTHOR="colobot"
IUSE="dev"

DESCRIPTION="Colobot (Colonize with Bots) is an educational real-time strategy video game featuring 3D graphics"
HOMEPAGE="http://colobot.info/
	https://github.com/${PACKAGEAUTHOR}/${PN}"

if [[ ${PV} = 9999* ]]; then
	inherit git-r3
	EGIT_PROJECT="${PN}"
	EGIT_REPO_URI="https://github.com/${PACKAGEAUTHOR}/${PN}.git"
	KEYWORDS="~amd64"
else
	SRC_URI="https://github.com/${PACKAGEAUTHOR}/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="amd64"
fi

LICENSE="GPL-3"
SLOT="0"

DEPEND="
	media-libs/sdl-image
	media-libs/openal
	dev-libs/boost
	dev-util/cmake
"

RDEPEND="
	games-strategy/colobot-data
	${DEPEND}
"

S="${WORKDIR}/${PN}"

pkg_setup() {
	if use dev; then
		EGIT_BRANCH="dev"
	else
		EGIT_BRANCH="master"
	fi
}

src_prepare() {
	if use dev; then
		eatch ${FILESDIR}/fix_man_dependency-dev.patch
	else
		epatch ${FILESDIR}/use_dynamic_boost.patch
		epatch ${FILESDIR}/fix_man_dependency.patch
	fi
}

src_configure() {
	if use dev; then
	EXTRA_PARAMS="-DSTATIC_BOOST=OFF"
	fi

	cd ${S}
	cmake -DCMAKE_BUILD_TYPE=Release -DOPENAL_SOUND=1 ${EXTRA_PARAMS} .
}
