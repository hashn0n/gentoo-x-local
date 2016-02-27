# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

# For mozlinguas:
MOZ_LANGS=( ar cs da de el en-GB es-AR es-ES es-MX fi fr gl-ES hr hu is it ja
kn ko nl pl pt-BR pt-PT ro ru sk sl sr sv-SE tr vi zh-CN zh-TW )
MOZ_LANGPACK_PREFIX="langpacks/26.x/"
MOZ_FTP_URI="http://relmirror.palemoon.org"

REQUIRED_BUILDSPACE='12G'

inherit palemoon-0 eutils flag-o-matic multilib mozlinguas pax-utils

KEYWORDS="~x86 ~amd64"
DESCRIPTION="Pale Moon Web Browser"
HOMEPAGE="http://www.palemoon.org"

SLOT="0"
LICENSE="MPL-2.0 GPL-2 LGPL-2.1"
IUSE="+official-branding +optimize -system-libs
	+gtk2 -gtk3
	alsa oss pulseaudio"

SRC_URI="${SRC_URI} ftp://source:get@ftp.palemoon.org/${P}-source.7z"

DEPEND="
	app-arch/p7zip"

RDEPEND="
	>=sys-devel/autoconf-2.13:2.1
	>=dev-lang/perl-5.6
	x11-libs/libXt
	>=dev-libs/libIDL-0.6.3
	>=app-arch/zip-2.3
	>=media-libs/freetype-2.1.0
	media-libs/fontconfig
	>=media-libs/gstreamer-0.10.25:0.10
	>=media-libs/gst-plugins-base-0.10:0.10
	virtual/pkgconfig
	>=sys-apps/dbus-0.60
	>=dev-libs/dbus-glib-0.60
	>=dev-lang/yasm-1.1.0
	>=dev-lang/python-2.7.3:2.7

	optimize? ( >=sys-libs/glibc-2.4 )

	gtk2? ( >=x11-libs/gtk+-2.10:2 )
	gtk3? ( >=x11-libs/gtk+-3.0.0:3 )

	alsa? ( media-libs/alsa-lib )
	oss? ( || ( media-sound/oss media-sound/oss-devel ) )
	pulseaudio? ( media-sound/pulseaudio )

	system-libs? (
		dev-python/ply
		dev-libs/libevent
		media-libs/libjpeg-turbo
		sys-libs/zlib
		app-arch/bzip2
		media-libs/libwebp
		media-libs/libpng[apng]
		>=media-libs/libvpx-1.4.0

		x11-libs/cairo
		x11-libs/pixman
		app-text/hunspell
		>=virtual/libffi-3.0.10
		>=dev-db/sqlite-3.8.11.1[secure-delete]
	)"

REQUIRED_USE="
	|| ( gtk2 gtk3 )
	^^ ( alsa oss pulseaudio )"

src_unpack() {
	mkdir -p "${S}"
	cd "${S}"
	unpack ${A}

	#HACK :-(
	chmod -R 777 .

	# Unpack language packs:
	cd "${WORKDIR}"
	mozlinguas_src_unpack
}

src_prepare() {
	# Allow users to apply any additional patches without modifing the ebuild:
	epatch_user

	# Ensure that our plugins dir is enabled by default:
	sed -i -e "s:/usr/lib/mozilla/plugins:/usr/lib/nsbrowser/plugins:" \
		"${S}/xpcom/io/nsAppFileLocationProvider.cpp" \
		|| die "sed failed to replace plugin path for 32bit!"
	sed -i -e "s:/usr/lib64/mozilla/plugins:/usr/lib64/nsbrowser/plugins:" \
		"${S}/xpcom/io/nsAppFileLocationProvider.cpp" \
		|| die "sed failed to replace plugin path for 64bit!"
}

