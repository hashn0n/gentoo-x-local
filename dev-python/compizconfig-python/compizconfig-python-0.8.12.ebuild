# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/compizconfig-python/compizconfig-python-0.8.4-r3.ebuild,v 1.1 2010/09/08 22:18:08 flameeyes Exp $

EAPI="5"

PYTHON_COMPAT=( python2_7 )

inherit autotools eutils python-single-r1

DESCRIPTION="Compizconfig Python Bindings"
HOMEPAGE="http://blog.northfield.ws/
	http://blog.northfield.ws/"
SRC_URI="http://www.northfield.ws/projects/compiz/releases/${PV}/${PN}.tar.xz -> ${P}.tar.xz"
S="${WORKDIR}/${PN}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	>=dev-libs/glib-2.6
	>=x11-libs/libcompizconfig-${PV}
	dev-python/cython
"

DEPEND="${RDEPEND}
	dev-python/pyrex
	dev-util/pkgconfig"

src_prepare() {
	eautoreconf
}
