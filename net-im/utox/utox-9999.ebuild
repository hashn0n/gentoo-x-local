# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
PACKAGEAUTHOR="utox"
inherit eutils fdo-mime git-r3 gnome2-utils toolchain-funcs cmake-utils

DESCRIPTION="Lightweight Tox client"
HOMEPAGE="http://utox.org
	https://github.com/${PACKAGEAUTHOR}/${PN}"
EGIT_REPO_URI="
		https://github.com/${PACKAGEAUTHOR}/${PN}.git
		git://github.com/${PACKAGEAUTHOR}/${PN}.git
"

LICENSE="GPL-3"
SLOT="0"
IUSE="+dbus +filter_audio"

RDEPEND="net-libs/tox[av]
	media-libs/freetype
	filter_audio? ( media-libs/libfilteraudio )
	media-libs/libv4l
	media-libs/libvpx
	media-libs/openal
	x11-libs/libX11
	x11-libs/libXext
	dbus? ( sys-apps/dbus )"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_prepare() {
	epatch_user
}

src_configure() {
#	# respect CFLAGS
#	sed -i \
#		-e '/CFLAGS/s# -g ##' \
#		Makefile || die
	cmake-utils_src_configure
}

src_compile() {
#	emake \
#		CC="$(tc-getCC)" \
#		DBUS=$(usex dbus "1" "0") \
#		FILTER_AUDIO=$(usex filter_audio "1" "0")
	cmake-utils_src_compile
}

src_install() {
#	emake DESTDIR="${D}" PREFIX="/usr" install
	cmake-utils_src_install
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}
