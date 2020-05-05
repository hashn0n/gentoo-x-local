# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools

PACKAGEAUTHOR="compiz-reloaded"

DESCRIPTION="CompizConfig plugin required for compizconfig-settings-manager"
HOMEPAGE="https://github.com/${PACKAGEAUTHOR}/${PN}"

if [[ ${PV} = 9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/${PACKAGEAUTHOR}/${PN}.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/${PACKAGEAUTHOR}/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-2+"
SLOT="0"

RDEPEND="
	dev-libs/libxml2
	dev-libs/protobuf
	x11-libs/libX11
	>=x11-wm/compiz-${PV}
	<x11-wm/compiz-0.9
"
DEPEND="
	>=dev-util/intltool-0.41
	virtual/pkgconfig
	x11-base/xorg-proto
	${RDEPEND}
"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf \
		--enable-fast-install \
		--disable-static
}

src_install() {
	default
	find "${D}" -name '*.la' -delete || die
}
