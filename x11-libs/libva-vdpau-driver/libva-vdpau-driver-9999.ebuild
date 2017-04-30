# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

AUTOTOOLS_AUTORECONF="yes"
inherit autotools-multilib

DESCRIPTION="VDPAU Backend for Video Acceleration (VA) API"
HOMEPAGE="https://www.freedesktop.org/wiki/Software/vaapi"

LICENSE="GPL-2"
SLOT="0"

if [[ ${PV} == *9999* ]]; then
	inherit git-2
	EGIT_BRANCH=master
#	EGIT_REPO_URI="https://github.com/${PACKAGEAUTHOR}/${PN}.git"
	EGIT_REPO_URI="https://anongit.freedesktop.org/git/vaapi/vdpau-driver.git"
	RESTRICT="mirror"
	SRC_URI=""
	S="${WORKDIR}/${PN}"
	KEYWORDS="~amd64 ~x86"
else
	KEYWORDS=""
#	SRC_URI="https://github.com/${PACKAGEAUTHOR}/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
	SRC_URI="https://www.freedesktop.org/software/vaapi/releases/libva-vdpau-driver/${P}.tar.bz2"
fi
IUSE="debug opengl"

RDEPEND=">=x11-libs/libva-1.2.1-r1[X,opengl?,${MULTILIB_USEDEP}]
	opengl? ( >=virtual/opengl-7.0-r1[${MULTILIB_USEDEP}] )
	>=x11-libs/libvdpau-0.7[${MULTILIB_USEDEP}]
	!x11-libs/vdpau-video"

DEPEND="${DEPEND}
	virtual/pkgconfig"

DOCS=( NEWS README AUTHORS )

multilib_src_configure() {
	local myeconfargs=(
		$(use_enable debug)
		$(use_enable opengl glx)
	)
	autotools-utils_src_configure
}
