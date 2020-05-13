# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools

PACKAGEAUTHOR="compiz"

DESCRIPTION="Emerald window decorator themes"
HOMEPAGE="https://gitlab.com/${PACKAGEAUTHOR}/${PN}"

if [[ ${PV} = 9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://gitlab.com/${PACKAGEAUTHOR}/${PN}.git"
	KEYWORDS=""
else
	SRC_URI="https://gitlab.com/${PACKAGEAUTHOR}/${PN}/-/archive/v${PV}/${PN}-v${PV}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-2+ GPL-3+"
SLOT="0"

RDEPEND="
	>=x11-wm/emerald-${PV}
	<x11-wm/emerald-0.9
"

S="${WORKDIR}/${PN}-v${PV}"

src_prepare() {
	default
	eautoreconf
}
