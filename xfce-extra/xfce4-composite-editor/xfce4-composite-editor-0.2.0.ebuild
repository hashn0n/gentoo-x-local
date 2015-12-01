# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-composite-editor/xfce4-composite-editor-0.ebuild,v 1.1 2012/12/11 12:07:42 ssuominen Exp $

EAPI="5"

inherit xfconf

MY_PN=Xfwm4CompositeEditor-${PV}

DESCRIPTION="An graphical interface to modify composite settings"
HOMEPAGE="http://keithhedger.hostingsiteforfree.com/pages/apps.html#xfcecomp"
SRC_URI="http://keithhedger.hostingsiteforfree.com/zips/${MY_PN}.tar.gz -> ${MY_PN}-${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="x11-libs/gtk+:2
	>=xfce-base/libxfce4ui-4.8.0
	>=xfce-base/xfconf-4.8.1
	>=xfce-base/xfwm4-4.8.0
"
DEPEND="${RDEPEND}"

S=${WORKDIR}/Xfwm4CompositeEditor-0.2.0

src_install() { :;
	epatch "${FILESDIR}"/${P}-validate.patch
	dobin ${S}/Xfwm4CompositeEditor/app/xfce4-composite-editor
	domenu ${S}/Xfwm4CompositeEditor/resources/pixmaps/Xfwm4CompositeEditor.desktop
	dodoc README
}
