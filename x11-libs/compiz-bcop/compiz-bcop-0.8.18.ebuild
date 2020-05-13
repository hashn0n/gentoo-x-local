# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools

PACKAGEAUTHOR="compiz"

DESCRIPTION="Compiz Option code Generator"
HOMEPAGE="https://gitlab.com/${PACKAGEAUTHOR}/${PN}"

if [[ ${PV} = 9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://gitlab.com/${PACKAGEAUTHOR}/${PN}.git"
	KEYWORDS=""
else
	SRC_URI="https://gitlab.com/${PACKAGEAUTHOR}/${PN}/-/archive/v${PV}/${PN}-v${PV}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-2+"
SLOT="0"

RDEPEND="dev-libs/libxslt"

DEPEND="
	virtual/pkgconfig
	${RDEPEND}
"

S="${WORKDIR}/${PN}-v${PV}"

src_prepare() {
	default
	eautoreconf
}
