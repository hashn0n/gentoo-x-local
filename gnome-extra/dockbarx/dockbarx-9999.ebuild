# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=7

PYTHON_COMPAT=( python3_{6..9} )
inherit xdg-utils distutils-r1 eutils xdg

PACKAGEAUTHOR="M7S"
EGIT_BRANCH="pygi-python3"

DESCRIPTION="Panel applet (GTK+3, Mate, XFCE4) and stand alone dock with groupping and group manipulation."
HOMEPAGE="
	https://github.com/${PACKAGEAUTHOR}/${PN}/tree/${EGIT_BRANCH}
"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="
		https://github.com/${PACKAGEAUTHOR}/${PN}
	"
	SRC_URI=""
else
	KEYWORDS="~amd64 ~x86"
#	SRC_URI="https://github.com/${PACKAGEAUTHOR}/${PN}/archive/${PV}-${EGIT_BRANCH}.tar.gz -> ${P}-${EGIT_BRANCH}.tar.gz"
	SRC_URI=""
	inherit git-r3
	EGIT_REPO_URI="
		https://github.com/${PACKAGEAUTHOR}/${PN}
	"
	EGIT_COMMIT="4a5b382f03402e58cbbaaeb2ee3be4fbbb795aba"
fi

LICENSE="GPL3"
SLOT="3"
IUSE="xfce mate battery"

RDEPEND="
	dev-python/pygobject:3[${PYTHON_USEDEP}]
	dev-libs/gobject-introspection
	dev-libs/keybinder:3[introspection]
	x11-libs/pango[introspection]
	dev-python/pycairo[${PYTHON_USEDEP}]
	dev-python/pillow[${PYTHON_USEDEP}]
	x11-libs/libwnck:3[introspection]
	dev-python/python-xlib[${PYTHON_USEDEP}]
	dev-python/polib[${PYTHON_USEDEP}]
	dev-python/pyxdg[${PYTHON_USEDEP}]
	dev-python/dbus-python[${PYTHON_USEDEP}]
"

DEPEND="
	xfce? ( xfce-extra/xfce4-dockbarx-plugin[${PYTHON_USEDEP}] )
	mate? ( mate-base/mate-panel )
	battery? ( dev-python/pyudev[${PYTHON_USEDEP}] )
	${RDEPEND}
"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

src_prepare() {
	eapply_user
	distutils-r1_src_prepare
}

src_compile() {
	distutils-r1_src_compile
}

src_install() {
	distutils-r1_src_install
}

pkg_preinst() {
	if use mate ; then
		dodir /usr/bin/
		dodir /usr/share/dbus-1/services/
		dodir /usr/share/mate-panel/applets/
		dodir /usr/share/mate-panel/ui/
		rm -f ${ED}/usr/bin/dockbarx_mate_applet
		rm -f ${ED}/usr/share/dbus-1/services/org.mate.panel.applet.DockbarXAppletFactory.service
		rm -f ${ED}/usr/share/mate-panel/applets/org.mate.panel.DockbarX.mate-panel-applet
		rm -f ${ED}/usr/share/mate-panel/ui/dockbarx-applet-menu.xml
		cp ${S}/dockbarx_mate_applet ${ED}/usr/bin/
		cp ${S}/org.mate.panel.applet.DockbarXAppletFactory.service ${ED}/usr/share/dbus-1/services/
		cp ${S}/org.mate.panel.DockbarX.mate-panel-applet ${ED}/usr/share/mate-panel/applets/
		cp ${S}/dockbarx-applet-menu.xml ${ED}/usr/share/mate-panel/ui/
	else
		rm -f ${ED}/usr/bin/dockbarx_mate_applet
		rm -f ${ED}/usr/share/dbus-1/services/org.mate.panel.applet.DockbarXAppletFactory.service
		rm -f ${ED}/usr/share/mate-panel/applets/org.mate.panel.DockbarX.mate-panel-applet
		rm -f ${ED}/usr/share/mate-panel/ui/dockbarx-applet-menu.xml
	fi
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
