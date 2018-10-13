# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-wm/compiz/compiz-0.8.8-r3.ebuild,v 1.1 2013/04/09 07:26:11 pinkbyte Exp $

EAPI="5"

inherit autotools eutils

DESCRIPTION="OpenGL window and compositing manager"
HOMEPAGE="https://github.com/compiz-reloaded/${PN%%-reloaded}"
SRC_URI="https://github.com/compiz-reloaded/${PN%%-reloaded}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2 LGPL-2.1 MIT"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
IUSE="+cairo dbus fuse mate +gtk2 gtk3 +svg"

COMMONDEPEND="
	>=dev-libs/glib-2.32
	dev-libs/libxml2
	dev-libs/libxslt
	media-libs/libpng:0=
	>=media-libs/mesa-6.5.1-r1
	>=x11-base/xorg-server-1.1.1-r1
	>=x11-libs/libX11-1.4
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXinerama
	x11-libs/libXrandr
	x11-libs/libICE
	x11-libs/libSM
	>=x11-libs/libXrender-0.9.3
	>=x11-libs/startup-notification-0.7
	virtual/glu
	cairo? (
		x11-libs/cairo[X]
	)
	dbus? (
		>=sys-apps/dbus-1.0
		dev-libs/dbus-glib
	)
	fuse? ( sys-fs/fuse )
	gtk2? (
		>=x11-libs/gtk+-2.10.0:2
		>=x11-libs/libwnck-2.18.3:1
		x11-libs/pango
		mate? ( x11-wm/marco[-gtk3] )
	)
	gtk3? (
		x11-libs/gtk+:3
		x11-libs/libwnck:3
		x11-libs/pango
		mate? ( x11-wm/marco[gtk3] )
	)
	svg? (
		>=gnome-base/librsvg-2.14.0:2
		>=x11-libs/cairo-1.0
	)
	app-misc/compiz-manager
"

DEPEND="${COMMONDEPEND}
	virtual/pkgconfig
	x11-base/xorg-proto
"

RDEPEND="${COMMONDEPEND}
	x11-apps/mesa-progs
	x11-apps/xdpyinfo
	x11-apps/xset
	x11-apps/xvinfo
"

DOCS=( AUTHORS ChangeLog NEWS README.md TODO )

python_configure_all() {
	#set prefix
	mydistutilsargs=( build --prefix=/usr )
}

src_prepare() {
	echo gtk/gnome/compiz-wm.desktop.in >> po/POTFILES.skip

	eautoreconf || die "eautoreconf failed"
}

src_configure() {
	local myconf
	if use gtk2 ; then
		myconf="${myconf} --with-gtk=2.0"
	elif use gtk3 ; then
		myconf="${myconf} --with-gtk=3.0"
	else
		myconf="${myconf} --disable-gtk"
	fi

	econf \
		--enable-fast-install \
		--disable-static \
		--enable-gsettings \
		--enable-compizconfig \
		--enable-menu-entries \
		--with-default-plugins \
		--with-gnu-ld \
		$(use_enable svg librsvg) \
		$(use_enable cairo annotate) \
		$(use_enable dbus) \
		$(use_enable dbus dbus-glib) \
		$(use_enable fuse) \
		$(use_enable mate) \
		$(use_enable mate marco) \
		${myconf}
}

src_install() {
	default
	prune_libtool_files --all

	domenu "${FILESDIR}"/compiz.desktop
}

pkg_postinst() {
	ewarn "If you update to x11-wm/marco after you install ${P},"
	ewarn "gtk-window-decorator will crash until you reinstall ${PN} again."
}
