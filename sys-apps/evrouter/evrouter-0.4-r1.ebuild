# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit autotools

DESCRIPTION="An input event router"
HOMEPAGE="https://www.bedroomlan.org/projects/evrouter"

SRC_URI="https://files.bedroomlan.org/debian/pool/main/e/evrouter/${PN}_${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""

DEPEND="x11-libs/libX11
	x11-libs/libXext
	x11-libs/libxcb
	x11-libs/libXau
	x11-libs/libXdmcp"

RDEPEND="${DEPEND}"

src_prepare() {
	eautoreconf
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# fix window title GTK2 detection.
	# http://als.regnet.cz/evrouter-gtk2-focus-patch.html
	epatch "${FILESDIR}"/evrouter-focus.patch
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc src/example || die "dodoc failed"
}
