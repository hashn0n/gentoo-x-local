# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python2_7 )
PYTHON_REQ_USE="threads(+)"

inherit waf-utils python-r1 vala eutils gnome2-utils

PACKAGEAUTHOR="TiZ-EX1"

DESCRIPTION="Xfce4 integration packadge for DockBarX."
HOMEPAGE="http://xfce-look.org/content/show.php/xfce4-dockbarx-plugin+%2B+Mouse+DBX+Theme?content=157865
	https://github.com/${PACKAGEAUTHOR}/xfce4-dockbarx-plugin"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="
		git://github.com/${PACKAGEAUTHOR}/${PN}
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
	EGIT_COMMIT="a2dcb6694866b75e70f23544474cec17af42de22"
fi

LICENSE="GPL3"
SLOT="0"

RDEPEND="dev-libs/glib:2
	x11-libs/gtk+:2
	>=xfce-base/xfce4-panel-4.8
	>=xfce-extra/xfce4-vala-4.8
"
DEPEND=""

export VALAC="$(type -P valac-0.22)"
export VALAC="$(type -P valac-0.26)"
export VALAC="$(type -P valac-0.28)"
export VALAC="$(type -P valac-0.30)"

src_configure() {
	python_setup
	waf-utils_src_configure
}

pkg_postinst() {
	gtk-update-icon-cache
}

pkg_postrm() {
	gtk-update-icon-cache
}
