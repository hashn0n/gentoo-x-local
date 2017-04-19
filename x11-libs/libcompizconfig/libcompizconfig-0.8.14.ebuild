# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libcompizconfig/libcompizconfig-0.8.4-r2.ebuild,v 1.2 2011/03/21 19:52:57 nirbheek Exp $

EAPI="5"

inherit autotools eutils

DESCRIPTION="Compiz Configuration System"
HOMEPAGE="http://blog.northfield.ws/
	http://blog.northfield.ws/"
SRC_URI="http://www.northfield.ws/projects/compiz/releases/${PV}/${P}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
IUSE=""

RDEPEND="
	dev-libs/libxml2:2
	dev-libs/protobuf
	=x11-wm/compiz-${PV}
"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.41
	>=dev-util/pkgconfig-0.19
"

RESTRICT="test"

src_prepare() {
	eautoreconf || die "eautoreconf failed"
}

src_configure() {
	econf \
		--disable-dependency-tracking \
		--enable-fast-install \
		--with-gnu-ld \
		--disable-static
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	find "${D}" -name '*.la' -delete || die
}
