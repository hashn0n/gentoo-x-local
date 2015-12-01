# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils git-2

IUSE="dev"

DESCRIPTION="Colobot (Colonize with Bots) is an educational real-time strategy video game featuring 3D graphics"
HOMEPAGE="http://colobot.info/"
SRC_URI=""

EGIT_REPO_URI="https://github.com/colobot/colobot.git"
EGIT_PROJECT="colobot"
if use dev; then
  EGIT_BRANCH="dev"
else
  EGIT_BRANCH="master"
fi

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"

DEPEND="
  media-libs/sdl-image
  media-libs/sdl-ttf
  media-libs/openal
  dev-libs/boost
  dev-util/cmake
"
RDEPEND="
  ${DEPEND}
  games-strategy/colobot-data
"

S="${WORKDIR}/${PN}"

src_configure() {
  if use dev; then
    EXTRA_PARAMS="-DSTATIC_BOOST=OFF"
  fi
  cd ${S}
  cmake -DCMAKE_BUILD_TYPE=Release -DOPENAL_SOUND=1 ${EXTRA_PARAMS} .
}
