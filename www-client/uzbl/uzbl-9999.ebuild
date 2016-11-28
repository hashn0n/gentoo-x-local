# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

# git-hosting.eclass
GH_URI="github"
# GH_REF="master"
EGIT_BRANCH="next"
# python-*.eclass
PYTHON_COMPAT=( python2_7 python3_{4,5} pypy )
# distutils-*.eclass
# event-manager is required and is written in python
# DISTUTILS_OPTIONAL=true

inherit git-hosting
inherit distutils-r1
inherit xdg

DESCRIPTION="A web browser that adheres to the unix philosophy"
LICENSE="GPL-2"

SLOT="0"
SRC_URI+=" https://patch-diff.githubusercontent.com/raw/uzbl/uzbl/pull/321.patch ->
				${PN}-0.9.0-desktop_menu_entries.patch"

KEYWORDS="~amd64 ~arm"

CDEPEND_A=(
	# gtk+-3.0
	'>=x11-libs/gtk+-2.14:3'
	# 'webkit2gtk-4.0 >= 2.3.5'
	# javascriptcoregtk-4.0
	'net-libs/webkit-gtk:4'

	# 'libsoup-2.4 >= 2.33.4'
	# 'libsoup-2.4 >= 2.41.1'
	'>=net-libs/libsoup-2.41.1'

	# gthread-2.0 glib-2.0 'gio-2.0 >= 2.44' gio-unix-2.0
	'dev-libs/glib:2'

	# gnutls
	'net-libs/gnutls'

	# x11
	'x11-libs/libX11'
)
DEPEND_A=( "${CDEPEND_A[@]}"
	# icons converter
	'media-gfx/imagemagick'
	'virtual/pkgconfig'
	"dev-python/setuptools[${PYTHON_USEDEP}]"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/six[${PYTHON_USEDEP}]"
	# configparser is built-in in python3+
	"$(python_gen_cond_dep 'dev-python/configparser[${PYTHON_USEDEP}]' 'python2*' pypy)"
)

## optional deps, specified in `docs/INSTALL.md`
# net-misc/socat
# x11-misc/dmenu
# gnome-extra/zenity
# dev-lang/python
# x11-misc/xclip
# dev-python/pygtk
# dev-python/pygobject

inherit arrays

src_prepare() {
	eapply "${DISTDIR}/${PN}-0.9.0-desktop_menu_entries.patch"
	xdg_src_prepare

	# respect user CFLAGS
	sed -e '/^CFLAGS/ s| -g[^ \t]*||g' \
		-i -- Makefile || die

	# supply PVR instead of commit hash
	sed -e "s|^COMMIT_HASH.*|COMMIT_HASH=${PVR}|" \
		-i -- Makefile || die

	# fix examples path
	# NOTE: this path is hard-coded in startup scripts
	# sed -e "s|\(cp -rv examples\) \$(SHAREDIR)/uzbl/|\1 \$(SHAREDIR)/${PF}/|" \
	# 	-i -- Makefile || die

	# we'll run setup.py manually
	sed -e 's|$(PYTHON)|# disabled # $(PYTHON)|' \
		-i -- Makefile || die

	# fix default ca-cert path
	sed -e "s|/etc/ssl/certs/ca-bundle.crt|${EPREFIX}/etc/ssl/certs/ca-certificates.crt|" \
		-i -- examples/config/config || die

	# NOTE: examples must be installed as they're used in startup scripts

	distutils-r1_src_prepare
}

src_configure() {
	local localmk=(
		"DESTDIR	= ${D}"
		"PREFIX		= ${EPREFIX}/usr"
		"DOCDIR		= \$(SHAREDIR)/doc/${PF}"
		"LIBDIR		= \$(INSTALLDIR)/$(get_libdir)/${PN}"

		"ENABLE_GTK3 = yes"
	)
	printf '%s\n' "${localmk[@]}" > local.mk || die

	distutils-r1_src_configure
}

src_compile() {
	default

	distutils-r1_src_compile
}

src_install() {
	default

	# `--prefix=` can not go into `mydistutilsargs`, because `esetup.py`
	# places it before `install` subcommand.
	python_install() {
		distutils-r1_python_install --prefix="${EPREFIX}/usr"
	}
	distutils-r1_src_install
}
