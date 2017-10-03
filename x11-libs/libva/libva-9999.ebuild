# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

AUTOTOOLS_AUTORECONF="yes"
inherit autotools-multilib multilib

DESCRIPTION="Video Acceleration (VA) API for Linux"

LICENSE="MIT"

PACKAGEAUTHOR="01org"
HOMEPAGE="https://01.org/linuxmedia/vaapi
	https://github.com/${PACKAGEAUTHOR}/${PN}"
if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_BRANCH=master
	EGIT_REPO_URI="
		git://github.com/${PACKAGEAUTHOR}/${PN}
		https://github.com/${PACKAGEAUTHOR}/${PN}
	"
	RESTRICT="mirror"
	SRC_URI=""
	KEYWORDS="-amd64 -x86 -amd64-linux -x86-linux"
else
	KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
	SRC_URI="https://github.com/${PACKAGEAUTHOR}/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
fi

SLOT="0"
IUSE="+drm egl opengl vdpau wayland X utils"

VIDEO_CARDS="dummy nvidia intel i965 fglrx nouveau"
for x in ${VIDEO_CARDS}; do
	IUSE+=" video_cards_${x}"
done

RDEPEND=">=x11-libs/libdrm-2.4.46[${MULTILIB_USEDEP}]
	X? (
		>=x11-libs/libX11-1.6.2[${MULTILIB_USEDEP}]
		>=x11-libs/libXext-1.3.2[${MULTILIB_USEDEP}]
		>=x11-libs/libXfixes-5.0.1[${MULTILIB_USEDEP}]
	)
	egl? ( >=media-libs/mesa-9.1.6[egl,${MULTILIB_USEDEP}] )
	opengl? ( >=virtual/opengl-7.0-r1[${MULTILIB_USEDEP}] )
	wayland? ( >=dev-libs/wayland-1.0.6[${MULTILIB_USEDEP}] )"

DEPEND="${RDEPEND}
	virtual/pkgconfig"
PDEPEND="video_cards_nvidia? ( >=x11-libs/libva-vdpau-driver-0.7.4-r1[${MULTILIB_USEDEP}] )
	video_cards_nouveau? ( >=x11-libs/libva-vdpau-driver-0.7.4-r3[${MULTILIB_USEDEP}] )
	vdpau? ( >=x11-libs/libva-vdpau-driver-0.7.4-r1[${MULTILIB_USEDEP}] )
	video_cards_fglrx? (
		|| ( >=x11-drivers/ati-drivers-14.12-r3[${MULTILIB_USEDEP}]
			>=x11-libs/xvba-video-0.8.0-r1[${MULTILIB_USEDEP}] )
		)
	video_cards_intel? ( >=x11-libs/libva-intel-driver-1.2.2-r1[${MULTILIB_USEDEP}] )
	video_cards_i965? ( >=x11-libs/libva-intel-driver-1.2.2-r1[${MULTILIB_USEDEP}] )
	utils? ( media-video/libva-utils )
	"

REQUIRED_USE="|| ( drm wayland X )
		opengl? ( X )"

DOCS=( NEWS )

MULTILIB_WRAPPED_HEADERS=(
/usr/include/va/va_backend_glx.h
/usr/include/va/va_x11.h
/usr/include/va/va_dri2.h
/usr/include/va/va_dricommon.h
/usr/include/va/va_glx.h
)

multilib_src_configure() {
	local myeconfargs=(
		--with-drivers-path="${EPREFIX}/usr/$(get_libdir)/va/drivers"
		$(use_enable video_cards_dummy dummy-driver)
		$(use_enable opengl glx)
		$(use_enable X x11)
		$(use_enable wayland)
		$(use_enable egl)
		$(use_enable drm)
	)
	autotools-utils_src_configure
}
