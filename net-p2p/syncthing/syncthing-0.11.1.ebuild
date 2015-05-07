# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: This ebuild is from mva overlay; Bumped by mva; $

EAPI="5"

vcs="git-r3"
SRC_URI=""
EGIT_REPO_URI="https://github.com/syncthing/${PN}"
EGIT_COMMIT="v${PV}"

inherit eutils base systemd ${vcs}

DESCRIPTION="Open, trustworthy and decentralized syncing engine (some kind of analog of DropBox and BTSync)"
HOMEPAGE="http://syncthing.net"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~x86 ~amd64 ~arm"
IUSE=""

DEPEND="
	dev-lang/go
	app-misc/godep
"
RDEPEND="${DEPEND}"

DOCS=( README.md AUTHORS LICENSE CONTRIBUTING.md )

export GOPATH="${S}"

GO_PN="github.com/syncthing/${PN}"
EGIT_CHECKOUT_DIR="${S}/src/${GO_PN}"
S="${EGIT_CHECKOUT_DIR}"

src_compile() {
	# XXX: All the stuff below needs for "-version" command to show actual info
	local version="$(git describe --always | sed 's/\([v\.0-9]*\)\(-\(beta\|alpha\)[0-9]*\)\?-/\1\2+/')";
	local date="$(git show -s --format=%ct)";
	local user="$(whoami)"
	local host="$(hostname)"; host="${host%%.*}";
	local lf="-w -X main.Version ${version} -X main.BuildStamp ${date} -X main.BuildUser ${user} -X main.BuildHost ${host}"

	godep go build -ldflags "${lf}" -tags noupgrade ./cmd/syncthing
}

src_install() {
	dobin syncthing
	systemd_newunit "${FILESDIR}"/syncthing.service syncthing@.service
	base_src_install_docs
	newinitd ${FILESDIR}/syncthing.initd syncthing
	newconfd ${FILESDIR}/syncthing.confd syncthing
}

pkg_postinst() {
	einfo "To run syncthing as a service, execute"
	einfo "  systemctl start syncthing@<user>"
	einfo "  or"
	einfo " /etc/init.d/syncthing start"
}
