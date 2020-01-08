# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6
PYTHON_COMPAT=( python2_7 )
PYTHON_REQ_USE="threads(+)"

inherit waf-utils python-r1 vala eutils gnome2-utils xdg-utils

PACKAGEAUTHOR="M7S"

DESCRIPTION="Xfce4 integration packadge for DockBarX."
HOMEPAGE="http://xfce-look.org/content/show.php/xfce4-dockbarx-plugin+%2B+Mouse+DBX+Theme?content=157865
	https://github.com/${PACKAGEAUTHOR}/xfce4-dockbarx-plugin"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="
		https://github.com/${PACKAGEAUTHOR}/${PN}
	"
	RESTRICT="mirror"
	SRC_URI=""
else
	KEYWORDS="~amd64 ~x86"
#	SRC_URI="https://github.com/${PACKAGEAUTHOR}/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	inherit git-r3
	EGIT_REPO_URI="https://github.com/${PACKAGEAUTHOR}/${PN}"
	RESTRICT="mirror"
	SRC_URI=""
	EGIT_COMMIT="9e2818fab2dfcf7428715123d5427b7a7d14baed"
	EGIT_BRANCH="pygi-python3"
fi

LICENSE="MIT"
SLOT="3"

RDEPEND="
	dev-libs/glib:2
	x11-libs/gtk+:2
	>=xfce-base/xfce4-panel-4.10
	>=xfce-extra/xfce4-vala-4.10
"
DEPEND=""

export VALAC="$(type -P valac-0.36)"
export VALAC="$(type -P valac-0.40)"
export VALAC="$(type -P valac-0.42)"
export VALAC="$(type -P valac-0.44)"
export VALAC="$(type -P valac-0.46)"

src_prepare() {
	eapply_user
}

src_configure() {
	python_setup
	waf-utils_src_configure
}

pkg_preinst() {
	dodir /usr/$(get_libdir)/xfce4/panel/plugins/
	mv ${S}/build/libdockbarx.so ${ED}/usr/$(get_libdir)/xfce4/panel/plugins/
}

pkg_postinst() {
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_icon_cache_update
}
