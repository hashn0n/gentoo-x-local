# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

PYTHON_COMPAT=( python2_7 )

inherit python-r1 base

DESCRIPTION="The system-config-users tool lets you manage the users and groups on your computer."
HOMEPAGE="http://fedoraproject.org/wiki/SystemConfig/users"
SRC_URI="https://fedorahosted.org/releases/s/y/${PN}/${P}.tar.bz2"

LICENSE="GPL-1"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE="X"

DEPEND="
	dev-util/desktop-file-utils
	dev-util/intltool
	sys-apps/findutils
	sys-devel/gettext"

RDEPEND="
	${PYTHON_DEPS}
	X? (	>=dev-python/pygtk-2.6
		x11-misc/xdg-utils
	)
	>=sys-libs/libuser-0.56.18
	>=sys-apps/usermode-1.106
	sys-libs/cracklib
	sys-process/procps"

PATCHES=( "${FILESDIR}/${PV}-remove_rpm.patch" )

#pkg_postrm() {
#        python_mod_cleanup /usr/share/${PN}
#}

src_install() {
	base_src_install
}
