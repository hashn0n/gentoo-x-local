# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit desktop gnome2-utils xdg

PACKAGEAUTHOR="telegramdesktop"
PACKAGENAME="tdesktop"
DESCRIPTION="Official desktop client for Telegram (binary package)"
HOMEPAGE="https://desktop.telegram.org https://github.com/${PACKAGEAUTHOR}/${PACKAGENAME}"

SRC_URI="
	https://github.com/${PACKAGEAUTHOR}/${PACKAGENAME}/archive/v${PV}.tar.gz -> ${PACKAGENAME}-${PV}.tar.gz
	amd64? ( https://github.com/${PACKAGEAUTHOR}/${PACKAGENAME}releases/download/v${PV}/tsetup.${PV}.tar.xz )
	x86? ( https://github.com/${PACKAGEAUTHOR}/${PACKAGENAME}/releases/download/v${PV}/tsetup32.${PV}.tar.xz )
"

LICENSE="telegram"
SLOT="0"
KEYWORDS="-* ~amd64 ~x86"

QA_PREBUILT="usr/lib/${PN}/Telegram"

RDEPEND="
	dev-libs/glib:2
	dev-libs/gobject-introspection
	>=sys-apps/dbus-1.4.20
	x11-libs/libX11
	>=x11-libs/libxcb-1.10[xkb]
	>=media-libs/fontconfig-2.13
"

S="${WORKDIR}/Telegram"

src_install() {
	exeinto /usr/lib/${PN}
	doexe "Telegram"
	newbin "${FILESDIR}"/${PN}-r2 "telegram-desktop"

	local icon_size
	for icon_size in 16 32 48 64 128 256 512; do
		newicon -s "${icon_size}" \
			"${WORKDIR}/${PACKAGENAME}-${PV}/Telegram/Resources/art/icon${icon_size}.png" \
			telegram.png
	done

	dodir /etc/${PN}
	insinto /etc/${PN}/
	doins "${FILESDIR}"/fonts.conf

	domenu "${WORKDIR}/${PACKAGENAME}-${PV}"/lib/xdg/${PACKAGEAUTHOR}.desktop
}

pkg_preinst() {
	xdg_pkg_preinst
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_icon_cache_update
	einfo
	einfo "Previous versions of ${PN} have created "
	einfo "\"~/.local/share/applications/telegram.desktop\". These files"
	einfo "conflict with the one shipped by portage and should be removed"
	einfo "from all homedirs. (https://bugs.gentoo.org/618662)"
	einfo
	einfo "This versions fixes fontconfig issues that have been reported"
	einfo "by several users. However, the fix might have side-effects on"
	einfo "non-latin fonts. If you have font issues with this version just"
	einfo "delete \"/etc/${PN}/fonts.conf\" and leave a comment here"
	einfo "https://bugs.gentoo.org/664872"
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_icon_cache_update
}
