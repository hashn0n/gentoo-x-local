# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit flag-o-matic

if [[ ${PV} == 4.9999* ]]; then
	inherit git-r3
	SRC_URI=""
	EGIT_REPO_URI="https://git.code.sf.net/p/opensound/git"
	EGIT_BRANCH="master"
	KEYWORDS="~amd64 ~x86"
#	S="${WORKDIR}/${PN}"
else
	inherit eutils versionator
	RESTRICT="mirror"
	MY_PV=$(get_version_component_range 1-2)
	MY_BUILD=$(get_version_component_range 3)
	MY_P="oss-v${MY_PV}-build${MY_BUILD}-src-gpl"
	SRC_URI="http://www.4front-tech.com/developer/sources/testing/gpl/${MY_P}.tar.bz2"
	KEYWORDS="amd64 x86"
	S="${WORKDIR}/${MY_P}"
fi

filter-ldflags "-Wl,-O1"

DESCRIPTION="Open Sound System - portable, mixing-capable, high quality sound system for Unix."
HOMEPAGE="http://developer.opensound.com/ https://sourceforge.net/projects/opensound/"

LICENSE="GPL-2"
SLOT="0"
IUSE="ogg"

DEPEND="
	sys-apps/gawk
	>=x11-libs/gtk+-2
	>=sys-kernel/linux-headers-2.6.11
	!media-sound/oss-devel
"

RDEPEND="${DEPEND}"

src_unpack() {
	git-r3_src_unpack
	mkdir "${WORKDIR}/build"

	einfo "Replacing init script with gentoo friendly one..."
	cp "${FILESDIR}"/oss "${S}"/setup/Linux/oss/etc/S89oss

	cd "${S}"
	epatch "${FILESDIR}"/${P}-000_osscore_fix.patch
	epatch "${FILESDIR}"/${P}-000_oss_live_fix.patch
	epatch "${FILESDIR}"/${P}-000_usb.patch
	epatch "${FILESDIR}"/${P}-000_devlists_fix_git.patch
	epatch "${FILESDIR}"/${P}-000_scripts_remove_drv.sh.patch
#	epatch "${FILESDIR}"/${P}-001_oss4_linux_4.11_osscore_fix_git.patch

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
