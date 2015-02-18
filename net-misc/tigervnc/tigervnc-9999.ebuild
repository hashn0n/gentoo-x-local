# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils cmake-utils autotools java-pkg-opt-2

if [[ ${PV} == "9999" ]] ; then
	XSERVER_VERSION="1.13.4"
elif [[ ${PV} == "1.2.0" ]] ; then
	XSERVER_VERSION="1.12.0"
else
	XSERVER_VERSION="1.12.0"
fi
OPENGL_DIR="xorg-x11"

if [[ ${PV} == "9999" ]] ; then
ESVN_REPO_URI="https://${PN}.svn.sourceforge.net/svnroot/tigervnc/trunk/"
inherit subversion autotools
SRC_URI="mirror://gentoo/${PN}.png
	server? ( ftp://ftp.freedesktop.org/pub/xorg/individual/xserver/xorg-server-${XSERVER_VERSION}.tar.bz2	)"
KEYWORDS="~amd64 ~x86"
else
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz
	mirror://gentoo/${PN}.png
	server? ( ftp://ftp.freedesktop.org/pub/xorg/individual/xserver/xorg-server-${XSERVER_VERSION}.tar.bz2	)"
KEYWORDS="~amd64 ~x86"
fi

DESCRIPTION="Remote desktop viewer display system"
HOMEPAGE="http://www.tigervnc.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="gnutls internal-fltk java nptl +opengl pam server +xorgmodule"

RDEPEND="virtual/jpeg
	sys-libs/zlib
	x11-libs/libXtst
	gnutls? ( net-libs/gnutls )
	java? ( >=virtual/jre-1.7 )
	pam? ( virtual/pam )
	!internal-fltk? ( >=x11-libs/fltk-1.3.2 )
	internal-fltk? (
		x11-libs/libXft
		x11-libs/libXinerama
		x11-libs/libXcursor )
	server? (
		x11-libs/libXi
		x11-libs/libXfont
		x11-libs/libXmu
		x11-libs/libxkbfile
		x11-libs/libXrender
		x11-libs/pixman
		x11-apps/xauth
		x11-apps/xsetroot
		x11-misc/xkeyboard-config
		opengl? ( app-admin/eselect-opengl )
		xorgmodule? ( =x11-base/xorg-server-${XSERVER_VERSION%.*}* )
	)
	!net-misc/vnc
	!net-misc/tightvnc
	!net-misc/xf4vnc"
DEPEND="${RDEPEND}
	amd64? ( dev-lang/nasm )
	x86? ( dev-lang/nasm )
	x11-proto/inputproto
	x11-proto/xextproto
	x11-proto/xproto
	java? ( >=virtual/jdk-1.7 )
	server?	(
		dev-util/pkgconfig
		media-fonts/font-util
		x11-misc/util-macros
		x11-proto/bigreqsproto
		x11-proto/compositeproto
		x11-proto/damageproto
		x11-proto/dri2proto
		x11-proto/fixesproto
		x11-proto/fontsproto
		x11-proto/randrproto
		x11-proto/renderproto
		x11-proto/resourceproto
		x11-proto/scrnsaverproto
		x11-proto/videoproto
		x11-proto/xcmiscproto
		x11-proto/xineramaproto
		x11-libs/xtrans
		opengl? ( media-libs/mesa )
	)"

CMAKE_IN_SOURCE_BUILD=1

pkg_setup() {
	if ! use server ; then
		echo
		einfo "The 'server' USE flag will build tigervnc's server."
		einfo "If '-server' is chosen only the client is built to save space."
		einfo "Stop the build now if you need to add 'server' to USE flags.\n"
		ebeep
		epause 5
	else
		ewarn "Forcing on xorg-x11 for new enough glxtokens.h..."
		OLD_IMPLEM="$(eselect opengl show)"
		eselect opengl set ${OPENGL_DIR}
	fi
}

switch_opengl_implem() {
	# Switch to the xorg implementation.
	# Use new opengl-update that will not reset user selected
	# OpenGL interface ...
	echo
	eselect opengl set ${OLD_IMPLEM}
}

src_unpack() {
if [[ ${PV} == "9999" ]] ; then
	unpack xorg-server-${XSERVER_VERSION}.tar.bz2
	subversion_src_unpack
	cd "${S}"
	epatch "${FILESDIR}"/java7_9999.patch
	if use server ; then
		cp -r "${WORKDIR}"/xorg-server-${XSERVER_VERSION}/* unix/xserver
		epatch "${FILESDIR}"/1.2.0-gethomedir.patch
		cd unix/xserver
		epatch ../xserver114.patch
		eautoreconf
	fi
elif [[ ${PV} == "1.2.0" ]] ; then
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/gnutls.patch
	epatch "${FILESDIR}"/install_paths.patch
	epatch "${FILESDIR}"/java7.patch
	epatch "${FILESDIR}"/no-force-fltk.patch
	if use server ; then
		cp -r "${WORKDIR}"/xorg-server-${XSERVER_VERSION}/* unix/xserver
		epatch "${FILESDIR}"/1.2.0-gethomedir.patch
		epatch "${FILESDIR}"/xorg111.patch
		epatch "${FILESDIR}"/xorg112.patch
		cd unix/xserver
		epatch ../xserver110.patch
		eautoreconf
	fi
else
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/tigervnc11-rh692048.patch
	eautoreconf
	cd unix
	if use server ; then
		cp -r "${WORKDIR}"/xorg-server-${XSERVER_VERSION}/* unix/xserver
		epatch xserver110.patch
		epatch "${FILESDIR}"/tigervnc11-xorg111.patch
		epatch "${FILESDIR}"/tigervnc11-xorg112.patch
		epatch "${FILESDIR}"/tigervnc-102434.patch
		epatch "${FILESDIR}"/tigervnc-cookie.patch
		epatch "${FILESDIR}"/tigervnc-viewer-reparent.patch
		cd xserver
		epatch "${FILESDIR}"/1.1.0-export_missing_symbol.patch
		epatch "${FILESDIR}"/1.1.0-gethomedir.patch
		epatch "${FILESDIR}"/0001-Use-memmove-instead-of-memcpy-in-fbblt.c-when-memory.patch
		eautoreconf
	fi
fi
}

src_compile() {
	mycmakeargs=(
		-G "Unix Makefiles"
		$(cmake-utils_use_use internal-fltk INCLUDED_FLTK)
		$(cmake-utils_use_enable gnutls GNUTLS)
		$(cmake-utils_use_enable pam PAM)
		$(cmake-utils_use_build java JAVA)
	)

	cmake-utils_src_compile

	if use server ; then
		cd unix/xserver
		econf \
			--disable-xorg --disable-xnest --disable-xvfb --disable-dmx \
			--disable-xwin --disable-xephyr --disable-kdrive --with-pic \
			--disable-static --disable-xinerama --without-dtrace \
			--disable-unit-tests --disable-devel-docs --disable-dri \
			--disable-config-dbus \
			--disable-config-hal \
			--disable-config-udev \
			--enable-dri2 \
			$(use_enable opengl glx) \
			$(use_enable nptl glx-tls) \
			|| die "econf server failed"
		emake || die "emake server failed"
	fi
}

src_install() {
	cmake-utils_src_install

	newicon "${DISTDIR}"/tigervnc.png vncviewer.png
	make_desktop_entry vncviewer vncviewer vncviewer Network

	if use server ; then
		cd unix/xserver/hw/vnc
		emake DESTDIR="${D}" install || die "emake install failed"
		! use xorgmodule && rm -rf "${D}"/usr/$(get_libdir)/xorg

		newconfd "${FILESDIR}"/${PN}.confd ${PN}
		newinitd "${FILESDIR}"/${PN}.initd ${PN}

		rm "${D}"/usr/$(get_libdir)/xorg/modules/extensions/libvnc.la
	else
		cd "${D}"
		for f in vncserver vncpasswd x0vncserver vncconfig; do
			rm usr/bin/$f
			rm usr/share/man/man1/$f.1
		done
	fi
}

pkg_postinst() {
	use server && switch_opengl_implem
}
