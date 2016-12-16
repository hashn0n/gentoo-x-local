# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-plugins/compiz-plugins-extra/compiz-plugins-extra-0.8.6-r1.ebuild,v 1.5 2011/03/21 19:47:45 nirbheek Exp $

EAPI="5"

inherit autotools eutils gnome2-utils

DESCRIPTION="Compiz Extra Plugins"
HOMEPAGE="http://blog.northfield.ws/
	http://blog.northfield.ws/"
SRC_URI="http://www.northfield.ws/projects/compiz/releases/${PV}/${PN##compiz-}.tar.xz -> ${P}.tar.xz"
S="${WORKDIR}/${PN##compiz-}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
IUSE=""

RDEPEND="
	>=gnome-base/librsvg-2.14.0:2
	virtual/jpeg:0
	>=x11-libs/compiz-bcop-${PV}
	>=x11-plugins/compiz-plugins-main-${PV}
	>=x11-wm/compiz-${PV}
"

DEPEND="${RDEPEND}
	>=dev-util/intltool-0.35
	>=dev-util/pkgconfig-0.19
	>=sys-devel/gettext-0.15
	x11-libs/cairo
"

src_prepare() {
	# Prevent m4_copy error when running aclocal
	# m4_copy: won't overwrite defined macro: glib_DEFUN
	rm m4/glib-gettext.m4 || die

	intltoolize --copy --force || die "intltoolize failed"
	eautoreconf || die "eautoreconf failed"
}

src_configure() {
	econf \
		--disable-dependency-tracking \
		--enable-fast-install \
		--disable-static \
		--with-gnu-ld
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	find "${D}" -name '*.la' -delete || die
}
