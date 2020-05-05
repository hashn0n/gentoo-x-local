# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=7

inherit eutils toolchain-funcs

PACKAGEAUTHOR="irungentoo"
PACKAGENAME="filter_audio"

DESCRIPTION="Lightweight audio filtering library made from webrtc code."
HOMEPAGE="https://github.com/${PACKAGEAUTHOR}/${PACKAGENAME}"

if [[ ${PV} = 9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/${PACKAGEAUTHOR}/${PACKAGENAME}.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/${PACKAGEAUTHOR}/${PACKAGENAME}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="BSD"
SLOT="0"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_prepare() {
	epatch_user
}

src_compile() {
	emake CC="$(tc-getCC)"
}

src_install() {
	emake DESTDIR="${D}" PREFIX="/usr" LIBDIR="$(get_libdir)" install
}
