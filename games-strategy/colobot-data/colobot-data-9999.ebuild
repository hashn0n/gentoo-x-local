# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit eutils git-r3

PACKAGEAUTHOR="colobot"
IUSE="dev"

DESCRIPTION="Data package for colobot (Colonize with Bots)"
HOMEPAGE="http://colobot.info/
	https://github.com/${PACKAGEAUTHOR}/${PN}"

if [[ ${PV} = 9999* ]]; then
	inherit git-r3
	EGIT_PROJECT="${PN}-data"
	EGIT_REPO_URI="https://github.com/${PACKAGEAUTHOR}/${PN}.git"
	KEYWORDS="~amd64"
else
	SRC_URI="https://github.com/${PACKAGEAUTHOR}/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="amd64"
fi


LICENSE="GPL-3"
SLOT="0"

DEPEND=""
RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}"

pkg_setup() {
	if use dev; then
		EGIT_BRANCH="dev"
	else
		EGIT_BRANCH="master"
	fi
}

src_install() {
	insinto /usr/local/share/games/colobot
	doins -r *
}
