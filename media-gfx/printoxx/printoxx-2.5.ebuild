# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

#FIXME: This package doesn't need install userguide html docs implicitly
# (for example i don't want them)
DESCRIPTION="Program for printing one or more image files with a user-defined page layout"
HOMEPAGE="http://kornelix.squarespace.com/printoxx"
SRC_URI="http://kornelix.squarespace.com/storage/downloads/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=x11-libs/gtk+-2.8"
RDEPEND="${DEPEND}"

src_compile() {
	emake || die "build failed"
}

src_install() {
	emake DESTDIR="${D}" PREFIX=/usr install || die "emake install failed"
	make_desktop_entry ${PN} "Printoxx" /usr/share/${PN}/icons/${PN}.png "Application;Graphics;2DGraphics;"
	rm "${D}"/usr/share/doc/${PN}/{COPYING,README} || die "Clean-up unnecessary docs failed"
}
