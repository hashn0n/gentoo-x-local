# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{4,5} pypy )

inherit distutils-r1 git-r3

PACKAGEAUTHOR="MayeulC"
GITREPNAME="Saitek"

DESCRIPTION="Control utility for some features of Saitek Cyborg R.A.T mice!"
HOMEPAGE="https://github.com/${PACKAGEAUTHOR}/${GITREPNAME}"
EGIT_REPO_URI="https://github.com/${PACKAGEAUTHOR}/${GITREPNAME}.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="
	dev-python/setuptools[${PYTHON_USEDEP}]
	dev-python/PyQt5[${PYTHON_USEDEP}]
"
RDEPEND="
	dev-python/python-libusb1
"

src_configure() {
:
}

src_compile() {
:
}

src_install() {
	into "/opt"
	dobin "${S}/ratctl.py"
}

pkg_postinst() {
	elog "To be able to read status information of mouse"
	elog "user need read access to /dev/input/*"
	elog "To be able to change DPI for profiles of mouse"
	elog "user need write access to /dev/input/*"
}
