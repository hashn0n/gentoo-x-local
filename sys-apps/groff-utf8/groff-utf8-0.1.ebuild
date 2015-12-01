# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

DESCRIPTION="Extension of groff that permits to view UTF-8 encoded man pages"
HOMEPAGE="http://www.haible.de/bruno/packages-groff-utf8.html"
SRC_URI="http://www.haible.de/bruno/gnu/groff-utf8.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND=">=sys-apps/groff-1.18.1"
RDEPEND="${DEPEND}"


src_install() {

    cd "${WORKDIR}/${PN}"
    make install PREFIX=${D}/usr
}