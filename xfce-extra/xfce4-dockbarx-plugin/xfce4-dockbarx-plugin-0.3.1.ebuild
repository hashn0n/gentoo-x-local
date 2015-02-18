# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit waf-utils vala eutils gnome2-utils

PYTHON_DEPEND="2:2.7"
RESTRICT_PYTHON_ABIS="3.*"

DESCRIPTION="Xfce4 integration packadge for DockBarX."
HOMEPAGE="http://xfce-look.org/content/show.php/xfce4-dockbarx-plugin+%2B+Mouse+DBX+Theme?content=157865
	https://github.com/TiZ-EX1/xfce4-dockbarx-plugin"

PACKAGEAUTHOR="TiZ-EX1"
if [[ ${PV} == *9999* ]]; then
	inherit git-2
	EGIT_REPO_URI="git://github.com/${PACKAGEAUTHOR}/${PN}.git"
	RESTRICT="mirror"
	SRC_URI=""
else
	KEYWORDS="~amd64 ~x86"
	SRC_URI="https://github.com/${PACKAGEAUTHOR}/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
fi

LICENSE="GPL3"
SLOT="0"

RDEPEND="dev-libs/glib:2
	x11-libs/gtk+:2
	>=xfce-base/xfce4-panel-4.8
	>=xfce-extra/xfce4-vala-4.8
"
DEPEND=""

export VALAC="$(type -P valac-0.20)"

pkg_postinst() {
	gtk-update-icon-cache
}

pkg_postrm() {
	gtk-update-icon-cache
}
