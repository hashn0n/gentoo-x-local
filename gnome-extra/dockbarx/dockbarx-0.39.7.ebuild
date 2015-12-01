# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit distutils eutils

DESCRIPTION="Gnome2 taskbar applet, AWN Applet, Mate taskbar applet and stand alone dock with groupping and group manipulation."
HOMEPAGE="http://launchpad.net/dockbar/dockbarx"
SRC_URI="http://launchpad.net/dockbar/${PN}/x.${PV}/+download/${P/-/_}.tar.gz"

SLOT=0
LICENSE="GPL-3"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	dev-python/pygobject
	dev-python/pygtk
	dev-python/gconf-python
	dev-python/imaging
	dev-python/libgnome-python
	dev-python/gnome-applets-python
	dev-python/gnome-vfs-python
	dev-python/libwnck-python
	dev-python/keybinder"
DEPEND=""

S="${WORKDIR}/${P/-/_}"
