# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-plugins/compiz-plugins-extra/compiz-plugins-extra-0.8.6-r1.ebuild,v 1.5 2011/03/21 19:47:45 nirbheek Exp $

EAPI="5"

inherit autotools eutils gnome2-utils

DESCRIPTION="Compiz Extra Plugins"
HOMEPAGE="https://github.com/compiz-reloaded/${PN%%-reloaded}"
SRC_URI="https://github.com/compiz-reloaded/${PN%%-reloaded}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
IUSE=""

RDEPEND="
	>=gnome-base/librsvg-2.14.0:2
	virtual/jpeg:0
	>=x11-libs/compiz-bcop-reloaded-${PV}
	>=x11-plugins/compiz-plugins-main-reloaded-${PV}
	>=x11-wm/compiz-reloaded-${PV}
"

DEPEND="${RDEPEND}
	>=dev-util/intltool-0.35
	>=dev-util/pkgconfig-0.19
	>=sys-devel/gettext-0.15
	x11-libs/cairo
"

src_prepare() {
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
