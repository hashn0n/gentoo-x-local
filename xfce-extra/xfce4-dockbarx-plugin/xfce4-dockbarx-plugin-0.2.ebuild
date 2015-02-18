# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

inherit waf-utils vala eutils gnome2-utils

DESCRIPTION="Xfce4 integration packadge for DockBarX."
HOMEPAGE="https://plus.google.com/110582468951930692841/posts/KogHZaufjc8
	http://xfce-look.org/content/show.php/xfce4-dockbarx-plugin+%2B+Mouse+DBX+Theme?content=157865"
SRC_URI="http://xfce-look.org/CONTENT/content-files/157865-xfce4-dockbarx-plugin-0.2.tar.bz2"

SLOT=0
LICENSE="GPL-3"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="dev-libs/glib:2
	x11-libs/gtk+:2
	>=xfce-base/xfce4-panel-4.8
	>=xfce-extra/xfce4-vala-4.8
"
DEPEND=""

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
