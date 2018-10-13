# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-wm/emerald/emerald-0.8.8.ebuild,v 1.5 2013/04/20 10:29:43 pinkbyte Exp $

EAPI="5"

inherit autotools eutils flag-o-matic

DESCRIPTION="Emerald Window Decorator"
HOMEPAGE="http://blog.northfield.ws/
	http://blog.northfield.ws/"
SRC_URI="http://www.northfield.ws/projects/compiz/releases/${PV}/${P}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
IUSE="+gtk2 gtk3"

PDEPEND="~x11-themes/emerald-themes-${PV}"

RDEPEND="
	=x11-wm/compiz-${PV}
	gtk2? (
		>=x11-libs/gtk+-2.10.0:2
		>=x11-libs/libwnck-2.18.3:1
	)
	gtk3? (
		x11-libs/gtk+:3
		x11-libs/libwnck:3
	)
"

DEPEND="${RDEPEND}
	>=dev-util/intltool-0.35
	virtual/pkgconfig
	>=sys-devel/gettext-0.15
"

DOCS=( AUTHORS INSTALL NEWS README.md TODO )

src_prepare() {
	# fix build with gtk+-2.22 - bug 341143
	sed -i -e '/#define G[DT]K_DISABLE_DEPRECATED/s:^://:' \
		include/emerald.h || die
	# Fix underlinking
	append-libs -ldl -lm

	epatch_user

	eautoreconf || die "eautoreconf failed"
}

src_configure() {
	local myconf
	if use gtk2 ; then
		myconf="${myconf} --with-gtk=2.0"
	elif use gtk3 ; then
		myconf="${myconf} --with-gtk=3.0"
	fi

	econf \
		--disable-static \
		--enable-fast-install \
		--disable-mime-update \
		--with-gnu-ld \
		${myconf}
}

src_install() {
	default
	prune_libtool_files
}
