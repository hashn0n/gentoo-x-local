# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
PYTHON_COMPAT=( python2_7 )
PACKAGEAUTHOR="M7S"
DISTUTILS_OPTIONAL=1

inherit gnome2-utils distutils-r1 eutils

DESCRIPTION="Panel applet (Gnome2, AWN, Mate, XFCE4) and stand alone dock with groupping and group manipulation."
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
	KEYWORDS="~amd64 ~x86"
	SRC_URI="https://github.com/${PACKAGEAUTHOR}/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
fi

LICENSE="GPL3"
SLOT="0"
IUSE="awn xfce dockmanager gnome"

RDEPEND="
	${PYTHON_DEPS}
	dev-python/pygobject:2[${PYTHON_USEDEP}]
	dev-python/pygtk:2[${PYTHON_USEDEP}]
	dev-python/pyxdg[${PYTHON_USEDEP}]
	dev-python/gconf-python:2[${PYTHON_USEDEP}]
	|| ( dev-python/pillow[${PYTHON_USEDEP}] dev-python/imaging[${PYTHON_USEDEP}] )
	dev-python/libwnck-python[${PYTHON_USEDEP}]
	dev-python/python-xlib[${PYTHON_USEDEP}]
	dev-python/dbus-python[${PYTHON_USEDEP}]
	dev-libs/keybinder[python]
"

DEPEND="
	awn? ( gnome-extra/avant-window-navigator )
	xfce? ( >=xfce-extra/xfce4-dockbarx-plugin-0.2 )
	dockmanager? ( x11-misc/dockmanager )
	gnome? ( =gnome-base/gnome-menus-2.30.5-r1 =gnome-base/gnome-panel-2.32.1-r3 )"

src_prepare() {
	distutils-r1_src_prepare
}

src_install() {
	distutils-r1_src_install
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
	gnome2_icon_savelist
}

pkg_postinst() {
	sed -i "s:s = im.tostring('raw', 'BGRA'):s = im.tobytes('raw', 'BGRA'):" /usr/lib/python2.7/site-packages/dockbarx/iconfactory.py
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
