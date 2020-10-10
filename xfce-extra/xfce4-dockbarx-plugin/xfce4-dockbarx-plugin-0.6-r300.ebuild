# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

PYTHON_COMPAT=( python3_{6..9} )
PYTHON_REQ_USE="threads(+)"
inherit waf-utils vala python-r1 eutils gnome2-utils xdg-utils xdg

PACKAGEAUTHOR="M7S"

DESCRIPTION="Xfce4 integration packadge for DockBarX. Gtk3 port (compatible with DockbarX 1.0-beta)."
HOMEPAGE="http://xfce-look.org/content/show.php/xfce4-dockbarx-plugin+%2B+Mouse+DBX+Theme?content=157865
	https://github.com/${PACKAGEAUTHOR}/xfce4-dockbarx-plugin/tree/pygi-python3"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_BRANCH="pygi-python3"
	EGIT_REPO_URI="
		https://github.com/${PACKAGEAUTHOR}/${PN}
	"
	SRC_URI=""
else
	KEYWORDS="~amd64 ~x86"
#	SRC_URI="https://codeload.github.com/${PACKAGEAUTHOR}/${PN}/zip/pygi-python3"
#	SRC_URI="https://github.com/${PACKAGEAUTHOR}/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	inherit git-r3
	EGIT_BRANCH="pygi-python3"
	EGIT_REPO_URI="
		https://github.com/${PACKAGEAUTHOR}/${PN}
	"
	RESTRICT="mirror"
	SRC_URI=""
	EGIT_COMMIT="f7585b53792fc9945be6a8f95a08aed8663b1b04"
fi

LICENSE="MIT"
SLOT="3"

RDEPEND="
	dev-libs/glib:2
	x11-libs/gtk+:3
	>=xfce-base/xfce4-panel-4.12
	>=xfce-base/xfconf-4.12
	>=xfce-extra/xfce4-vala-4.10
	>=gnome-extra/dockbarx-1.0b:3
"
DEPEND=""

export VALAC="$(type -P valac-0.36)"
export VALAC="$(type -P valac-0.40)"
export VALAC="$(type -P valac-0.42)"
export VALAC="$(type -P valac-0.44)"
export VALAC="$(type -P valac-0.46)"
export VALAC="$(type -P valac-0.48)"



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
	xdg_pkg_postinst
	gnome2_gconf_install
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_icon_cache_update
	xdg_pkg_postrm
	gnome2_gconf_uninstall
	gnome2_schemas_update
}
