# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit linux-info scons-utils toolchain-funcs systemd udev

PACKAGEAUTHOR="xboxdrv"
DESCRIPTION="Userspace Xbox 360 Controller driver"
HOMEPAGE="http://pingus.seul.org/~grumbel/xboxdrv/
	https://github.com/${PACKAGEAUTHOR}/${PN}"

#MY_P=${PN}-linux-${PV}
#SRC_URI="http://pingus.seul.org/~grumbel/xboxdrv/${MY_P}.tar.bz2"
#S=${WORKDIR}/${MY_P}

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	KEYWORDS="~amd64 ~x86 ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux"
	EGIT_REPO_URI="
		git://github.com/${PACKAGEAUTHOR}/${PN}
		https://github.com/${PACKAGEAUTHOR}/${PN}
	"
	SRC_URI=""
else
	KEYWORDS="amd64 x86 ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux"
	SRC_URI="https://github.com/${PACKAGEAUTHOR}/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
fi


RDEPEND="dev-libs/boost
	dev-libs/dbus-glib:=
	virtual/libudev:=
	sys-apps/dbus:=
	dev-libs/glib:2=
	virtual/libusb:1=
	x11-libs/libX11:="
DEPEND="${RDEPEND}
	virtual/pkgconfig"

CONFIG_CHECK="~INPUT_EVDEV ~INPUT_JOYDEV ~INPUT_UINPUT ~!JOYSTICK_XPAD"

src_prepare() {
	epatch "${FILESDIR}"/${P}-scons.patch
}

src_compile() {
	escons \
		BUILD=custom \
		CXX="$(tc-getCXX)" \
		AR="$(tc-getAR)" \
		RANLIB="$(tc-getRANLIB)" \
		CXXFLAGS="-Wall ${CXXFLAGS}" \
		LINKFLAGS="${LDFLAGS}"
}

src_install() {
	dobin xboxdrv
	doman doc/xboxdrv.1
	dodoc AUTHORS NEWS PROTOCOL TODO

	newinitd "${FILESDIR}"/xboxdrv.initd xboxdrv
	newconfd "${FILESDIR}"/xboxdrv.confd xboxdrv

	insinto /etc/dbus-1/system.d/
	doins "${FILESDIR}/org.seul.Xboxdrv.conf"

	udev_newrules "${FILESDIR}"/xboxdrv.udev-rules 99-xbox-controller.rules
	systemd_dounit "${FILESDIR}"/xboxdrv.service
}

pkg_postinst() {
	udev_reload
}
