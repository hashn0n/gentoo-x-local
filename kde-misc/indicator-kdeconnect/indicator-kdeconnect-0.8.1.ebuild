# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit cmake-utils gnome2-utils
PACKAGEAUTHOR="Bajoja"

DESCRIPTION="Adds systray and AppIndicator indicator for KDE-Connect"
HOMEPAGE="https://github.com/${PACKAGEAUTHOR}/${PN}"
if [[ ${PV} == *9999* ]]; then
	inherit git-2
	EGIT_REPO_URI="
		git://github.com/${PACKAGEAUTHOR}/${PN}.git
		https://github.com/${PACKAGEAUTHOR}/${PN}.git
	"
	RESTRICT="mirror"
	SRC_URI=""
else
	KEYWORDS="amd64 x86"
	SRC_URI="https://github.com/${PACKAGEAUTHOR}/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
fi

LICENSE="LGPL-2.1"
SLOT="0"
IUSE=""

DEPEND="
	dev-lang/vala
	kde-misc/kdeconnect:5
	dev-python/oauthlib
	dev-libs/libappindicator:3[introspection]
"

src_prepare() {
	epatch "${FILESDIR}"/remove_call_for_gtk-update-icon-cache.patch
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
