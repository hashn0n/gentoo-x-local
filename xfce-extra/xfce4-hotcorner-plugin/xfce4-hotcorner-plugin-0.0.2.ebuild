 # Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-eyes-plugin/xfce4-eyes-plugin-4.4.4.ebuild,v 1.1 2015/03/28 20:46:39 mgorny Exp $

EAPI=5
inherit xfconf
inherit cmake-utils

DESCRIPTION="A panel plug-in which adds classic eyes to your every step"
HOMEPAGE="http://goodies.xfce.org/projects/panel-plugins/xfce4-eyes-plugin"
#SRC_URI="http:/qqqqq.com/${PN}/${PV}/${P}.tar.bz2"
SRC_URI="https://github.com/brianhsu/${PN}/releases/download/${PV}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux"
IUSE="debug"

RDEPEND=">=x11-libs/libwnck-3.14.0:=
   >=xfce-base/libxfce4util-4.10:=
   >=xfce-base/xfce4-panel-4.10:="
DEPEND="${RDEPEND}
   dev-util/intltool
   virtual/pkgconfig"

pkg_setup() {
   XFCONF=(
      $(xfconf_use_debug)
      )

   DOCS=( AUTHORS README.md )
} 