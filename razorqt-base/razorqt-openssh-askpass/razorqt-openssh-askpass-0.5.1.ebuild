# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/razorqt-base/razorqt-openssh-askpass/razorqt-openssh-askpass-0.5.1.ebuild,v 1.5 2013/01/20 19:08:55 ago Exp $

EAPI=4
inherit cmake-utils

DESCRIPTION="Razor-qt OpenSSH ask password interface"
HOMEPAGE="http://razor-qt.org/"

if [[ ${PV} = *9999* ]]; then
	inherit git-2
	EGIT_REPO_URI="git://github.com/Razor-qt/razor-qt.git"
	EGIT_BRANCH="master"
	KEYWORDS=""
else
	SRC_URI="mirror://github/Razor-qt/razor-qt/razorqt-${PV}.tar.bz2"
	KEYWORDS="amd64 ~ppc x86"
	S="${WORKDIR}/razorqt-${PV}"
fi

LICENSE="LGPL-2.1+"
SLOT="0"
IUSE=""

DEPEND="razorqt-base/razorqt-libs"
RDEPEND="${DEPEND}
	razorqt-base/razorqt-data"

DOCS=( "${PN}/README" )

src_configure() {
	local mycmakeargs=(
		-DSPLIT_BUILD=On
		-DMODULE_ASKPASS=On
	)
	cmake-utils_src_configure
}
