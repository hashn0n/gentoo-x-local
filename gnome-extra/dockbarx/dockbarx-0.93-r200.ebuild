# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=7

PYTHON_COMPAT=( python2_7 )

PACKAGEAUTHOR="M7S"

inherit xdg-utils gnome2-utils distutils-r1 eutils
DISTUTILS_OPTIONAL=1

DESCRIPTION="Panel applet (GTK+2, Mate, XFCE4) and stand alone dock with groupping and group manipulation."
HOMEPAGE="https://github.com/${PACKAGEAUTHOR}/${PN}"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/${PACKAGEAUTHOR}/${PN}"
	RESTRICT="mirror"
	SRC_URI=""
else
	KEYWORDS="amd64 x86"
	SRC_URI="https://github.com/${PACKAGEAUTHOR}/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
fi

LICENSE="GPL3"
SLOT="0"
IUSE="xfce dockmanager mate"

RDEPEND="
	dev-python/pygtk:2[${PYTHON_USEDEP}]
	dev-python/pyxdg[${PYTHON_USEDEP}]
	dev-python/polib[${PYTHON_USEDEP}]
	dev-python/pygobject:2[${PYTHON_USEDEP}]
	dev-python/gconf-python:2[${PYTHON_USEDEP}]
	dev-libs/gobject-introspection[cairo]
	dev-libs/keybinder:0[python,introspection]
	dev-python/pillow[${PYTHON_USEDEP}]
	dev-python/libwnck-python[${PYTHON_USEDEP}]
	dev-python/python-xlib[${PYTHON_USEDEP}]
	dev-python/dbus-python[${PYTHON_USEDEP}]
	${PYTHON_DEPS}
"

DEPEND="
	xfce? ( >=xfce-extra/xfce4-dockbarx-plugin-0.2 )
	dockmanager? ( x11-misc/dockmanager )
	mate? ( mate-base/mate-panel )
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
	gnome2_gconf_install
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_icon_cache_update
	gnome2_gconf_uninstall
	gnome2_schemas_update
}
