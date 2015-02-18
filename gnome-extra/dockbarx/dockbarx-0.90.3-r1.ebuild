# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

SUPPORT_PYTHON_ABIS="1"
PYTHON_DEPEND="2:2.6"
RESTRICT_PYTHON_ABIS="2.4 3.*"

inherit distutils eutils gnome2-utils

DESCRIPTION="Gnome2 taskbar applet, AWN Applet, Mate taskbar applet and stand alone dock with groupping and group manipulation."
HOMEPAGE="http://launchpad.net/dockbar/dockbarx
	xfce? https://plus.google.com/110582468951930692841/posts/KogHZaufjc8
	xfce? http://xfce-look.org/content/show.php/xfce4-dockbarx-plugin+%2B+Mouse+DBX+Theme?content=157865"
SRC_URI="http://launchpad.net/dockbar/${PN}/${PV}/+download/${P/-/_}.tar.gz
	xfce? ( http://xfce-look.org/CONTENT/content-files/157865-xfce4-dockbarx-plugin-0.2.tar.bz2 )"

SLOT=0
LICENSE="GPL-3"
KEYWORDS="~amd64 ~x86"
IUSE="awn xfce"

RDEPEND="
	dev-python/pygobject
	dev-python/pygtk
	dev-python/pyxdg
	dev-python/gconf-python
	dev-python/imaging
	dev-python/libwnck-python
	dev-python/python-xlib
	dev-libs/keybinder[python]"
DEPEND="awn? ( gnome-extra/avant-window-navigator )
	xfce? ( dev-libs/glib:2
		x11-libs/gtk+:2
		>=xfce-base/xfce4-panel-4.8
		>=xfce-extra/xfce4-vala-4.8 )"

S="${WORKDIR}/${P/-/_}"

post_src_unpack() {
    epatch_user
}

post_src_compile() {
	if use xfce ; then
		PATH=${S}:${PATH}
		cd ${S}/../xfce4-dockbarx-plugin-0.2/
		./waf configure --prefix=/usr
		./waf build
		cd ${S}
	fi
}

pkg_preinst() {
	rm -rf ${ROOT}/usr/share/avant-window-navigator/applets/DockBarX/
	rm -f ${ROOT}/usr/share/avant-window-navigator/applets/DockBarX.desktop
	if use awn ; then
		dodir /usr/share/avant-window-navigator/applets/DockBarX/
		cp ${S}/AWN/DockBarX.desktop ${D}/usr/share/avant-window-navigator/applets/
		cp ${S}/AWN/DockBarX/DockBarX.py ${D}/usr/share/avant-window-navigator/applets/DockBarX/
		fperms -x /usr/share/avant-window-navigator/applets/DockBarX.desktop
	fi
	if use xfce ; then
		cd ${S}/../xfce4-dockbarx-plugin-0.2/
		./waf install
		cd ${S}
	fi
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