src_configure() {
	# Basic configuration:
	mozconfig_init

	mozconfig_disable accessibility parental-controls webrtc install-strip

	# Not used and unmaintained. Build fails with them enabled (the default):
	mozconfig_disable tests

	if use optimize; then
		mozconfig_enable optimize=\"-O2\" shared-js
	else
		mozconfig_disable optimize
	fi

	if use official-branding; then
		official-branding_warning
		mozconfig_enable official-branding
	fi

	if use system-libs; then
		mozconfig_with system-ply system-libevent \
			system-jpeg system-zlib system-bz2 system-webp system-png \
			system-libvpx
		mozconfig_enable system-hunspell system-ffi system-sqlite \
			system-cairo system-pixman
	fi

	if use alsa; then
		mozconfig_enable alsa
	fi

	if use oss; then
		mozconfig_enable oss
	fi

	if ! use pulseaudio; then
		mozconfig_disable pulseaudio
	fi

	export MOZBUILD_STATE_PATH="${WORKDIR}/mach_state"
	mozconfig_var PYTHON $(which python2)
	mozconfig_var AUTOCONF $(which autoconf-2.13)
	mozconfig_var MOZ_MAKE_FLAGS "${MAKEOPTS}"

	filter-flags '-O*'

	if [[ $(gcc-major-version) -lt 4 ]]; then
		append-cxxflags -fno-stack-protector
	elif [[ $(gcc-major-version) -gt 4 || $(gcc-minor-version) -gt 3 ]]; then
		if use amd64 || use x86; then
			append-flags -mno-avx
		fi
	fi

	python2 mach # Run it once to create the state directory.
	python2 mach configure || die
}

src_compile() {
	python2 mach build || die
}

src_install() {
	# obj_dir changes depending on arch, compiler, etc:
	local obj_dir="$(echo */config.log)"
	obj_dir="${obj_dir%/*}"

	# Disable MPROTECT for startup cache creation:
	pax-mark m "${obj_dir}"/dist/bin/xpcshell

	load_default_prefs
	set_pref "spellchecker.dictionary_path" "${EPREFIX}/usr/share/myspell"

	# Gotta create the package, unpack it and manually install the files
	# from there not to miss anything (e.g. the statusbar extension):
	einfo "Creating the package..."
	python2 mach package || die
	local extracted_dir="${T}/package"
	mkdir -p "${extracted_dir}"
	cd "${extracted_dir}"
	einfo "Extracting the package..."
	tar xjpf "${S}/${obj_dir}/dist/${P}.en-US.linux-${CTARGET_default%%-*}.tar.bz2"
	einfo "Installing the package..."
	local dest_libdir="/usr/$(get_libdir)"
	mkdir -p "${D}/${dest_libdir}"
	cp -rL "${PN}" "${D}/${dest_libdir}"
	dosym "${dest_libdir}/${PN}/${PN}" "/usr/bin/${PN}"
	einfo "Done installing the package."

	# Until JIT-less builds are supported,
	# also disable MPROTECT on the main executable:
	pax-mark m "${D}/${dest_libdir}/${PN}/"{palemoon,palemoon-bin,plugin-container}

	# Install language packs:
	MOZILLA_FIVE_HOME="${dest_libdir}/${PN}/browser"
	mozlinguas_src_install

	# Install icons and .desktop for menu entry:
	cp -rL "${S}/${obj_dir}/dist/branding" "${extracted_dir}/"
	local size sizes icon_path icon name
	sizes="16 32 48"
	icon_path="${extracted_dir}/branding"
	icon="${PN}"
	name="Pale Moon"
	for size in ${sizes}; do
		insinto "/usr/share/icons/hicolor/${size}x${size}/apps"
		newins "${icon_path}/default${size}.png" "${icon}.png"
	done
	# The 128x128 icon has a different name:
	insinto "/usr/share/icons/hicolor/128x128/apps"
	newins "${icon_path}/mozicon128.png" "${icon}.png"
	# Install a 48x48 icon into /usr/share/pixmaps for legacy DEs:
	newicon "${icon_path}/default48.png" "${icon}.png"
	newmenu "${FILESDIR}/icon/${PN}.desktop" "${PN}.desktop"
	sed -i -e "s:@NAME@:${name}:" -e "s:@ICON@:${icon}:" \
		"${ED}/usr/share/applications/${PN}.desktop" || die
}
