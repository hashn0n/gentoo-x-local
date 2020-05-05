# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

inherit eutils autotools

PACKAGEAUTHOR="bg111"

DESCRIPTION="Asterisk Huawei 3G Dongle Channel Driver."
HOMEPAGE="https://github.com/${PACKAGEAUTHOR}/${PN}"

if [[ ${PV} = 9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/${PACKAGEAUTHOR}/${PN}.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/${PACKAGEAUTHOR}/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-3"
SLOT="0"
IUSE=""

RDEPEND=">=net-misc/asterisk-11.0"
DEPEND="${RDEPEND}"

AT_NOEAUTOMAKE=yes

src_prepare() {
	cd ${S}
	epatch ${FILESDIR}/${PN/*-/}.patch
	eaclocal
	eautoconf
	automake -a
}

src_install() {
	insinto /usr/$(get_libdir)/asterisk/modules
	doins "${PN/*-/}.so"
	insinto /etc/asterisk
	doins etc/dongle.conf
	newdoc README.txt README
	newdoc LICENSE.txt LICENSE
	newdoc etc/extensions.conf extensions.conf.${PN/*-/}
}
