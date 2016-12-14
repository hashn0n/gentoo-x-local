# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
inherit gnome2-utils distutils eutils python

PYTHON_DEPEND="2:2.7"
RESTRICT_PYTHON_ABIS="3.*"
PACKAGEAUTHOR="M7S"

DESCRIPTION="Panel applet (Gnome2, AWN, Mate, XFCE4) and stand alone dock with groupping and group manipulation."
HOMEPAGE="https://github.com/${PACKAGEAUTHOR}/${PN}"
if [[ ${PV} == *9999* ]]; then
	inherit git-2
	EGIT_REPO_URI="https://github.com/${PACKAGEAUTHOR}/${PN}.git"
	RESTRICT="mirror"
	SRC_URI=""
else
	KEYWORDS="~amd64 ~x86"
	SRC_URI="https://github.com/${PACKAGEAUTHOR}/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
fi

LICENSE="GPL3"
SLOT="0"
IUSE="awn xfce dockmanager gnome"

RDEPEND="
	dev-python/pygobject
	dev-python/pygtk
	dev-python/pyxdg
	dev-python/gconf-python
	|| ( dev-python/pillow dev-python/imaging )
	dev-python/libwnck-python
	dev-python/python-xlib
	dev-python/dbus-python
	dev-libs/keybinder[python]"
DEPEND="
	awn? ( gnome-extra/avant-window-navigator )
	xfce? ( >=xfce-extra/xfce4-dockbarx-plugin-0.2 )
	dockmanager? ( x11-misc/dockmanager )
	gnome? ( =gnome-base/gnome-menus-2.30.5-r1 =gnome-base/gnome-panel-2.32.1-r3 )"

pkg_setup() {
	python_set_active_version 2
	python_pkg_setup
}

pkg_preinst() {
	if ! use awn ; then
		rm -rf ${ROOT}/usr/share/avant-window-navigator/applets/DockBarX/
		rm -f ${ROOT}/usr/share/avant-window-navigator/applets/DockBarX.desktop
	else
		rm -rf ${ROOT}/usr/share/avant-window-navigator/applets/DockBarX/
		rm -f ${ROOT}/usr/share/avant-window-navigator/applets/DockBarX.desktop
		dodir /usr/share/avant-window-navigator/applets/DockBarX/
		cp ${S}/AWN/DockBarX.desktop ${D}/usr/share/avant-window-navigator/applets/
		cp ${S}/AWN/DockBarX/DockBarX.py ${D}/usr/share/avant-window-navigator/applets/DockBarX/
		fperms -x /usr/share/avant-window-navigator/applets/DockBarX.desktop
	fi
}

pkg_postinst() {
	sed -i "s:s = im.tostring('raw', 'BGRA'):s = im.tobytes('raw', 'BGRA'):" /usr/lib/python2.7/site-packages/dockbarx/iconfactory.py
	gtk-update-icon-cache
}

pkg_postrm() {
	gtk-update-icon-cache
}
