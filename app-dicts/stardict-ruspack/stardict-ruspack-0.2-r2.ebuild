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

DEPEND="|| ( app-arch/p7zip app-arch/unrar app-arch/rar )"

src_unpack() {
	mkdir -p "${S}"
	if command -v 7z >/dev/null 2>&1; then
		7z e "${DISTDIR}/stardict-dicts.exe" -o"${S}" || die "Unable to unpack stardict-dicts.exe"
	elif command -v /usr/bin/unrar >/dev/null 2>&1; then
		/usr/bin/unrar e "${DISTDIR}/stardict-dicts.exe" "${S}"
	elif command -v /opt/bin/unrar >/dev/null 2>&1; then
		/opt/bin/unrar e "${DISTDIR}/stardict-dicts.exe" "${S}"
	fi
	cd "${S}"
}

src_install() {
	dodir /usr/share/stardict/dic
	cp -R "${S}/" "${D}""/usr/share/stardict/dic/" || die "Install failed!"
}
