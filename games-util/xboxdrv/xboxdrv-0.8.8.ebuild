# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit linux-info scons-utils toolchain-funcs systemd udev

PACKAGEAUTHOR="xboxdrv"

DESCRIPTION="Userspace Xbox 360 Controller driver"
HOMEPAGE="https://xboxdrv.gitlab.io/
	https://gitlab.com/${PACKAGEAUTHOR}/${PN}"


if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	KEYWORDS="~amd64 ~x86 ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux"
	EGIT_REPO_URI="https://gitlab.com/${PACKAGEAUTHOR}/${PN}.git"
	SRC_URI=""
else
	KEYWORDS="amd64 x86 ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux"
	SRC_URI="https://gitlab.com/${PACKAGEAUTHOR}/${PN}/-/archive/v${PV}/${PN}-v${PV}.tar.gz"
fi

LICENSE="GPL-3"
SLOT="0"
IUSE=""

RDEPEND="
	dev-libs/boost
	dev-libs/dbus-glib:=
	virtual/libudev:=
	sys-apps/dbus:=
	dev-libs/glib:2=
	virtual/libusb:1=
	x11-libs/libX11:=
"

DEPEND="
	virtual/pkgconfig
	${RDEPEND}
"

CONFIG_CHECK="~INPUT_EVDEV ~INPUT_JOYDEV ~INPUT_UINPUT ~!JOYSTICK_XPAD"

src_prepare() {
	epatch "${FILESDIR}"/${P}-scons.patch
}

src_configure() {
	MYSCONS=(
		BUILD=custom \
		CXX="$(tc-getCXX)" \
		AR="$(tc-getAR)" \
		RANLIB="$(tc-getRANLIB)" \
		CXXFLAGS="-Wall ${CXXFLAGS}" \
		LINKFLAGS="${LDFLAGS}"
	)
}

src_compile() {
	escons "${MYSCONS[@]}"
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
