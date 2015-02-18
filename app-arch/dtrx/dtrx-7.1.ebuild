# Copyright 2009-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5
PYTHON_DEPEND="2:2.5"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="3.*"

inherit distutils

DESCRIPTION="Intelligently extract multiple archive types."
HOMEPAGE="http://brettcsmith.org/2007/dtrx/"
SRC_URI="http://brettcsmith.org/2007/dtrx/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="cab 7z +zip cpio +tar +gzip +bzip2 +lzma rpm installshield rar deb lha"

DEPEND=""
RDEPEND="cab? ( app-arch/cabextract )
	7z? ( app-arch/p7zip )
	zip? ( app-arch/unzip )
	tar? ( app-arch/tar )
	cpio? ( app-arch/cpio )
	gzip? ( app-arch/gzip )
	bzip2? ( app-arch/bzip2 )
	lha? ( app-arch/lha )
	lzma? ( app-arch/xz-utils )
	rar? ( app-arch/unrar )
	installshield? ( app-arch/unshield )
	rpm? ( app-arch/rpm app-arch/cpio )
	deb? ( sys-devel/binutils app-arch/tar app-arch/gzip )
"
