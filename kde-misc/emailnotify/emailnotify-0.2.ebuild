# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit cmake-utils

KLV=75194
PKG="${P/-/_v}"
S="${WORKDIR}/${PN}"

DESCRIPTION="Plasmoid Mailbox checker."
HOMEPAGE="http://www.kde-look.org/content/show.php?content=${KLV}"
SRC_URI="http://emailnotify.googlecode.com/files/${PKG}.tar.gz"

LICENSE="GPL"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
>=kde-base/kdelibs-4.0.0
|| ( >=kde-base/plasma-runtime-4.0.0 >=kde-base/kdebase-4.0.0 )"
RDEPEND="${DEPEND}"
