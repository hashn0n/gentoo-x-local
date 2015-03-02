# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/emerald-themes/emerald-themes-0.5.2.ebuild,v 1.3 2007/10/24 18:39:26 hanno Exp $

EAPI="5"

inherit autotools eutils

DESCRIPTION="Emerald window decorator themes"
HOMEPAGE="http://blog.northfield.ws/
	http://blog.northfield.ws/"
SRC_URI="http://www.northfield.ws/projects/compiz/releases/${PV}/${PN##compiz-}.tar.gz"
S="${WORKDIR}/${PN}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
IUSE=""
DEPEND="x11-wm/emerald"

src_prepare() {
	eautoreconf || die "eautoreconf failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
}
