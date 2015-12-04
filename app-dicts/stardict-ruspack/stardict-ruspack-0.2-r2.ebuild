# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

DESCRIPTION="Collection of dicts for stardict."
HOMEPAGE="http://gnome.msiu.ru/stardict.php"
SRC_URI="ftp://ftp.msiu.ru/education/FSF-Windows/stardict/dicts/stardict-dicts.exe"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="app-text/stardict
		!app-dicts/stardict-freedict-eng-rus"

DEPEND="app-arch/p7zip"

src_install() {
	dodir /usr/share/stardict/dic
	7z e "${DISTDIR}/stardict-dicts.exe" -o"${D}/usr/share/stardict/dic/"
}
