# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=7

inherit eutils

PACKAGEAUTHOR="davidgfnet"

DESCRIPTION="Whatsapp plugin for libpurple (Pidgin)"
HOMEPAGE="http://davidgf.net/page/39/
	https://github.com/${PACKAGEAUTHOR}/${PN}"

if [[ ${PV} = 9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/${PACKAGEAUTHOR}/${PN}.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/${PACKAGEAUTHOR}/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-2"
SLOT="0"
IUSE=""

DEPEND="
	net-im/pidgin
	>=media-libs/freeimage-3
"
RDEPEND="${DEPEND}"
