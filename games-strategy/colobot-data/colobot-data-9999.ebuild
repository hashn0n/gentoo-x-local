# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils git-2

IUSE="dev"

DESCRIPTION="Data package for colobot (Colonize with Bots)"
HOMEPAGE="http://colobot.info/"
SRC_URI=""

EGIT_REPO_URI="https://github.com/colobot/colobot-data.git"
EGIT_PROJECT="colobot-data"
if use dev; then
  EGIT_BRANCH="dev"
else
  EGIT_BRANCH="master"
fi

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"

DEPEND=""
RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}"

src_install() {
  insinto /usr/local/share/games/colobot
  doins -r *
}

