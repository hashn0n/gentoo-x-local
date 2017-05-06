# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils git-r3

PACKAGEAUTHOR="davidgfnet"

DESCRIPTION="Whatsapp plugin for libpurple (Pidgin)"
HOMEPAGE="http://davidgf.net/page/39/
	https://github.com/${PACKAGEAUTHOR}/${PN}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

EGIT_REPO_URI="
		git://github.com/${PACKAGEAUTHOR}/${PN}.git
		https://github.com/${PACKAGEAUTHOR}/${PN}.git
"

DEPEND="net-im/pidgin
>=media-libs/freeimage-3
"
RDEPEND="${DEPEND}"
