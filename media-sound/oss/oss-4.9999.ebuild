# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit flag-o-matic git-r3

filter-ldflags "-Wl,-O1"

EGIT_REPO_URI="https://github.com/Open-Sound-System/Open-Sound-System.git"
EGIT_BRANCH="master"
SRC_URI=""

DESCRIPTION="Open Sound System - portable, mixing-capable, high quality sound system for Unix."
HOMEPAGE="http://developer.opensound.com/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="sys-apps/gawk
	>=x11-libs/gtk+-2
	>=sys-kernel/linux-headers-2.6.11
	!media-sound/oss"
RDEPEND="${DEPEND}"

#S="${WORKDIR}/${PN}"

src_unpack() {
	git-r3_src_unpack
	mkdir "${WORKDIR}/build"

	einfo "Replacing init script with gentoo friendly one..."
	cp "${FILESDIR}"/oss "${S}"/setup/Linux/oss/etc/S89oss

#	cd "${S}"
#	epatch_user
}

src_configure() {
	myconf="--enable-libsalsa=NO"
	einfo "Running configure..."
	# Configure has to be run from build dir with full path.
	cd "${WORKDIR}"/build
	"${S}"/configure ${myconf} || die "configure failed"
}

src_compile() {
	cd "${WORKDIR}"/build
	einfo "Stripping compiler flags..."
	sed -i -e 's/-D_KERNEL//' "${WORKDIR}"/build/Makefile

	emake build || die "emake build failed"
}

src_install() {
	newinitd "${FILESDIR}"/oss oss
	cd "${WORKDIR}"/build
	cp -R prototype/* "${D}"
}

pkg_postinst() {
	elog "To use OSSv4 for the first time you must run"
	elog "# /etc/init.d/oss start "
	elog ""
	elog "If you are upgrading, run"
	elog "# /etc/init.d/oss restart "
	elog ""
	elog "Enjoy OSSv4 !"
}