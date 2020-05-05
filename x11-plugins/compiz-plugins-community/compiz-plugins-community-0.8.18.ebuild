# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PACKAGEAUTHOR="ethus3h"

inherit autotools eutils gnome2-utils

DESCRIPTION="Compiz Window Manager: Community Plugins"
HOMEPAGE="https://github.com/${PACKAGEAUTHOR}/${PN}"

if [[ ${PV} = 9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/${PACKAGEAUTHOR}/${PN}.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/${PACKAGEAUTHOR}/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-2+ BSD"
SLOT="0"

RDEPEND="
	media-libs/opencv
	gnome-base/librsvg
	virtual/jpeg:0
	>=x11-libs/compiz-bcop-${PV}
	<x11-libs/compiz-bcop-0.9
	>=x11-plugins/compiz-plugins-experimental-${PV}
	<x11-plugins/compiz-plugins-experimental-0.9
	>=x11-wm/compiz-${PV}
	<x11-wm/compiz-0.9
	x11-libs/cairo
"

DEPEND="
	>=dev-util/intltool-0.35
	>=sys-devel/gettext-0.15
	virtual/pkgconfig
	${RDEPEND}
"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf \
		--enable-fast-install \
		--disable-static
}

src_install() {
	default
	find "${D}" -name '*.la' -delete || die
}

compiz_icon_cache_update() {
	# Needed because compiz needs its own icon cache.
	# Based on https://gitweb.gentoo.org/repo/gentoo.git/tree/eclass/gnome2-utils.eclass#n241
	local dir="${EROOT}/usr/share/compiz/icons/hicolor"
	local updater="${EROOT}/usr/bin/gtk-update-icon-cache"
	if [[ -n "$(ls "$dir")" ]]; then
		"${updater}" -q -f -t "${dir}"
		rv=$?

		if [[ ! $rv -eq 0 ]] ; then
			debug-print "Updating cache failed on ${dir}"

			# Add to the list of failures
			fails+=( "${dir}" )

			retval=2
		fi
	elif [[ $(ls "${dir}") = "icon-theme.cache" ]]; then
		# Clear stale cache files after theme uninstallation
		rm "${dir}/icon-theme.cache"
	fi

	if [[ -z $(ls "${dir}") ]]; then
		# Clear empty theme directories after theme uninstallation
		rmdir "${dir}"
	fi
}

pkg_postinst() {
	gnome2_icon_cache_update
	compiz_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
	compiz_icon_cache_update
}
