# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/livestreamer/livestreamer-1.10.2.ebuild,v 1.1 2014/11/15 12:40:38 hwoarang Exp $

EAPI="5"

PYTHON_COMPAT=( python{2_7,3_3,3_4} )
PACKAGEAUTHOR="chrippa"
inherit distutils-r1

DESCRIPTION="CLI tool that pipes video streams from services like twitch.tv into a video player"
HOMEPAGE="https://github.com/${PACKAGEAUTHOR}/${PN}"

if [[ ${PV} == *9999* ]]; then
	inherit git-2
	EGIT_REPO_URI="git://github.com/${PACKAGEAUTHOR}/${PN}.git"
	RESTRICT="mirror"
	KEYWORDS="amd64 mips x86"
	SRC_URI=""
else
	KEYWORDS="~amd64 ~mips ~x86"
	SRC_URI="https://github.com/${PACKAGEAUTHOR}/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
fi

LICENSE="Apache-2.0 BSD-2 MIT-with-advertising"
SLOT="0"

RDEPEND="dev-python/pycrypto[${PYTHON_USEDEP}]
	>=dev-python/requests-1.0[${PYTHON_USEDEP}]
	virtual/python-futures[${PYTHON_USEDEP}]
	virtual/python-singledispatch[${PYTHON_USEDEP}]
	>media-video/rtmpdump-2.4"
DEPEND="${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]"

src_prepare() {
	epatch "${FILESDIR}"/livestreamer_youtube-py.patch
}
