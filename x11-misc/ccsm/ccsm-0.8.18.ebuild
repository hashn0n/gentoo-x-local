# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7  python3_{6,7} )
DISTUTILS_IN_SOURCE_BUILD=1
inherit distutils-r1 gnome2-utils python-r1

DESCRIPTION="A graphical manager for CompizConfig Plugin (libcompizconfig)"
HOMEPAGE="https://github.com/compiz-reloaded/${PN}"

if [[ ${PV} = 9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/compiz-reloaded/${PN}.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/compiz-reloaded/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-2+"
SLOT="0"
IUSE="gtk3"

RDEPEND="
	dev-python/pycairo[${PYTHON_USEDEP}]
	dev-python/pygobject:3[${PYTHON_USEDEP}]
	<dev-python/compizconfig-python-0.9
	>=dev-python/compizconfig-python-${PV}[${PYTHON_USEDEP}]
	gnome-base/librsvg[introspection]
"

python_prepare_all() {
	# correct gettext behavior
	if [[ -n "${LINGUAS+x}" ]] ; then
		for i in $(cd po ; echo *po | sed 's/\.po//g') ; do
		if ! has ${i} ${LINGUAS} ; then
			rm po/${i}.po || die
		fi
		done
	fi

	distutils-r1_python_prepare_all
}

python_configure_all() {
	mydistutilsargs=(
		build
		"--prefix=/usr"
		"--with-gtk=$(usex gtk3 3.0 2.0)"
	)
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
