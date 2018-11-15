# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit rpm
#unpacker  gnome2-utils xdg

MY_PN="${PN/-bin/}"

DESCRIPTION="Video conferencing and web conferencing service"
HOMEPAGE="https://zoom.us"
SRC_URI="
	amd64? ( ${HOMEPAGE}/client/${PV}/${MY_PN}_x86_64.rpm -> ${P}_x86_64.rpm )
	x86? ( ${HOMEPAGE}/client/${PV}/${MY_PN}_i686.rpm -> ${P}_i686.rpm )
"

LICENSE="ZOOM"
SLOT="0"
KEYWORDS="amd64 x86"

RESTRICT="mirror"

IUSE="pulseaudio gstreamer"

DEPEND=""
RDEPEND="${DEPEND}
	pulseaudio? ( media-sound/pulseaudio )
	gstreamer? ( media-libs/gst-plugins-base )
	dev-db/sqlite
	dev-db/unixODBC
	dev-libs/glib
	dev-libs/nss
	dev-libs/libxslt
	dev-libs/quazip
	dev-qt/qtmultimedia
	dev-qt/qtwebengine
	dev-qt/qtsvg
	media-libs/fontconfig
	media-libs/gstreamer
	media-libs/gst-plugins-base
	media-libs/mesa
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXi
	x11-libs/libXrender
"

S="${WORKDIR}"

src_unpack() {
#	unpack_rpm ${A}
	rpm_src_unpack ${A}
}

src_prepare() {
	rm -rf ${WORKDIR}/usr/share/doc
	cd ${WORKDIR}/opt/zoom
	rm -r libQt5* libicu* libfaac* libquazip* libturbojpeg* audio egldeviceintegrations generic iconengines imageformats platforminputcontexts platforms platformthemes Qt QtQml QtQuick QtQuick.2 QtWebChannel QtWebEngine xcbglintegrations qt.conf
	cd ${S}
	sed -i -e 's:Icon=Zoom.png:Icon=Zoom:' "${WORKDIR}/usr/share/applications/Zoom.desktop"
	sed -i -e 's:Application;::' "${WORKDIR}/usr/share/applications/Zoom.desktop"
	default
	eapply_user
}

src_install() {
	doins -r *
	fperms a+x /opt/zoom/{zopen,zoom,ZoomLauncher,qtdiag,QtWebEngineProcess,zoomlinux,zoom.sh,config-dump.sh,getmem.sh}
}
