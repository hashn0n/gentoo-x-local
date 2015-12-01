# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit xfconf

DESCRIPTION="Panel plugin to support GNOME applets"
HOMEPAGE="http://goodies.xfce.org/projects/panel-plugins/xfce4-xfapplet-plugin"

EGIT_REPO_URI="git://git.xfce.org/panel-plugins/${MY_PN:-${PN}}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE="debug"

RDEPEND=">=x11-libs/gtk+-2.6:2
	>=xfce-base/xfce4-panel-4.3.20
	>=xfce-base/libxfcegui4-4.2
	>=gnome-base/orbit-2.12.5
	|| ( gnome-base/gnome-panel[bonobo] <gnome-base/gnome-panel-2.32 )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	dev-util/intltool"

pkg_setup() {
	XFCONF=(
		--docdir="${EPREFIX}"/usr/share/doc/${PF}
		--disable-dependency-tracking
		--disable-static
		$(xfconf_use_debug)
		--with-html-dir="${EPREFIX}"/usr/share/doc/${PF}/html
		)
	DOCS="AUTHORS ChangeLog NEWS README"
}
