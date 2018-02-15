# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

DESCRIPTION="Virtual for IP Queue based on a Berkeley DataBase"
SLOT="0"
KEYWORDS="alpha amd64 arm ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd ~amd64-linux ~x86-linux"

RDEPEND="
	net-libs/libnetfilter_queue
	dev-perl/BerkeleyDB
	dev-libs/popt
	dev-libs/libpcre
"
