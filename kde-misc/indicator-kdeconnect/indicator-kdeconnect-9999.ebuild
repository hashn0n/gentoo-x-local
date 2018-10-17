# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils vala gnome2
PACKAGEAUTHOR="Bajoja"

DESCRIPTION="Adds systray and AppIndicator indicator for KDE-Connect"
HOMEPAGE="https://github.com/${PACKAGEAUTHOR}/${PN}"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="
		git://github.com/${PACKAGEAUTHOR}/${PN}
		https://github.com/${PACKAGEAUTHOR}/${PN}
	"
	RESTRICT="mirror"
	KEYWORDS="~amd64 ~x86"
	SRC_URI=""
else
	KEYWORDS="amd64 x86"
	SRC_URI="https://github.com/${PACKAGEAUTHOR}/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
fi

LICENSE="LGPL-2.1"
SLOT="0"
IUSE=""

RDEPEND="$(vala_depend)
	dev-libs/libappindicator:3[introspection]
	dev-python/requests-oauthlib
	kde-misc/kdeconnect:5
	x11-libs/gtk+:3"

DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_prepare() {
	vala_src_prepare
	sed -i -e '28,35d' "${S}/data/CMakeLists.txt"
	eapply_user
}

src_configure() {
	local mycmakeargs=(
		-DVALA_EXECUTABLE="${VALAC}"
		-DGSETTINGS_COMPILE=NO
	)
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

src_install() {
	cmake-utils_src_install
}

pkg_preinst() {
	gnome2_pkg_preinst
}

pkg_postinst() {
	gnome2_pkg_postinst
}

pkg_postrm() {
	gnome2_pkg_postrm
}
