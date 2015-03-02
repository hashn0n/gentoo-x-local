# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/compiz-bcop/compiz-bcop-0.8.4.ebuild,v 1.1 2009/10/15 16:35:51 mrpouet Exp $

EAPI="5"

inherit autotools eutils

DESCRIPTION="Compiz Option code Generator"
HOMEPAGE="http://blog.northfield.ws/
	http://blog.northfield.ws/"
SRC_URI="http://www.northfield.ws/projects/compiz/releases/${PV}/${PN##compiz-}.tar.gz"
S="${WORKDIR}/${PN##compiz-}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
IUSE=""

RDEPEND="dev-libs/libxslt"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.19"

src_prepare() {
	eautoreconf || die "eautoreconf failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
}
