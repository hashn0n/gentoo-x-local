# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit meson ninja-utils git-r3

PACKAGEAUTHOR="Genymobile"
GITREPNAME="scrcpy"

EGIT_REPO_URI="https://github.com/${PACKAGEAUTHOR}/${GITREPNAME}.git"

if [[ ${PV} = 9999* ]]; then
	MY_SERVER_PV="1.16"
else
	EGIT_COMMIT="v${PV}"
	MY_SERVER_PV="${PV}"
	KEYWORDS="~amd64"
fi

MY_SERVER_PN="${GITREPNAME}-server"
MY_SERVER_P="${MY_SERVER_PN}-v${MY_SERVER_PV}"

SRC_URI="https://github.com/${PACKAGEAUTHOR}/${PN}/releases/download/v${MY_SERVER_PV}/${MY_SERVER_P} -> ${MY_SERVER_PN}-v${MY_SERVER_PV}.jar"

DESCRIPTION="Display and control your Android device"
HOMEPAGE="https://blog.rom1v.com/2018/03/introducing-${GITREPNAME}/
	https://github.com/${PACKAGEAUTHOR}/${GITREPNAME}"

LICENSE="Apache-2.0"
SLOT="0"
IUSE=""

RESTRICT="test"

COMMON_DEPEND="media-libs/libsdl2
	media-video/ffmpeg"
DEPEND="${COMMON_DEPEND}"
RDEPEND="${COMMON_DEPEND}"
PDEPEND=""

src_configure() {
	local emesonargs=(
		-Db_lto=true
		-Dprebuilt_server="${DISTDIR}/${MY_SERVER_P}.jar"
	)
	meson_src_configure
}
