# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-apps/ccsm/ccsm-0.8.4-r1.ebuild,v 1.2 2011/04/11 19:51:07 arfrever Exp $

EAPI="5"

PYTHON_COMPAT=( python2_7 )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1

DESCRIPTION="Compizconfig Settings Manager"
HOMEPAGE="http://blog.northfield.ws/
	http://blog.northfield.ws/"
SRC_URI="http://www.northfield.ws/projects/compiz/releases/${PV}/${PN}.tar.xz -> ${P}.tar.xz"
S="${WORKDIR}/${PN}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	>=dev-python/compizconfig-python-${PV}
	>=dev-python/pygtk-2.12:2
	gnome-base/librsvg
"

DEPEND="${RDEPEND}"

DOCS="AUTHORS"

src_compile() {
	distutils-r1_src_compile
}

src_install() {
	distutils-r1_src_install install --prefix=/usr
}
