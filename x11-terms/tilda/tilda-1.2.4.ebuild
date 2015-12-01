# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-terms/tilda/tilda-1.1.8.ebuild $

EAPI="5"

inherit eutils gnome2 autotools
PACKAGEAUTHOR="lanoxx"
#PACKAGEAUTHOR="pik"
DESCRIPTION="A drop down terminal, similar to the consoles found in first person shooters"

HOMEPAGE="https://github.com/${PACKAGEAUTHOR}/${PN}"

if [[ ${PV} == *9999* ]]; then
	inherit git-2
	KEYWORDS="~amd64 ~ppc ~x86 ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux"
	EGIT_BRANCH="vteport2"
	EGIT_REPO_URI="https://github.com/${PACKAGEAUTHOR}/${PN}.git"
	SRC_URI=""
else
	KEYWORDS="amd64 ppc x86 ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux"
	SRC_URI="https://github.com/${PACKAGEAUTHOR}/${PN}/archive/${P}.tar.gz"
fi

LICENSE="GPL-2"
SLOT="0"
IUSE=""

RDEPEND="
	x11-libs/vte:2.90
	>=dev-libs/glib-2.30:2
	x11-libs/gtk+:3
	dev-libs/confuse"
DEPEND="
	${RDEPEND}
	virtual/pkgconfig"

S=${WORKDIR}"/"${PN}-${P}

src_configure() {
	eautoreconf || die
	econf || die
}
