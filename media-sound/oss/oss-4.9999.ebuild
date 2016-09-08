# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit mercurial flag-o-matic

filter-ldflags "-Wl,-O1"

EHG_REPO_URI="http://opensound.hg.sourceforge.net:8000/hgroot/opensound/opensound"

DESCRIPTION="Open Sound System - portable, mixing-capable, high quality sound system for Unix."
HOMEPAGE="http://developer.opensound.com/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="ogg"

DEPEND="sys-apps/gawk
	>=x11-libs/gtk+-2
	>=sys-kernel/linux-headers-2.6.11
	!media-sound/oss-devel"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}"

src_unpack() {
	mercurial_src_unpack
	mkdir "${WORKDIR}/build"

	einfo "Replacing init script with gentoo friendly one..."
	cp "${FILESDIR}"/oss "${S}"/setup/Linux/oss/etc/S89oss

	cd "${S}"
	epatch "${FILESDIR}"/${P}-000_gcc-5.patch
	epatch "${FILESDIR}"/${P}-000_osscore_fix.patch
	epatch "${FILESDIR}"/${P}-000_oss_live_fix.patch
	epatch "${FILESDIR}"/${P}-000_usb.patch
	epatch "${FILESDIR}"/${P}-001_oss4_linux_3.8_modules_build_fix.patch
	epatch "${FILESDIR}"/${P}-002_oss4_linux_3.10_build_fix.patch
	epatch "${FILESDIR}"/${P}-003_oss4_linux_3.11_build_fix.patch
	epatch "${FILESDIR}"/${P}-004_oss4_linux_3.14_build_fix.patch
	epatch "${FILESDIR}"/${P}-005_oss4_linux_4.0_build_fix.patch
	epatch "${FILESDIR}"/${P}-006_oss4_linux_4.6_fix.patch

	epatch_user
}

src_prepare() {
	if ! use ogg ; then
		sed -e "s;OGG_SUPPORT=YES;OGG_SUPPORT=NO;g" \
			-i "${S}/configure" || die
	fi

	sed -e "s/\ -Werror//g" \
	-i "phpmake/Makefile.php" "setup/Linux/oss/build/install.sh" "setup/srcconf_linux.inc" || die

	# Build at the "build" directory instead of /tmp
	sed -e "s;/tmp/;${WORKDIR}/build/;g" \
	-i "${S}/setup/Linux/build.sh" || die

	# Remove bundled libflashsupport. Deprecated since 2006.
	rm ${S}/oss/lib/flashsupport.c || die
	sed -e "/^.*flashsupport.c .*/d" \
		-i "${S}/setup/Linux/build.sh" \
	-i "${S}/setup/Linux/oss/build/install.sh" || die
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
