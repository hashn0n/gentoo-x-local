# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: wine.eclass
# @MAINTAINER:
# Rob Walker <bob.mt.wya@gmail.com>
# @SUPPORTED_EAPIS: 6 7
# @AUTHOR:
# Rob Walker <bob.mt.wya@gmail.com>
# @BLURB: common wine ebuild functions
# @DESCRIPTION:
# Eclass to provide functionality common to the ::bobwya Overlay:
#   app-emulation/wine-staging  app-emulation/wine-vanilla
# Wine packages. This Eclass is not compatible with the ::gentoo
# or ::wine Overlay Wine packages.
# The functionality, this Eclass provides, includes:
#    providing git helper functionality
#    fully setting up the SRC_URI
#    applying third party patchsets
#    setting up stock Gentoo patches
#    helper functions for manipulating source code / build files
#    helper functions for clean up; when specific USE flags are specified
#    overriding specific 'house keeping' ebuild phases
#    ...
# Implementing this Eclass was motivated by the shear amount of
# redundant duplication, when maintaining a large set of versions
# for legacy Wine packages.
# Implementing a common Eclass for the in-tree Gentoo ::gentoo
# and ::wine Overlay has been discussed.
# In fact setting up the ::wine Overlay was originally forced on the
# Gentoo Wine Developers. The the Gentoo ::gentoo app-emulation/wine-*
# packages were putting a large strain on
# the Gentoo infrastructure.
# Moving to a common Wine eclass has shown to provide impressive
# space savings: >50% reduction ; for in-tree Wine package sizes.

if [[ -z "${_WINE_ECLASS}" ]]; then
_WINE_ECLASS=1

case ${EAPI} in
	6)  inherit eapi7-ver ;;
	7)  ;;
	*)  die "EAPI=${EAPI:-0} is not supported" ;;
	esac

EXPORT_FUNCTIONS pkg_pretend pkg_setup src_configure multilib_src_test pkg_postinst pkg_prerm pkg_postrm

IUSE=""
PATCHES=""
# @ECLASS-VARIABLE: _WINE_SHA1_REGEXP
# @INTERNAL
# @DESCRIPTION:
# SHA-1 hash regular expression (internal usage).
_WINE_SHA1_REGEXP="[[:xdigit:]]{40}"
readonly _WINE_SHA1_REGEXP

# @ECLASS-VARIABLE: _WINE_VARIABLE_NAME_REGEXP
# @INTERNAL
# @DESCRIPTION:
# Regular expression - used to test BASH variable names
# passed by reference (internal usage).
_WINE_VARIABLE_NAME_REGEXP="^[_[:alpha:]][_[:alnum:]]+$"
readonly _WINE_VARIABLE_NAME_REGEXP

# @ECLASS-VARIABLE: _WINE_GIT_DATE_ROFFSET
# @INTERNAL
# @DESCRIPTION:
# Reverse offset range to search for a Wine Staging Git commit
# which matches a Wine Git commit. This is used when searching
# within the Wine Git tree; when the end user has specified a
# Wine Git commit which does not have a matching Wine Staging
# Git commit.
_WINE_GIT_DATE_ROFFSET="^[_[:alpha:]][_[:alnum:]]+$"
readonly _WINE_GIT_DATE_ROFFSET

# @ECLASS-VARIABLE: _WINE_GIT_DATE_FOFFSET
# @INTERNAL
# @DESCRIPTION:
# Forward offset range to search for a Wine Staging Git commit
# which matches a Wine Git commit. (See: _WINE_GIT_DATE_ROFFSET)
_WINE_GIT_DATE_FOFFSET="^[_[:alpha:]][_[:alnum:]]+$"
readonly _WINE_GIT_DATE_FOFFSET

# @ECLASS-VARIABLE: _WINE_IS_STAGING
# @INTERNAL
# @DESCRIPTION:
# Is package app-emulation/wine-staging (1) or app-emulation/wine-vanilla (0) ?
[[ "${PN}" == "wine-staging" ]] && _WINE_IS_STAGING=1 || _WINE_IS_STAGING=0
readonly _WINE_IS_STAGING

# gentoo-wine-ebuild-common support
# @ECLASS-VARIABLE: WINE_EBUILD_COMMON_P
# @DESCRIPTION:
# Full name and version for current: gentoo-wine-ebuild-common; tarball.
WINE_EBUILD_COMMON_P="gentoo-wine-ebuild-common-20181204"
readonly WINE_EBUILD_COMMON_P

# @ECLASS-VARIABLE: WINE_EBUILD_COMMON_PN
# @DESCRIPTION:
# Name only, for current: gentoo-wine-ebuild-common; tarball.
WINE_EBUILD_COMMON_PN="${WINE_EBUILD_COMMON_P%-*}"
readonly WINE_EBUILD_COMMON_PN

# @ECLASS-VARIABLE: WINE_EBUILD_COMMON_PV
# @DESCRIPTION:
# Version only, for current: gentoo-wine-ebuild-common; tarball.
WINE_EBUILD_COMMON_PV="${WINE_EBUILD_COMMON_P##*-}"
readonly WINE_EBUILD_COMMON_PV

# @ECLASS-VARIABLE: WINE_ESYNC_P
# @DESCRIPTION:
# Full name and version for current: gentoo-wine-esync; tarball.
WINE_ESYNC_P="gentoo-wine-esync-20181215"
readonly WINE_ESYNC_P

# @ECLASS-VARIABLE: WINE_ESYNC_PN
# @DESCRIPTION:
# Name only, for current: gentoo-wine-esync; tarball.
WINE_ESYNC_PN="${WINE_ESYNC_P%-*}"
readonly WINE_ESYNC_PN

# @ECLASS-VARIABLE: WINE_ESYNC_PV
# @DESCRIPTION:
# Version only, for current: gentoo-wine-esync; tarball.
WINE_ESYNC_PV="${WINE_ESYNC_P##*-}"
readonly WINE_ESYNC_PV

# wine-pba support
# @ECLASS-VARIABLE: WINE_PBA_P
# @DESCRIPTION:
# Full name and version for current: gentoo-wine-pba; tarball.
WINE_PBA_P="gentoo-wine-pba-20181119"
readonly WINE_PBA_P

# @ECLASS-VARIABLE: WINE_PBA_PN
# @DESCRIPTION:
# Name only, for current: gentoo-wine-pba; tarball.
WINE_PBA_PN="${WINE_PBA_P%-*}"
readonly WINE_PBA_PN

# @ECLASS-VARIABLE: WINE_PBA_PV
# @DESCRIPTION:
# Version only, for current: gentoo-wine-pba; tarball.
WINE_PBA_PV="${WINE_PBA_P##*-}"
readonly WINE_PBA_PV

# @ECLASS-VARIABLE: WINE_PV
# @DESCRIPTION:
# Wine release version. This will be stripped of components (see below).
WINE_PV="${PV}"
# @ECLASS-VARIABLE: _WINE_VERSION_ARRAY_COMPONENTS
# @INTERNAL
# @DESCRIPTION:
# Wine release version components (array).
# shellcheck disable=SC2207
_WINE_VERSION_ARRAY_COMPONENTS=( $( ver_rs 1- ' ' ) )
# @ECLASS-VARIABLE: _WINE_VERSION_COMPONENT_COUNT
# @INTERNAL
# @DESCRIPTION:
# Wine release version component count.
_WINE_VERSION_COMPONENT_COUNT=${#_WINE_VERSION_ARRAY_COMPONENTS[@]}

# @ECLASS-VARIABLE: _WINE_MAJOR_VERSION
# @INTERNAL
# @DESCRIPTION:
# Major Wine release version (e.g. 3.??.?? = 3).
_WINE_MAJOR_VERSION=$( ver_cut 1 )

# @ECLASS-VARIABLE: _WINE_MINOR_VERSION
# @INTERNAL
# @DESCRIPTION:
# Minor Wine release version (e.g. ??.1.?? = 1).
_WINE_MINOR_VERSION=0
(( _WINE_VERSION_COMPONENT_COUNT > 1 )) && _WINE_MINOR_VERSION=$( ver_cut 2 )

# @ECLASS-VARIABLE: _WINE_IS_STABLE
# @INTERNAL
# @DESCRIPTION:
# Is this Wine release a Wine Stable release version?
_WINE_IS_STABLE=$(( ((_WINE_MAJOR_VERSION == 1) && (_WINE_MINOR_VERSION % 2 == 0)) ||
	((_WINE_MAJOR_VERSION >= 2) && (_WINE_MINOR_VERSION == 0)) ))

# @ECLASS-VARIABLE: _WINE_VERSION_SLOT
# @INTERNAL
# @DESCRIPTION:
# Hack, using Portage patch versioning, to implement multiple slots per single unique slotted version.
(( _WINE_VERSION_COMPONENT_COUNT > 2 )) && \
if [[ "$( ver_cut $((_WINE_VERSION_COMPONENT_COUNT-1)) )" = "p" ]]; then
	_WINE_VERSION_SLOT="$( ver_cut $((_WINE_VERSION_COMPONENT_COUNT-1))- )"
	WINE_PV="${WINE_PV%_${_WINE_VERSION_SLOT}}"
	: $(( _WINE_VERSION_COMPONENT_COUNT -= 2 ))
fi

# @ECLASS-VARIABLE: WINE_IS_RC_VERSION
# @DESCRIPTION:
# Is this Wine release a Wine Stable base release version?
WINE_IS_RC_VERSION=0
(( _WINE_VERSION_COMPONENT_COUNT > 2 )) && \
if [[ "$( ver_cut $((_WINE_VERSION_COMPONENT_COUNT-1)) )" = "rc" ]]; then
	WINE_IS_RC_VERSION=1
	: $(( _WINE_VERSION_COMPONENT_COUNT -= 2 ))
	WINE_PV=$(ver_rs $((_WINE_VERSION_COMPONENT_COUNT)) '''-''' "${WINE_PV}")
fi

# @ECLASS-VARIABLE: _WINE_IS_STABLE_BASE
# @INTERNAL
# @DESCRIPTION:
# Is this Wine release a Wine Stable base release version?
_WINE_IS_STABLE_BASE=$(( _WINE_IS_STABLE && (_WINE_VERSION_COMPONENT_COUNT == 2) ))

# @ECLASS-VARIABLE: WINE_STABLE_PREFIX
# @DESCRIPTION:
# Prefix for Wine Stable versions. Applies to app-emulation/wine-vanilla package only.
# Used to support downloading Wine Stable release candidate versions.
WINE_STABLE_PREFIX=""
if (( _WINE_IS_STABLE && WINE_IS_RC_VERSION && ! _WINE_IS_STABLE_BASE )); then
	WINE_STABLE_PREFIX="wine-stable-"
fi

# @ECLASS-VARIABLE: WINE_PN
# @DESCRIPTION:
# Package name with variant suffix stripped.
WINE_PN="${PN%%-*}"

# @ECLASS-VARIABLE: WINE_STAGING_PN
# @DESCRIPTION:
# Wine Staging package name.
WINE_STAGING_PN=""
((_WINE_IS_STAGING)) && WINE_STAGING_PN="wine-staging"

# @ECLASS-VARIABLE: WINE_STAGING_PV
# @DESCRIPTION:
# Separate versioning for Wine Staging, to allow for re-release version updates.
WINE_STAGING_PV="${WINE_PV}"

# @ECLASS-VARIABLE: _WINE_STAGING_SUFFIX
# @INTERNAL
# @DESCRIPTION:
# Handle unofficial Wine Staging releases.
# Eclass internal variable.

_WINE_STAGING_SUFFIX=""

# @ECLASS-VARIABLE: _WINE_STAGING_REVISION
# @INTERNAL
# @DESCRIPTION:
# Used to stores stripped Wine Staging version revision.
# Eclass internal variable.

# Handle special cases for Wine Staging ...
((_WINE_IS_STAGING)) && case "${WINE_STAGING_PV}" in
	1.8.[1-6])
		_WINE_STAGING_SUFFIX="-unofficial"
		;;
	3.13.1)
		_WINE_STAGING_REVISION=".${WINE_PV##*.}"
		WINE_PV="${WINE_PV%${_WINE_STAGING_REVISION}}"
		;;
	*)
		;;
esac

# @ECLASS-VARIABLE: WINE_STAGING_P
# @DESCRIPTION:
# Separate naming and versioning for Wine Staging packages.
WINE_STAGING_P="${WINE_STAGING_PN}-${WINE_STAGING_PV}"

# @ECLASS-VARIABLE: _WINE_STAGING_DIR
# @INTERNAL
# @DESCRIPTION:
# Separate naming and versioning for Wine Staging packages.
_WINE_STAGING_DIR="${WORKDIR}/${WINE_STAGING_P}${_WINE_STAGING_SUFFIX}"

# @ECLASS-VARIABLE: WINE_P
# @DESCRIPTION:
# Package name with variant suffix stripped and stripped Wine version
# appended. The Wine version is stripped of Wine Staging re-release minor revisions.
WINE_P="${WINE_STABLE_PREFIX}${WINE_PN}-${WINE_PV}"

# @ECLASS-VARIABLE: WINE_VARIANT
# @DESCRIPTION:
# WINE_VARIANT is current the currently active Wine variant.
# Format: staging-${PV} vanilla-${PV}
WINE_VARIANT="${PN#wine}-${PV}"
WINE_VARIANT="${WINE_VARIANT#-}"

# @ECLASS-VARIABLE: WINE_PREFIX
# @DESCRIPTION:
# WINE_PREFIX defines the native ABI installation path (binaries and libraries),
# for the current Wine variant.
WINE_PREFIX="${EPREFIX%/}/usr/lib/wine-${WINE_VARIANT}"

# @ECLASS-VARIABLE: WINE_DATAROOTDIR
# @DESCRIPTION:
# WINE_DATAROOTDIR defines the root, of the shared data directory,
# for the current Wine variant.
WINE_DATAROOTDIR="${EPREFIX%/}/usr/share/wine-${WINE_VARIANT}"

# @ECLASS-VARIABLE: WINE_DATADIR
# @DESCRIPTION:
# WINE_DATADIR defines the shared data directory,
# for the current Wine variant.
WINE_DATADIR="${WINE_DATAROOTDIR}"

# @ECLASS-VARIABLE: WINE_DOCDIR
# @DESCRIPTION:
# WINE_DOCDIR defines the shared documentation directory,
# for the current Wine variant.
# shellcheck disable=SC2034
WINE_DOCDIR="${EPREFIX%/}/usr/share/doc/${PF}"

# @ECLASS-VARIABLE: WINE_INCLUDEDIR
# @DESCRIPTION:
# WINE_INCLUDEDIR defines the include (header) files directory,
# for the current Wine variant.
# shellcheck disable=SC2034
WINE_INCLUDEDIR="${EPREFIX%/}/usr/include/wine-${WINE_VARIANT}"

# @ECLASS-VARIABLE: WINE_LIBEXECDIR
# @DESCRIPTION:
# WINE_LIBEXECDIR defines the out-of-path PATH executables/library directory,
# for the current Wine variant.
# shellcheck disable=SC2034
WINE_LIBEXECDIR="${EPREFIX%/}/usr/libexec/wine-${WINE_VARIANT}"

# @ECLASS-VARIABLE: WINE_LOCALSTATEDIR
# @DESCRIPTION:
# WINE_LOCALSTATEDIR defines the volatile state directory,
# for the current Wine variant.
# shellcheck disable=SC2034
WINE_LOCALSTATEDIR="${EPREFIX%/}/var/wine-${WINE_VARIANT}"

# @ECLASS-VARIABLE: WINE_MANDIR
# @DESCRIPTION:
# WINE_MANDIR defines the volatile state directory,
# for the current Wine variant.
WINE_MANDIR="${WINE_DATADIR}/man"

# @ECLASS-VARIABLE: PATCHES_BIN
# @DESCRIPTION:
# PATCHES_BIN is an array variable for storing binary patches.
# Should be set externally.
[[ -z "${PATCHES_BIN}" ]] && PATCHES_BIN=()

# @ECLASS-VARIABLE: WINE_GIT_COMMIT_DATE
# @DESCRIPTION:
# Git commit date, of the Wine Git Source tree current HEAD.
# Should be set externally.
: "${WINE_GIT_COMMIT_DATE:=}"

# @ECLASS-VARIABLE: WINE_GIT_COMMIT_HASH
# @DESCRIPTION:
# Git commit hash, of the Wine Git Source tree current HEAD.
# Should be set externally.
: "${WINE_GIT_COMMIT_HASH:=}"

# @ECLASS-VARIABLE: SRC_URI
# @DESCRIPTION:
# Set base SRC_URI components (excluding: wine-esync, wine-pba components)
SRC_URI="https://github.com/bobwya/${WINE_EBUILD_COMMON_PN}/archive/${WINE_EBUILD_COMMON_PV}.tar.gz -> ${WINE_EBUILD_COMMON_P}.tar.gz"
if [[ "${WINE_PV}" != "9999" ]]; then
	if (( !_WINE_IS_STAGING && _WINE_IS_STABLE && WINE_IS_RC_VERSION && !_WINE_IS_STABLE_BASE )); then
		# Pull Wine RC intermediate stable versions from alternate Github repository...
		SRC_URI="${SRC_URI}
			https://github.com/mstefani/wine-stable/archive/${WINE_PN}-${WINE_PV}.tar.gz -> ${WINE_P}.tar.gz"
	elif (( (_WINE_MAJOR_VERSION < 2) || ((_WINE_VERSION_COMPONENT_COUNT == 2) && (_WINE_MAJOR_VERSION == 2) && (_WINE_MINOR_VERSION == 0)) )); then
		# The base Wine 2.0 release tarball was bzip2 compressed - switching to xz shortly after...
		SRC_URI="${SRC_URI}
			https://dl.winehq.org/wine/source/${_WINE_MAJOR_VERSION}.${_WINE_MINOR_VERSION}/${WINE_P}.tar.bz2 -> ${WINE_P}.tar.bz2"
	elif (( (_WINE_MAJOR_VERSION >= 2) && (_WINE_MINOR_VERSION == 0) )); then
		SRC_URI="${SRC_URI}
			https://dl.winehq.org/wine/source/${_WINE_MAJOR_VERSION}.0/${WINE_P}.tar.xz -> ${WINE_P}.tar.xz"
	else
		SRC_URI="${SRC_URI}
			https://dl.winehq.org/wine/source/${_WINE_MAJOR_VERSION}.x/${WINE_P}.tar.xz -> ${WINE_P}.tar.xz"
	fi
	((_WINE_IS_STAGING)) && SRC_URI="${SRC_URI}
			https://github.com/wine-staging/wine-staging/archive/v${WINE_STAGING_PV}${_WINE_STAGING_SUFFIX}.tar.gz -> ${WINE_STAGING_P}.tar.gz"
fi

# INTERNAL HELPER wine.eclass Git support function definitions

# @FUNCTION: _wine_get_date_offset
# @INTERNAL
# @USAGE: <base_date> <base_offset> [offset_date_reference]*
#         (* passed-by-reference)
# @DESCRIPTION:
# This function takes a <base_data> and offsets it by a specified amount: <base_offset>.
# The date+offset is returned in the (passed-by-reference) variable [offset_date_reference],
# or stdout if [offset_date_reference] is unspecified.
_wine_get_date_offset() {
	(((2 <= $#) && ($# <= 3))) || die "${FUNCNAME[0]}(): invalid parameter count: ${#} (2-3)"
	local _base_date="${1}" _base_offset="${2}" _offset_date_reference="${3}" \
		_offset_date
	local -a _date_arguments_array=( "--rfc-3339=seconds" )

	# shellcheck disable=SC1001
	[[ "${_base_offset:}" =~ ^[-+] ]] || _base_offset="+${_base_offset}"
	_date_arguments_array+=( "-d" "${_base_date}${_base_offset}" )
	# shellcheck disable=SC2068
	_offset_date="$( date ${_date_arguments_array[@]} )" || die "date ${_date_arguments_array[*]} failed"
	[[ -z "${_offset_date}" ]] && return 1

	if [[ -z "${_offset_date_reference}" ]]; then
		echo "${_offset_date}"
	elif [[ "${_offset_date_reference}" =~ ${_WINE_VARIABLE_NAME_REGEXP} ]]; then
		declare -n offset_date="${_offset_date_reference}"
		# shellcheck disable=SC2034
		offset_date="${_offset_date}"
	else
		die "${FUNCNAME[0]}(): argument (3): invalid reference name (${_WINE_VARIABLE_NAME_REGEXP}): '${_offset_date_reference}'"
	fi
}

# @FUNCTION: _wine_git_commit_to_date
# @INTERNAL
# @USAGE: <git_directory> <git_commit_hash> [git_commit_date_reference]*
#         (* passed-by-reference)
# @DESCRIPTION:
# This function retrieves the commit date for the specified <git_commit_hash>
# Git commit SHA-1 hash.
# The function returns the Git commit date, either via stdout or the
# (passed-by-reference) variable: [git_commit_date_reference] ; if this
# variable is set.
# <git_directory> must reference a valid Git repository root directory.
_wine_git_commit_to_date() {
	(((2 <= $#) && ($# <= 3))) || die "${FUNCNAME[0]}(): invalid parameter count: ${#} (2-3)"

	local	_git_directory="${1%/}" _git_commit_hash="${2}" _git_commit_date_reference="${3}" \
		_git_commit_date

	if [[ ! -d "${_git_directory}/.git" ]]; then
		die "${FUNCNAME[0]}(): argument (1): path '${_git_directory}' is not a valid Git repository directory"
	fi

	pushd "${_git_directory}" >/dev/null || die "pushd failed"
	if [[ ! "${_git_commit_hash}" =~ ${_WINE_SHA1_REGEXP} ]]; then
		die "${FUNCNAME[0]}(): argument (2): invalid SHA-1 git commit '${_git_commit_hash}'"
	fi

	local -a _git_show_arguments_array=( "-s" "--format=%cI" "${_git_commit_hash}" )
	# shellcheck disable=SC2068
	_git_commit_date="$( git show ${_git_show_arguments_array[@]} )" || die "git show ${_git_show_arguments_array[*]} failed"
	popd >/dev/null || die "popd failed"
	[[ -z "${_git_commit_date}" ]] && return 1

	if [[ -z ${_git_commit_date_reference} ]]; then
		echo "${_git_commit_date}"
	elif [[ "${_git_commit_date_reference}" =~ ${_WINE_VARIABLE_NAME_REGEXP} ]]; then
		declare -n git_commit_date="${_git_commit_date_reference}"
		# shellcheck disable=SC2034
		git_commit_date="${_git_commit_date}"
	else
		die "${FUNCNAME[0]}(): argument (3): invalid reference name (${_WINE_VARIABLE_NAME_REGEXP}): '${_git_commit_date_reference}'"
	fi
}

# @FUNCTION: _wine_get_sieved_git_log
# @INTERNAL
# @USAGE: <git_directory> <start_date> <end_date> <git_log_array_reference*>
#         (* passed-by-reference)
# @DESCRIPTION:
# This internal function is used to support building app-emulation/wine-staging:9999, a multi-homed Git package.
# This function returns a Git log between the specified: <start_date> and <end_date> (exclusive),
# via the (passed-by-reference) array variable: <git_log_array_reference*>
# Either range limit specifier argument: <start_date> <end_date> ; can be omitted, by passing a: '.' .
# <git_directory> must reference a valid Git repository root directory.
_wine_get_sieved_git_log() {
	(($# == 4)) || die "${FUNCNAME[0]}(): invalid parameter count: ${#} (4)"

	# shellcheck disable=SC2124
	local	_git_directory="${1%/}" _start_date="${2}" _end_date="${3}" _git_log_array_reference="${4}" \
		_git_log
	if [[ ! -d "${_git_directory}/.git" ]]; then
		die "${FUNCNAME[0]}(): argument (1): path '${_git_directory}' is not a valid Git repository directory"
	fi

	local -a _git_log_arguments_array=( "--format=%H%P" "--reverse" "--all" )
	[[ "${_start_date}" != "." ]] && _git_log_arguments_array+=( "--after" "${_start_date}" )
	[[ "${_end_date}"   != "." ]] && _git_log_arguments_array+=( "--before" "${_end_date}" )
	pushd "${_git_directory}" >/dev/null || die "pushd failed"
	# shellcheck disable=SC2068
	_git_log="$( git log ${_git_log_arguments_array[@]} )" || die "git log ${_git_log_arguments_array[*]} failed"
	popd >/dev/null || die "popd failed"

	if [[ "${_git_log_array_reference}" =~ ${_WINE_VARIABLE_NAME_REGEXP} ]]; then
		declare -n git_log_array="${_git_log_array_reference}"
		# shellcheck disable=SC2034,SC2206
		git_log_array=( ${_git_log} )
	else
		die "${FUNCNAME[0]}(): argument (4): invalid reference name (${_WINE_VARIABLE_NAME_REGEXP}): '${_git_log_array_reference}'"
	fi
}

# @FUNCTION: _wine_staging_get_upstream_commit
# @INTERNAL
# @USAGE: <wine_staging_git_directory> <target_wine_staging_commit> [wine_git_commit_reference*]
#         (* passed-by-reference)
# @DESCRIPTION:
# This internal function is used to support building app-emulation/wine-staging:9999, a multi-homed Git package.
# This function returns the Wine Staging Git commit corresponding to the Wine Git commit: <target_wine_staging_commit>.
# The corresponding Wine Staging Git commit is returned via [wine_git_commit_reference*], if this argument is supplied,
# otherwise fallback to outputting the commit on stdout.
# <wine_staging_git_directory> must reference the root directory of a Wine Staging Git repository.
_wine_staging_get_upstream_commit() {
	(((2 <= $#) && ($# <= 3))) || die "${FUNCNAME[0]}(): invalid parameter count: ${#} (2-3)"

	local	_wine_staging_git_directory="${1%/}" _target_wine_staging_commit="${2}" _wine_git_commit_reference="${3}" \
		_patch_installer="patches/patchinstall.sh" _wine_git_commit wine_staging_version
	if [[ ! -d "${_wine_staging_git_directory}/.git" ]]; then
		die "${FUNCNAME[0]}(): argument (1): path '${_wine_staging_git_directory}' is not a valid Wine Staging Git repository directory"
	elif [[ ! -f "${_wine_staging_git_directory}/${_patch_installer}" ]]; then

		die "${FUNCNAME[0]}(): argument (1): path '${_wine_staging_git_directory}' does not contain the Wine Staging patch installer script '${_patch_installer}'"
	fi

	if [[ ! "${_target_wine_staging_commit}" =~ ${_WINE_SHA1_REGEXP} ]]; then
		die "${FUNCNAME[0]}(): argument (2): invalid Wine Staging SHA-1 git commit '${_target_wine_staging_commit}'"
	fi

	pushd "${_wine_staging_git_directory}" >/dev/null || die "pushd '${_wine_staging_git_directory}' failed"
	local -a _git_reset_arguments_array=( "--hard" "--quiet" "${_target_wine_staging_commit}" )
	# shellcheck disable=SC2068
	git reset ${_git_reset_arguments_array[@]} || die "git reset ${_git_reset_arguments_array[*]} failed"
	wine_staging_version="$( "${_patch_installer}" --version 2>/dev/null )" || die "bash script '${_patch_installer}' failed"
	popd >/dev/null || die "popd failed"

	_wine_git_commit="$(printf '%s' "${wine_staging_version}" | awk '{ if ($1=="commit") print $2}' 2>/dev/null)"
	if [[ ! "${_wine_git_commit}" =~ ${_WINE_SHA1_REGEXP} ]]; then
		die "Unable to get Wine commit corresponding to Wine Staging commit '${_target_wine_staging_commit}'"
	fi

	if [[ -z "${_wine_git_commit_reference}" ]]; then
		echo "${_wine_git_commit}"
	elif [[ "${_wine_git_commit_reference}" =~ ${_WINE_VARIABLE_NAME_REGEXP} ]]; then
		declare -n wine_git_commit="${_wine_git_commit_reference}"
		# shellcheck disable=SC2034
		wine_git_commit="${_wine_git_commit}"
	else
		die "${FUNCNAME[0]}(): argument (3): invalid reference name (${_WINE_VARIABLE_NAME_REGEXP}): '${_wine_git_commit_reference}'"
	fi
}

# @FUNCTION: _wine_staging_walk_git_tree
# @INTERNAL
# @USAGE: <wine_staging_git_directory> <wine_git_directory> <target_wine_git_commit> [wine_staging_commit_reference*]
#         (* passed-by-reference)
# @DESCRIPTION:
# This internal function is used to support building app-emulation/wine-staging:9999, a multi-homed Git package.
# This function converts a Wine Git commit into a date. Then this Git commit date is used to set the start date
# when obtaining a Wine Staging Git log. We walk through this Git log, ensuring that we following a
# parent->child commit path.
# When store a Wine Staging commit, if the corresponding Upstream Wine commit matches <target_wine_git_commit>.
# We continue searching the Wine Staging Git log writing over stored Wine Staging commit, if we find a newer
# (in time) match. We exit the loop with a match, if a subsequent Wine Staging child commit does not match our
# Upstream Wine commit <target_wine_git_commit>.
# The function returns the Wine Staging Git commit that corresponds to: <target_wine_git_commit>; either
# via [wine_staging_commit_reference*] - if this variable is specified - or directly to stdout.
# <wine_staging_git_directory> must reference the root directory of a Wine Staging Git repository.
# <wine_git_directory> must reference the root directory of a Wine Git repository.
_wine_staging_walk_git_tree() {
	(((3 <= $#) && ($# <= 4))) || die "${FUNCNAME[0]}(): invalid parameter count: ${#} (3-4)"

	local 	_wine_staging_git_directory="${1%/}" _wine_git_directory="${2%/}" \
		_target_wine_git_commit="${3}" _wine_staging_commit_reference="${4}" \
		_ilog _patch_installer="patches/patchinstall.sh" \
		_prev_wine_staging_commit _target_wine_staging_commit _wine_staging_commit _wine_staging_parent_commit

	if [[ ! -d "${_wine_staging_git_directory}/.git" ]]; then
		die "${FUNCNAME[0]}(): argument (1): path '${_wine_staging_git_directory}' is not a valid Wine Staging Git repository directory"
	elif [[ ! -f "${_wine_staging_git_directory}/${_patch_installer}" ]]; then

		die "${FUNCNAME[0]}(): argument (1): path '${_wine_staging_git_directory}' does not contain the Wine Staging patch installer script '${_patch_installer}'"
	fi

	if [[ ! -d "${_wine_git_directory}/.git" ]]; then
		die "${FUNCNAME[0]}(): argument (2): path '${_wine_git_directory}' is not a valid Wine Git repository directory"
	fi

	if [[ ! "${_target_wine_git_commit}" =~ ${_WINE_SHA1_REGEXP} ]]; then
		die "${FUNCNAME[0]}(): argument (3): invalid Wine SHA-1 git commit '${_target_wine_git_commit}'"
	fi

	declare target_wine_git_commit_date wine_git_commit
	declare -a wine_staging_git_log_array
	_wine_git_commit_to_date "${_wine_git_directory}" "${_target_wine_git_commit}" "target_wine_git_commit_date"
	pushd "${_wine_staging_git_directory}" >/dev/null || die "pushd '${_wine_staging_git_directory}' failed"
	_wine_get_sieved_git_log "${_wine_staging_git_directory}" "${target_wine_git_commit_date}" . "wine_staging_git_log_array"
	for (( _ilog=0 ; _ilog<${#wine_staging_git_log_array[@]} ; ++_ilog )); do
		_prev_wine_staging_commit="${_target_wine_staging_commit:-${_wine_staging_commit}}"
		_wine_staging_commit="${wine_staging_git_log_array[_ilog]:0:40}"
		_wine_staging_parent_commit="${wine_staging_git_log_array[_ilog]:40:40}"
		if [[ -n "${_prev_wine_staging_commit}" && ( "${_wine_staging_parent_commit}" != "${_prev_wine_staging_commit}" ) ]]; then
			continue
		fi

		_wine_staging_get_upstream_commit "${_wine_staging_git_directory}" "${_wine_staging_commit}" "wine_git_commit"
		if [[ "${wine_git_commit}" == "${_target_wine_git_commit}" ]]; then
			_target_wine_staging_commit="${_wine_staging_commit}"
		elif [[ -n "${_target_wine_staging_commit}" ]]; then
			break
		fi
	done
	if [[ -n "${_target_wine_staging_commit}" ]]; then
		local -a _git_reset_arguments_array=( "--hard" "--quiet" "${_target_wine_staging_commit}" )
	# shellcheck disable=SC2068
		git reset ${_git_reset_arguments_array[@]} || die "git reset ${_git_reset_arguments_array[*]} failed"
	fi
	popd >/dev/null || die "popd failed"
	unset -v target_wine_git_commit_date wine_git_commit wine_staging_git_log_array
	[[ -z "${_target_wine_staging_commit}" ]] && return 1

	if [[ -z ${_wine_staging_commit_reference} ]]; then
		echo "${_target_wine_staging_commit}"
	elif [[ "${_wine_staging_commit_reference}" =~ ${_WINE_VARIABLE_NAME_REGEXP} ]]; then
		declare -n target_wine_staging_commit="${_wine_staging_commit_reference}"
		# shellcheck disable=SC2034
		target_wine_staging_commit="${_target_wine_staging_commit}"
	else
		die "${FUNCNAME[0]}(): argument (4): invalid reference name (${_WINE_VARIABLE_NAME_REGEXP}): '${_wine_staging_commit_reference}'"
	fi
}

# @FUNCTION: _wine_find_closest_commit
# @INTERNAL
# @USAGE: <wine_staging_git_directory> <wine_git_directory> <wine_git_commit_reference>* <wine_staging_commit_reference>* [wine_commit_diff_reference]*
#         (* passed-by-reference)
# @DESCRIPTION:
# This internal function is used to support building app-emulation/wine-staging:9999, a multi-homed Git package.
# This function takes a Wine Git commit, <wine_git_commit_reference>, and uses this as the centre of temporal search
# through the Wine Git tree [-6 months -> +6 months]. At each Wine Git commit in this range, we look to see if there
# is valid downstream Wine Staging Git commit. We stop with a match, selecting the smallest amount -/+ Wine Git
# commit offset (from the originally specified Wine Git commit). If we find a match then we return both the
# Wine Git commit we find, via the reference variable <wine_git_commit_reference> and corresponding Wine Staging Git
# commit, via the reference variable <wine_staging_commit_reference>.
# If [wine_commit_diff_reference] is specified, then we pass back the commit count offset in this variable. This
# is the difference between the originally specified Wine Git commit <wine_git_commit_reference> and the Wine Git commit
# we have just found with out search.
# If however we don't find a valid downstream Wine Staging Git commit, within to the Wine Git search range
# then function returns an error value, and the reference variable <wine_staging_commit_reference> is left unset
# as is [wine_commit_diff_reference] (if specified).
# <wine_staging_git_directory> must reference the root directory of a Wine Staging Git repository.
# <wine_git_directory> must reference the root directory of a Wine Git repository.
_wine_find_closest_commit() {
	(((4 <= $#) && ($# <= 5))) || die "${FUNCNAME[0]}(): invalid parameter count: ${#} (4-5)"

	local 	_wine_staging_git_directory="${1%/}" _wine_git_directory="${2%/}" \
		_wine_commit_reference="${3}" _wine_staging_commit_reference="${4}" \
		_wine_commit_diff_reference="${5}" \
		_ilog _ilog_pre _ilog_post _ilog_total _wine_commit_date _wine_commit_diff _wine_reverse_date_limit _wine_forward_date_limit \
		_pre_commit_target_child _post_commit_target_parent _target_wine_commit _target_wine_staging_commit \
		_patch_installer="patches/patchinstall.sh"
	if [[ ! -d "${_wine_staging_git_directory}/.git" ]]; then
		die "${FUNCNAME[0]}(): argument (1): path '${_wine_staging_git_directory}' is not a valid Wine Staging Git repository directory"
	elif [[ ! -f "${_wine_staging_git_directory}/${_patch_installer}" ]]; then

		die "${FUNCNAME[0]}(): argument (1): path '${_wine_staging_git_directory}' does not contain the Wine Staging patch installer script '${_patch_installer}'"
	fi

	if [[ ! -d "${_wine_git_directory}/.git" ]]; then
		die "${FUNCNAME[0]}(): argument (2): path '${_wine_git_directory}' is not a valid Wine Git repository directory"
	fi

	if [[ ! "${_wine_commit_reference}" =~ ${_WINE_VARIABLE_NAME_REGEXP} ]]; then
		die "${FUNCNAME[0]}(): argument (3): invalid reference name (${_WINE_VARIABLE_NAME_REGEXP}): '${_wine_commit_reference}'"
	fi
	if [[ ! "${_wine_staging_commit_reference}" =~ ${_WINE_VARIABLE_NAME_REGEXP} ]]; then
		die "${FUNCNAME[0]}(): argument (4): invalid reference name (${_WINE_VARIABLE_NAME_REGEXP}): '${_wine_staging_commit_reference}'"
	fi
	declare -n wine_commit="${_wine_commit_reference}" wine_staging_commit="${_wine_staging_commit_reference}"

	declare -a wine_git_log_array
	pushd "${_wine_git_directory}" >/dev/null || die "pushd '${_wine_git_directory}' failed"
	_wine_git_commit_to_date "${_wine_git_directory}" "${wine_commit}" "_wine_commit_date"
	_wine_get_date_offset "${_wine_commit_date}" "${_WINE_GIT_DATE_ROFFSET}" "_wine_reverse_date_limit"
	_wine_get_date_offset "${_wine_commit_date}" "${_WINE_GIT_DATE_FOFFSET}" "_wine_forward_date_limit"
	_wine_get_sieved_git_log "${_wine_git_directory}" "${_wine_reverse_date_limit}" "${_wine_forward_date_limit}" "wine_git_log_array"

	_ilog_pre=-1
	_ilog_post=_ilog_total=${#wine_git_log_array[@]}
	for _ilog in "${!wine_git_log_array[@]}"; do
		if [[ "${wine_commit}" == "${wine_git_log_array[_ilog]:0:40}" ]]; then
			: $((_ilog_pre=_ilog_post=_ilog))
			break
		fi
	done
	while (( (0 <= _ilog_pre) || (_ilog_post < _ilog_total) )); do
		# Go backwards
		if ((_ilog_pre >= 0)); then
			_pre_commit_target_child="${wine_git_log_array[_ilog_pre]:40:40}"
			while ((--_ilog_pre >= 0)); do
				if [[ "${_pre_commit_target_child}" == "${wine_git_log_array[_ilog_pre]:0:40}" ]]; then
					break
				fi
			done
			if ((_ilog_pre >= 0)); then
				_target_wine_commit="${wine_git_log_array[_ilog_pre]:0:40}"
				_wine_commit_diff=$((_ilog_pre - _ilog))
				if _wine_staging_walk_git_tree "${_wine_staging_git_directory}" "${_wine_git_directory}" "${_target_wine_commit}" "_target_wine_staging_commit"; then
					break
				fi
			fi
		fi
		# Go forwards
		if ((_ilog_post < _ilog_total)); then
			_post_commit_target_parent="${wine_git_log_array[_ilog_post]:0:40}"
			while ((++_ilog_post < _ilog_total)); do
				if [[ "${_post_commit_target_parent}" == "${wine_git_log_array[_ilog_post]:40:40}" ]]; then
					break
				fi
			done
			if ((_ilog_post < _ilog_total)); then
				_target_wine_commit="${wine_git_log_array[_ilog_post]:0:40}"
				_wine_commit_diff=$(( _ilog_post - _ilog ))
				if _wine_staging_walk_git_tree "${_wine_staging_git_directory}" "${_wine_git_directory}"  "${_target_wine_commit}" "_target_wine_staging_commit"; then
					break
				fi
			fi
		fi
	done
	unset -v wine_git_log_array
	popd >/dev/null || die "popd failed"

	[[ -z "${_target_wine_staging_commit}" ]] && return 1

	wine_commit="${_target_wine_commit}"
	wine_staging_commit="${_target_wine_staging_commit}"
	if [[ -z "${_wine_commit_diff_reference}" ]]; then
		return 0
	elif [[ ! "${_wine_commit_diff_reference}" =~ ${_WINE_VARIABLE_NAME_REGEXP} ]]; then
		die "${FUNCNAME[0]}(): argument (5): invalid reference name (${_WINE_VARIABLE_NAME_REGEXP}): '${_wine_commit_diff_reference}'"
	fi
	declare -n wine_commit_diff="${_wine_commit_diff_reference}"
	# shellcheck disable=SC2034
	wine_commit_diff="${_wine_commit_diff}"
}

# @FUNCTION: _wine_display_closest_commit_message
# @INTERNAL
# @USAGE: <target_wine_commit> <target_wine_staging_commit> <wine_commit_diff>
# @DESCRIPTION:
# This internal function is used to support building app-emulation/wine-staging:9999, a multi-homed Git package.
# It pretty prints suggested Wine and Wine Staging Git commits, in the event the end user attempts
# to build this package against an unsupported Wine Git commit. The output includes the numerical difference,
# in commit count, between the target Wine Git commit and the suggested/ supported Wine Git commit.
_wine_display_closest_commit_message() {
	(($# == 3)) || die "${FUNCNAME[0]}(): invalid parameter count: ${#} (3)"

	local 	_target_wine_commit="${1}" _target_wine_staging_commit="${2}" \
		_wine_commit_diff="${3}" \
		_diff_message="no offset" _plural=""
	if [[ ! "${_target_wine_commit}" =~ ${_WINE_SHA1_REGEXP} ]]; then
		die "${FUNCNAME[0]}(): argument (1): invalid Wine SHA-1 git commit '${_target_wine_commit}'"
	elif [[ ! "${_target_wine_staging_commit}" =~ ${_WINE_SHA1_REGEXP} ]]; then
		die "${FUNCNAME[0]}(): argument (2): invalid Wine Staging SHA-1 git commit '${_target_wine_staging_commit}'"
	fi

	((_wine_commit_diff*_wine_commit_diff != 1)) && _plural="s"
	((_wine_commit_diff < 0))  && _diff_message="offset $((-_wine_commit_diff)) commit${_plural} backward"
	((_wine_commit_diff > 0))  && _diff_message="offset $((_wine_commit_diff)) commit${_plural} forward"

	eerror "Try rebuilding this package using the closest supported Wine commit (${_diff_message}):"
	eerror "EGIT_OVERRIDE_COMMIT_WINE=\"${_target_wine_commit}\" emerge -v =${CATEGORY}/${P}"
	eerror "... or:"
	eerror "EGIT_OVERRIDE_COMMIT_WINE_STAGING_WINE_STAGING=\"${_target_wine_staging_commit}\" emerge -v =${CATEGORY}/${P}"
	eerror
}

# EXTERNAL HELPER wine.eclass Git support function definitions

# @FUNCTION: wine_sieve_arrays_by_git_commit
# @USAGE: <git_directory> <array_commits|array_patch_files>* ... [array_commits|array_patch_files]*
#         (* passed-by-reference)
# @DESCRIPTION:
# This function checks the specified Git repository, current HEAD, for the presence of a list of
# Git array_commits.
# Takes a list of variables, passed by reference, which should all be arrays.
#  These arrays can contain a mixture of elements, of either:
#   array_commits     : array of SHA-1 Git commit hashes
#   array_patch_files : array of patch files, which must contain one, or more, embedded SHA-1 Git commit hashes
#                       (the hashes must all be clustered, contiguously, at the head of each patch file)
# These Git commit hashes are individually tested to see if they have been committed to HEAD, of the Git Source
# directory tree. If a Git commit hash is in tree then delete the current array entry.
# <git_directory> must reference a valid Git repository root directory.
wine_sieve_arrays_by_git_commit() {
	(($# >= 2))  || die "${FUNCNAME[0]}(): invalid number of arguments: ${#} (2-)"

	local _commit_hash _git_directory _git_log _i_arg=1 _i_array _line _patch_array_reference _patch_file

	_git_directory="${1%/}"
	if [[ ! -d "${_git_directory}/.git" ]]; then
		die "${FUNCNAME[0]}(): argument (1): path '${_git_directory}' is not a valid Git repository directory"
	fi

	pushd "${_git_directory}" >/dev/null || die "pushd failed"
	local -a _git_log_arguments_array=( "--pretty=format:%H" )
	# shellcheck disable=SC2068
	_git_log="$( git log ${_git_log_arguments_array[@]} 2>/dev/null )" || die "git log ${_git_log_arguments_array[*]} failed"
	popd >/dev/null || die "popd failed"

	shift 1
	for _patch_array_reference; do
		if [[ ! "${_patch_array_reference}" =~ ${_WINE_VARIABLE_NAME_REGEXP} ]]; then
			die "${FUNCNAME[0]}(): argument ($((_i_arg+=1))): invalid reference name: '${_patch_array_reference}'"
		fi

		declare -n patch_array="${_patch_array_reference}"
		for _i_array in "${!patch_array[@]}"; do
			if [[ "${patch_array[_i_array]}" =~ ${_WINE_SHA1_REGEXP} ]]; then
				[[ "${_git_log}" =~ ${patch_array[_i_array]} ]] && unset -v 'patch_array[_i_array]'
				continue
			fi

			[[ -f "${patch_array[_i_array]}" ]] || die "patch file: '${patch_array[_i_array]}' does not exist"

			_line=0
			while
				: $((++_line))
				_commit_hash="$( sed -n -e "${_line}"'s/^.*\([[:xdigit:]]\{40\}\).*$/\1/p' "${patch_array[_i_array]}" )"
				[[ "${_commit_hash}" =~ ${_WINE_SHA1_REGEXP} ]]
			do
				[[ "${_git_log}" =~ ${_commit_hash} ]] || continue

				_patch_file="$(basename "${patch_array[_i_array]}")"
				einfo "Excluding patch ${_patch_file} ... parent of (HEAD) Git commit: ${_commit_hash}"
				unset -v 'patch_array[_i_array]'
				break
			done
		done
	done
}

# @FUNCTION: wine_get_git_commit_info
# @USAGE: <git_directory> [git_commit_hash]* [git_commit_date]*
#         (* passed-by-reference)
# @DESCRIPTION:
# This function retrieves specified information about the specified Git repository HEAD.
# The function returns the Git commit hash <git_commit_hash> and the date <git_commit_date>,
# of the current HEAD Git commit.
# Both the reference variables, used to return these two values, are optional.
# <git_directory> must reference a valid Git repository root directory.
wine_get_git_commit_info() {
	(((1 <= $#) && ($# <= 3))) || die "${FUNCNAME[0]}(): invalid number of arguments: ${#} (1-3)"

	local _git_directory="${1%/}" _commit_hash _git_commit_hash _git_commit_date

	if [[ ! -d "${_git_directory}/.git" ]]; then
		die "${FUNCNAME[0]}(): argument (1): path '${_git_directory}' is not a valid Git repository directory"
	fi

	pushd "${_git_directory}" >/dev/null || die "pushd failed"
	local -a _git_revparse_arguments_array=( "HEAD" )
	# shellcheck disable=SC2068
	_commit_hash="$( git rev-parse ${_git_revparse_arguments_array[@]} )" || die "git rev-parse ${_git_revparse_arguments_array[*]} failed "
	if [[ ! "${_commit_hash}" =~ ${_WINE_SHA1_REGEXP} ]]; then
		die "unable to determine current HEAD Git commit for repository: '${_git_directory}'"
	fi

	if [[ -n "${2}" && "${2}" =~ ${_WINE_VARIABLE_NAME_REGEXP} ]]; then
		declare -n _git_commit_hash="${2}"
		# shellcheck disable=SC2034
		_git_commit_hash="${_commit_hash}"
	fi

	if [[ -n "${3}" && "${3}" =~ ${_WINE_VARIABLE_NAME_REGEXP} ]]; then
		declare -n _git_commit_date="${3}"
		local -a _git_show_arguments_array=( "-s" "--format=%cd" "${_commit_hash}" )
		# shellcheck disable=SC2068
		_git_commit_date="$( git show ${_git_show_arguments_array[@]} )" || die "git show ${_git_show_arguments_array[*]} failed"
	fi
	popd >/dev/null || die "popd failed"
}

# @FUNCTION: wine_staging_git_src_unpack
# @DESCRIPTION:
# This function is used to support building app-emulation/wine-staging:9999, a multi-homed Git package.
# This function tests for EGIT_OVERRIDE_* env variables for both Wine Staging and Wine.
# Using that ordering of these tests, prioritize EGIT overrides, specified for Wine Staging.
# Unpack the prioritized first repository. Then test to ensure that this repository
# Git HEAD will support building against the secondary repository.
wine_staging_git_src_unpack() {
	(($# == 0)) || die "${FUNCNAME[0]}(): invalid number of arguments: ${#} (0)"

	if [[ -n "${EGIT_OVERRIDE_COMMIT_WINE_STAGING_WINE_STAGING:-${EGIT_OVERRIDE_BRANCH_WINE_STAGING_WINE_STAGING}}" ]]; then
		# References are relative to Wine Staging git tree (Wine Staging Git tree -> Wine Git tree)
		# Use env variables "EGIT_OVERRIDE_COMMIT_WINE_STAGING_WINE_STAGING" or "EGIT_OVERRIDE_BRANCH_WINE_STAGING_WINE_STAGING" to reference Wine Staging git tree
		#588604 Use git-r3 internal functions for secondary Wine Staging repository
		ebegin "(subshell): Wine Staging git reference specified. Building Wine git with Wine Staging patchset ..."
		(
			EGIT_CHECKOUT_DIR="${_WINE_STAGING_DIR}" EGIT_REPO_URI="${EGIT_REPO_WINE_STAGING}" git-r3_src_unpack
			wine_staging_target_commit="${EGIT_VERSION}"
			_wine_staging_get_upstream_commit "${_WINE_STAGING_DIR}" "${wine_staging_target_commit}" "wine_commit" || die "_wine_staging_get_upstream_commit failed"
			EGIT_OVERRIDE_COMMIT_WINE="${wine_commit}" git-r3_src_unpack
			einfo "Building Wine commit '${wine_commit}' referenced by Wine Staging commit '${wine_staging_target_commit}' ..."
		)
		eend
	else
		# References are relative to Wine git tree (Wine Git tree -> Wine Staging Git tree)
		# Use env variables "EGIT_OVERRIDE_COMMIT_WINE" or "EGIT_OVERRIDE_BRANCH_WINE" to reference Wine git tree
		#588604 Use git-r3 internal functions for secondary Wine Staging repository
		ebegin "(subshell): Wine git reference specified or inferred. Building Wine git with with Wine Staging patchset ..."
		(
			git-r3_src_unpack
			wine_commit="${EGIT_VERSION}"
			wine_target_commit="${wine_commit}"
			EGIT_OVERRIDE_BRANCH_WINE_STAGING_WINE_STAGING="" EGIT_OVERRIDE_BRANCH_WINE_STAGING_WINE_STAGING="" \
			EGIT_CHECKOUT_DIR="${_WINE_STAGING_DIR}" EGIT_REPO_URI="${EGIT_REPO_WINE_STAGING}" git-r3_src_unpack
			wine_staging_commit=""; wine_commit_offset=""
			if ! _wine_staging_walk_git_tree "${_WINE_STAGING_DIR}" "${S}" "${wine_commit}" "wine_staging_commit" ; then
				_wine_find_closest_commit "${_WINE_STAGING_DIR}" "${S}" "wine_commit" "wine_staging_commit" "wine_commit_offset" \
					&& _wine_display_closest_commit_message "${wine_commit}" "${wine_staging_commit}" "${wine_commit_offset}"
				die "Failed to find Wine Staging git commit corresponding to supplied Wine git commit '${wine_target_commit}' ."
				exit 1
			fi
			EGIT_OVERRIDE_COMMIT_WINE_STAGING_WINE_STAGING="${wine_staging_commit}" \
			EGIT_CHECKOUT_DIR="${_WINE_STAGING_DIR}" EGIT_REPO_URI="${EGIT_REPO_WINE_STAGING}" git-r3_src_unpack
			einfo "Building Wine Staging commit '${wine_staging_commit}' corresponding to Wine commit '${wine_target_commit}' ..."
		)
		eend
	fi
}

# INTERNAL HELPER wine.eclass general support function definitions

# @FUNCTION: _wine_env_vcs_variable_prechecks
# @INTERNAL
# @DESCRIPTION:
# This function tests for invalid EGIT_GIT env variable overrides, for the packages:
#  app-emulation/wine-staging:9999 app-emulation/wine-vanilla:9999
_wine_env_vcs_variable_prechecks() {
	(($# == 0)) || die "${FUNCNAME[0]}(): invalid number of arguments: ${#} (0)"

	local _env_error=0
	if [[ -n "${EGIT_COMMIT:-${EGIT_BRANCH}}" || -n "${EGIT_WINE_COMMIT:-${EGIT_WINE_BRANCH}}" ]]; then
		_env_error=1
	elif [[ -n "${EGIT_STAGING_COMMIT:-${EGIT_STAGING_BRANCH}}" ]]; then
		_env_error=$((_WINE_IS_STAGING))
	fi

	if (( _env_error )); then
		eerror "To override fetched wine repository properties, use:"
		eerror "  EGIT_OVERRIDE_BRANCH_WINE"
		eerror "  EGIT_OVERRIDE_COMMIT_WINE"
		if ((_WINE_IS_STAGING)); then
			eerror "OR to override fetched wine-staging repository properties, use:"
			eerror "  EGIT_OVERRIDE_BRANCH_WINE_STAGING_WINE_STAGING"
			eerror "  EGIT_OVERRIDE_COMMIT_WINE_STAGING_WINE_STAGING"
		fi
		eerror
	fi

	return $((_env_error))
}

# @FUNCTION: _wine_build_environment_prechecks
# @INTERNAL
# @DESCRIPTION:
# This function tests for invalid gcc or clang versions, for the packages:
#  app-emulation/wine-staging app-emulation/wine-vanilla
_wine_build_environment_prechecks() {
	(($# == 0)) || die "${FUNCNAME[0]}(): invalid number of arguments: ${#} (0)"

	if ! use abi_x86_64 || [[ "${MERGE_TYPE}" = "binary" ]]; then
		return 0
	fi

	local _using_gcc _using_clang _gcc_major_version _gcc_minor_version _clang_major_version _clang_minor_version
	_using_gcc=$(tc-is-gcc)
	_using_clang=$(tc-is-clang)
	_gcc_major_version=$(gcc-major-version)
	_gcc_minor_version=$(gcc-minor-version)
	_clang_major_version=$(clang-major-version)
	_clang_minor_version=$(clang-minor-version)

	if (( _using_gcc && ( _gcc_major_version < 4 || (_gcc_major_version == 4 && _gcc_minor_version < 4) ) )); then
		eerror "You need >=sys-devel/gcc-4.4.x to compile 64-bit Wine"
		die "_wine_build_environment_prechecks() failed"
	elif (( _using_clang && ( _clang_major_version < 3 || (_clang_major_version == 3 && _clang_minor_version < 8) ) )); then
		eerror "You need >=sys-devel/clang-3.8 to compile 64-bit wine"
		die "_wine_build_environment_prechecks() failed"
	fi
	if (( _using_gcc && (_gcc_major_version == 5 && _gcc_minor_version <= 3) )); then
		ewarn "=sys-devel/gcc-5.0.x ... =sys-devel/gcc-5.3.x - introduced compilation bugs"
		ewarn "and are no longer supported byGentoo's Toolchain Team."
		ewarn "If your ebuild fails the compiler checks in the src-configure phase then:"
		ewarn "update your compiler, switch to <sys-devel-gcc-5.0.x or >=sys-devel/gcc-5.4.x"
		ewarn "See https://bugs.gentoo.org/610752"
	fi
	if use abi_x86_32 && use opencl && [[ "$(eselect opencl show 2>/dev/null)" == "intel" ]]; then
		eerror "You cannot build wine with USE=+opencl because dev-util/intel-ocl-sdk is 64-bit only."
		eerror "See https://bugs.gentoo.org/487864"
		eerror
		return 1
	fi
}

# @FUNCTION: _wine_gcc_specific_pretests
# @INTERNAL
# @DESCRIPTION:
# This function tests for an invalid gcc version, for the packages:
#  app-emulation/wine-staging app-emulation/wine-vanilla
_wine_gcc_specific_pretests() {
	(($# == 0)) || die "${FUNCNAME[0]}(): invalid number of arguments: ${#} (0)"

	tc-is-gcc 		|| return 0
	[[ "${MERGE_TYPE}" = "binary" ]] && return 0

	local _using_abi_x86_64 _gcc_major_version _gcc_minor_version
	_using_abi_x86_64=$(use abi_x86_64)
	_gcc_major_version=$(gcc-major-version)
	_gcc_minor_version=$(gcc-minor-version)

	#549768 sys-devel/gcc-5 miscompiles ms_abi functions (breaks app-emulation/wine)
	if (( _using_abi_x86_64 && (_gcc_major_version == 5 && _gcc_minor_version <= 2) )); then
		ebegin "(subshell): checking for =sys-devel/gcc-5.1.x , =sys-devel/gcc-5.2.0 MS X86_64 ABI compiler bug ..."
		$(tc-getCC) -O2 "${WORKDIR}/${WINE_EBUILD_COMMON_P%/}/files/pr66838.c" -o "${T}/pr66838" \
			|| die "cc compilation failed: pr66838 test"
		# Run in a subshell to prevent "Aborted" message
		if ! ( "${T}"/pr66838 || false ) >/dev/null 2>&1; then
			eerror "(subshell): =sys-devel/gcc-5.1.x , =sys-devel/gcc-5.2.0 MS X86_64 ABI compiler bug detected."
			eerror "64-bit wine cannot be built with =sys-devel/gcc-5.1 or initial patchset of =sys-devel/gcc-5.2.0."
			eerror "Please re-emerge wine using an unaffected version of gcc or apply"
			eerror "Re-emerge the latest =sys-devel/gcc-5.2.0 ebuild,"
			eerror "or use gcc-config to select a different compiler version."
			eerror "See https://bugs.gentoo.org/549768"
			eerror
			return 1
		fi
	fi

	#574044 sys-devel/gcc-5.3.0 miscompiles app-emulation/wine
	if (( _using_abi_x86_64 && (_gcc_major_version == 5) && (_gcc_minor_version == 3) )); then
		ebegin "(subshell): checking for =sys-devel/gcc-5.3.0 X86_64 misaligned stack compiler bug ..."
		# Compile in a subshell to prevent "Aborted" message
		if ! ( $(tc-getCC) -O2 -mincoming-stack-boundary=3 "${WORKDIR}/${WINE_EBUILD_COMMON_P%/}/files/pr69140.c" -o "${T}/pr69140" ) >/dev/null 2>&1; then
			eerror "(subshell): =sys-devel/gcc-5.3.0 X86_64 misaligned stack compiler bug detected."
			eerror "Please re-emerge the latest =sys-devel/gcc-5.3.0 ebuild,"
			eerror "or use gcc-config to select a different compiler version."
			eerror "See https://bugs.gentoo.org/574044"
			eerror
			return 1
		fi
	fi
}

# @FUNCTION: _wine_gcc_specific_pretests
# @INTERNAL
# @DESCRIPTION:
# This function tests generic compiler support for critical functionality, for the packages:
#  app-emulation/wine-staging app-emulation/wine-vanilla
_wine_generic_compiler_pretests() {
	(($# == 0)) || die "${FUNCNAME[0]}(): invalid number of arguments: ${#} (0)"

	use abi_x86_64 		|| return 0
	[[ "${MERGE_TYPE}" = "binary" ]] && return 0

	ebegin "(subshell): checking compiler support for (64-bit) builtin_ms_va_list ..."
	# Compile in a subshell to prevent "Aborted" message
	if ! ( $(tc-getCC) -O2 "${WORKDIR}/${WINE_EBUILD_COMMON_P%/}/files/builtin_ms_va_list.c" -o "${T}/builtin_ms_va_list" >/dev/null 2>&1 ); then
		eerror "(subshell): $(tc-getCC) does not support builtin_ms_va_list."
		eerror "Please re-emerge using a compiler (version) that supports building 64-bit Wine."
		eerror "Use >=sys-devel/gcc-4.4 or >=sys-devel/clang-3.8 to build ${CATEGORY}/${PN}."
		eerror
		return 1
	fi
}

# @FUNCTION: wine_src_set_staging_versioning
# @INTERNAL
# @DESCRIPTION:
# This function alters the Wine Source, to set the Wine Staging version / branding.
# Used for the package: 
#  app-emulation/wine-staging
# Staging branding is applied to applied to the Wine version, reported by:
#  wine --version
#  winecfg
wine_src_set_staging_versioning() {
	(($# == 0)) || die "${FUNCNAME[0]}(): invalid number of arguments: ${#} (0)"

	if [[ -n "${_WINE_STAGING_SUFFIX}" ]]; then
		sed -i -e 's/Staging/Staging'"${_WINE_STAGING_SUFFIX}"'/' "${S}/libs/wine/Makefile.in" || die "sed failed"
	fi
	if [[ -n "${_WINE_STAGING_REVISION}" ]]; then
		sed -i -e '/^AC_INIT(.*)$/{s/\[Wine\]/\[Wine Staging\]/}' \
			-e '/^m4_define/{s/\[\\1\]/\[\\1\]'"${_WINE_STAGING_REVISION}"'/}' \
			"${S}/configure.ac" || die "sed failed"
	else
		sed -i -e '/^AC_INIT(.*)$/{s/\[Wine\]/\[Wine Staging\]/}' "${S}/configure.ac" || die "sed failed"
	fi
}

# @FUNCTION: _wine_src_disable_man_file
# @USAGE: <makefile> <man_file> <locale>
# @DESCRIPTION:
# This function alters the Wine Source, to disable a specified (non-english)
# locale man page.
_wine_src_disable_man_file() {
	(($# == 3))  || die "${FUNCNAME[0]}(): invalid number of arguments: ${#} (3)"

	# Not all manpages are translated - so always install all English locale manpages
	[[ "${3}" = "en" ]] && return

	local makefile="${1}" man_file="${2}" locale="\\.${3}\\.UTF-8"
	sed -i -e "\\|${man_file}${locale}\\.man\\.in|d" "${makefile}" || die "sed failed"
}

# @FUNCTION: _wine_deregister_current_variant
# @INTERNAL
# @DESCRIPTION:
# This functions deregisters the current: app-emulation/wine-staging, app-emulation/wine-vanilla
# variant, with the eselect-wine module.
_wine_deregister_current_variant() {
	(($# == 0)) || die "${FUNCNAME[0]}(): invalid number of arguments: ${#} (0)"

	local _variant="${PN#wine-}"
	local -a _eselect_wine_arguments=( "--force" "--verbose" "--wine" "--${_variant}" )

	# shellcheck disable=SC2068
	eselect wine deregister ${_eselect_wine_arguments[@]} "${P}" \
		|| die "eselect wine deregister ${_eselect_wine_arguments[*]} \"${P}\" failed"
}

# @FUNCTION: _wine_register_new_variant
# @INTERNAL
# @DESCRIPTION:
# This functions registers a new: app-emulation/wine-staging, app-emulation/wine-vanilla
# variant, with the eselect-wine module.
_wine_register_new_variant() {
	(($# == 0)) || die "${FUNCNAME[0]}(): invalid number of arguments: ${#} (0)"

	local _variant="${PN#wine-}"
	local -a _eselect_wine_arguments

	_eselect_wine_arguments=( "--verbose" "--wine" "--${_variant}" )
	# Hack! Replace spaces with "non-breaking space" UTF-8 codes - to avoid argument splitting
	[[ -z "${WINE_GIT_COMMIT_DATE}" ]] || _eselect_wine_arguments+=( "--date=${WINE_GIT_COMMIT_DATE// / }" )
	[[ -z "${WINE_GIT_COMMIT_HASH}" ]] || _eselect_wine_arguments+=( "--commit=${WINE_GIT_COMMIT_HASH}" )
	# shellcheck disable=SC2068
	eselect wine register ${_eselect_wine_arguments[@]} "${P}" \
		|| die "eselect wine register ${_eselect_wine_arguments[*]} \"${P}\" failed"

	_eselect_wine_arguments=( "--force" "--verbose" "--wine" "--${_variant}" "--if-unset" )
	# shellcheck disable=SC2068
	eselect wine set ${_eselect_wine_arguments[@]} "${P}" \
		|| die "eselect wine set ${_eselect_wine_arguments[*]} \"${P}\" failed"
}

# EXTERNAL HELPER wine.eclass general support function definitions

# @FUNCTION: wine_eapply_bin
# @DESCRIPTION:
# Use patch patchbin to apply all binary patches from the array variable PATCHES_BIN
wine_eapply_bin() {
	(($# == 0)) || die "${FUNCNAME[0]}(): invalid number of arguments: ${#} (0)"

	local _patch_file _patch_path
	# shellcheck disable=SC2068
	for _patch_path in ${PATCHES_BIN[@]}; do
		_patch_file="$(basename "${_patch_path}")"
		einfo "Applying ${_patch_file} (binary) ..."
		if ! patchbin --nogit < "${_patch_path}" >"/${T}/${_patch_file}.log"; then
			cat "${T}/${_patch_file}.log"
			printf " %s
"  "[ !! ]"
			die  "patchbin failed with ${_patch_path}"
		fi
		printf " %s
" "[ ok ]"
	done
}

# @FUNCTION: wine_eapply_staging_patchset
# @DESCRIPTION:
# This function applies the Wine Staging patchset, for the package:
#  app-emulation/wine-staging
# See: https://github.com/wine-staging/wine-staging
wine_eapply_staging_patchset() {
	(($# == 0)) || die "${FUNCNAME[0]}(): invalid number of arguments: ${#} (0)"

	local _staging_patches_dir="${_WINE_STAGING_DIR}/patches"

	local -a _staging_exclude_patchsets
	ewarn "Applying the Wine Staging patchset. Any bug reports to Wine Bugzilla"
	ewarn "should explicitly state that Wine Staging was used."

	# Declare Wine Staging excluded patchsets
	_staging_exclude_patchsets=( "configure-OSMesa" "winhlp32-Flex_Workaround" )
	use gstreamer && _staging_exclude_patchsets+=( "quartz-NULL_TargetFormat" )
	if [[ "${WINE_PV}" == "2.2" ]]; then
		# https://bugs.winehq.org/show_bug.cgi?id=42512
		_staging_exclude_patchsets+=( "wined3d-buffer_create" )
	fi

	if has esync ${IUSE} && use esync; then
		_staging_exclude_patchsets+=( "msvfw32-ICGetDisplayFormat" )
	fi

	use pipelight || _staging_exclude_patchsets+=( "Pipelight" )
	if [[ "${WINE_PV}" == "1.9.5" ]]; then
		#577198
		use nls || _staging_exclude_patchsets+=( "makefiles-Disabled_Rules" )
	fi

	# Process Wine Staging excluded patchsets
	# shellcheck disable=SC2206
	local indices=( ${!_staging_exclude_patchsets[*]} )
	for ((i=0; i<${#indices[*]}; i++)); do
		if grep -q "${_staging_exclude_patchsets[indices[i]]}" "${_staging_patches_dir}/patchinstall.sh"; then
			einfo "Excluding Wine Staging patchset: \"${_staging_exclude_patchsets[indices[i]]}\""
		else
			einfo "Ignoring Wine Staging patchset: \"${_staging_exclude_patchsets[indices[i]]}\""
			unset -v '_staging_exclude_patchsets[indices[i]]'
		fi
	done

	# Disable Upstream (Wine Staging) about tab customisation, for winecfg utility, to support our own version
	((_WINE_MAJOR_VERSION > 1)) && if [[ -f "${_staging_patches_dir}/winecfg-Staging/0001-winecfg-Add-staging-tab-for-CSMT.patch" ]]; then
		sed -i '/SetDlgItemTextA(hDlg, IDC_ABT_PANEL_TEXT, PACKAGE_VERSION " (Staging)");/{s/PACKAGE_VERSION " (Staging)"/PACKAGE_VERSION/}' \
			"${_staging_patches_dir}/winecfg-Staging/0001-winecfg-Add-staging-tab-for-CSMT.patch" \
			|| die "sed failed"
	fi

	# Launch wine-staging patcher in a subshell, using eapply as a backend, and gitapply.sh as a backend for binary patches
	ebegin "Running Wine-Staging patch installer"
	(
		# Use a sed hack to add EAPI 7 support to the patchinstall.sh script
		sed -i 	-e '$ d' -e '/^# Critical error, abort$/,+6d' \
			-e '/^[[:blank:]]*abort ".*"$/{s/abort /die /g}' \
			-e 's/exit 1$/die/g' -e 's/epatch/eapply/g' \
			"${_staging_patches_dir}/patchinstall.sh" \
			|| die "sed failed"
		# shellcheck disable=SC2068
		set -- DESTDIR="${S}" --backend=eapply --no-autoconf --all ${_staging_exclude_patchsets[@]/#/-W }
		cd "${_staging_patches_dir}" || die "cd failed"
		# shellcheck source=/dev/null
		source "${_staging_patches_dir}/patchinstall.sh"
	)
	eend

}

# @FUNCTION: wine_eapply_esync_patchset
# @USAGE: <esync_patchset_directory>
# @DESCRIPTION:
# This function supports the packages:
#   app-emulation/wine-staging app-emulation/wine-vanilla
# This function applies the wine-esync patchset to the PWD - typically "${S}".
# <esync_patchset_directory> should be set to the root directory of the unpacked esync
# tarball.
# See: https://github.com/zfigura/wine/blob/esync/README.esync
wine_eapply_esync_patchset() {
	(($# == 1)) || die "${FUNCNAME[0]}(): invalid number of arguments: ${#} (1)"

	local _esync_patchsets_base_directory="${1%/}" \
		_i_array _esync_error=0 _esync_patchset_directory _esync_rebased_patchset
	local -a _base_commit _esync_patchset_commits _sieved_esync_patchset_commits
	if [[ ! -d "${_esync_patchsets_base_directory}" ]]; then
		die "${FUNCNAME[0]}(): argument (1): path '${_esync_patchsets_base_directory}' is not a valid directory"
	fi

	_esync_patchset_commits=(
		"f8e0bd1b0d189d5950dc39082f439cd1fc9569d5" "12276796c95007fc12eb38a41ca25b4daee7e1b3"
		"a7aa192a78d02d28f2bbae919a3f5c726e4e9e60" "c61c33ee66ea0e97450ac793ebc4ac41a1ccc793"
		"57212f64f8e4fef0c63c633940e13d407c0f2069" "24f47812165a5dcb2b22825e47ccccbbd7437b8b"
		"2f17e0112dc0af3f0b246cf377e2cb8fd7a6cf58" "2600ecd4edfdb71097105c74312f83845305a4f2"
	)

	case "${WINE_PV}" in
		3.0.[1-4]-rc[1-9]|3.0.[1-4]|3.0-rc[1-6]|3.[0-2])
			_esync_rebased_patchset="f8e0bd1b0d189d5950dc39082f439cd1fc9569d5"
			;;
		3.[3-5])
			_esync_rebased_patchset="a7aa192a78d02d28f2bbae919a3f5c726e4e9e60"
			;;
		3.[6-9]|3.1[0-3])
			_esync_rebased_patchset="c61c33ee66ea0e97450ac793ebc4ac41a1ccc793"
			;;
		3.1[4-6])
			_esync_rebased_patchset="57212f64f8e4fef0c63c633940e13d407c0f2069"
			;;
		3.1[7-8])
			_esync_rebased_patchset="24f47812165a5dcb2b22825e47ccccbbd7437b8b"
			;;
		3.19)
			_esync_rebased_patchset="2f17e0112dc0af3f0b246cf377e2cb8fd7a6cf58"
			;;
		3.2[0-1]|4.0-rc[1-9]|4.0)
			_esync_rebased_patchset="2600ecd4edfdb71097105c74312f83845305a4f2"
			;;
		9999)
			((_WINE_IS_STAGING)) \
				&& _base_commit="f9e1dbb83d850a2f7cb17079e02de139e2f8b920" \
				|| _base_commit="f8e0bd1b0d189d5950dc39082f439cd1fc9569d5"

			_sieved_esync_patchset_commits=( "${_esync_patchset_commits[@]}" )
			wine_sieve_arrays_by_git_commit "${S}" "_sieved_esync_patchset_commits"
			for _i_array in "${!_esync_patchset_commits[@]}"; do
				# shellcheck disable=SC2068
				has "${_esync_patchset_commits[_i_array]}" ${_sieved_esync_patchset_commits[@]} && break

				_esync_rebased_patchset="${_esync_patchset_commits[_i_array]}"
			done
			if [[ -z "${_esync_rebased_patchset}" ]]; then
				ewarn "The esync patchset is only supported for Wine Git commit (+child commits): '${_base_commit}'"
				ewarn "The esync patchset cannot be applied on Wine Git commit: '${WINE_GIT_COMMIT_HASH}'"
				_esync_error=1
			fi
			;;
		*)
			ewarn "The esync patchset is unsupported for package: =${P}"
			_esync_error=1
			;;
	esac

	if ((_esync_error)); then
		ewarn "USE +esync will be omitted for this build."
		return 1
	fi

	einfo "Using esync rebase revision: '${_esync_rebased_patchset}'"
	_esync_patchset_directory="${_esync_patchsets_base_directory}/${PN}/${_esync_rebased_patchset}"
	ewarn "Applying the wine-esync patchset."
	ewarn "Note: this third-party patchset is not officially supported!"

	eapply "${_esync_patchset_directory}"
}

# @FUNCTION: wine_eapply_pba_patchset()
# @USAGE: <pba_patchset_directory>
# @DESCRIPTION:
# This function supports the packages:
#   app-emulation/wine-staging app-emulation/wine-vanilla
# This function applies the wine-pba patchset to the PWD - typically "${S}".
# <pba_patchset_directory> should be set to the root directory of the unpacked gentoo_wine_pba
# tarball.
# See: https://github.com/acomminos/wine-pba
wine_eapply_pba_patchset() {
	(($# == 1)) || die "${FUNCNAME[0]}(): invalid number of arguments: ${#} (1)"

	local _pba_patchset_directory="${1%/}" _i_array _pba_error=0 _pba_patchset _max_pba_patchset
	if [[ ! -d "${_pba_patchset_directory}" ]]; then
		die "${FUNCNAME[0]}(): argument (1): path '${_pba_patchset_directory}' is not a valid directory"
	fi
	declare -a pba_patchset_commits sieved_pba_patchset_commits

	((_WINE_IS_STAGING)) && case "${WINE_PV}" in
		3.[34])
			_pba_patchset="9ae8b8c00f2cca205fdf4ce76e221778b7dfbea7"
			;;
		3.[5-9]|3.1[0-3])
			_pba_patchset="be002fd92b9d72163bf130ab8ade8aa4d9cdbad0"
			;;
		3.1[4-6])
			_pba_patchset="c698682b3286d72cc7c4c4624b4d14b03dbe6908"
			;;
		3.1[78])
			_pba_patchset="f11563c65fa50e2f8b7e39cade34bb7a998b26f7"
			;;
		9999)
			_max_pba_patchset="6"
			pba_patchset_commits=(
				"9ae8b8c00f2cca205fdf4ce76e221778b7dfbea7" "afef57f872433bcd3032c2ccbc0453bef5b62178"
				"5946973021285dd6ecb8df224956fea4817f8fed" "be002fd92b9d72163bf130ab8ade8aa4d9cdbad0"
				"c698682b3286d72cc7c4c4624b4d14b03dbe6908" "f11563c65fa50e2f8b7e39cade34bb7a998b26f7"
				"82dbf75dc064bb03b5dfc5d8a82b9782a7272ce2" "d279bc24934fd1b68324017ae1b9e70975640a0a"
				"853351698842c92db62bddedd2f531b7c5e745d1" "3d5a2567977455d04e4896368a71db74e7b9074b"
			)
			;;
		*)
			_pba_error=1
			;;
	esac

	((_WINE_IS_STAGING)) || case "${WINE_PV}" in
		3.0.[1-4]|3.0.[1-4]-rc[1-9]|3.[01]|3.0-rc[1-6])
			_pba_patchset="429e0c913087bdc2c183f74f346a9438278ec960"
			;;
		3.2)
			_pba_patchset="f08342f5737c2bb3f965059f930e5d9a25ff6268"
			;;
		3.[34])
			_pba_patchset="6eb562210cb154749b1da5c399a69320d87365e6"
			;;
		3.[56])
			_pba_patchset="1251fe692165077f9ee38992ac33a999bf26b69d"
			;;
		3.[7-9]|3.1[0-3])
			_pba_patchset="ea7186348f48a749ab28ecc405fb56601c56e4f8"
			;;
		3.1[4-6])
			_pba_patchset="cf9536b6bfbefbf5003c7633446a91f6e399c4de"
			;;
		3.1[78])
			_pba_patchset="580ea44bc65472c0304d74b7e873acfb7f680b85"
			;;
		9999)
			_max_pba_patchset="9"
			pba_patchset_commits=(
				"429e0c913087bdc2c183f74f346a9438278ec960" "7772c4fdbf33507b2262da375b465d4c2cbc316d"
				"f08342f5737c2bb3f965059f930e5d9a25ff6268" "6eb562210cb154749b1da5c399a69320d87365e6"
				"1251fe692165077f9ee38992ac33a999bf26b69d" "0e9f94ec1c201c56442124eb8754be1e30840299"
				"ea7186348f48a749ab28ecc405fb56601c56e4f8" "cf9536b6bfbefbf5003c7633446a91f6e399c4de"
				"580ea44bc65472c0304d74b7e873acfb7f680b85" "944e92ba06ecadeb933d95e30035323483dfe7c7"
				"12b5c9148588464d621131e80a2b751e7dbce55b" "b579afd30ae48fef03c9333e31c1349d54ed681a"
				"22b3a4f044036e62104a6994828d18d3536b3d78" "45bf95278d669779e6ca3cde9215556a043a8cf8"
			)
			;;
		*)
			_pba_error=1
			;;
	esac

	if [[ "${WINE_PV}" == "9999" ]]; then
		sieved_pba_patchset_commits=( "${pba_patchset_commits[@]}" )
		wine_sieve_arrays_by_git_commit "${S}" "sieved_pba_patchset_commits"
		for _i_array in "${!pba_patchset_commits[@]}"; do
			# shellcheck disable=SC2068
			has "${pba_patchset_commits[_i_array]}" ${sieved_pba_patchset_commits[@]} && break

			_pba_patchset="${_pba_patchset_directory}/${pba_patchset_commits[_i_array]}"
		done
		# shellcheck disable=SC2068
		if [[ -z "${_pba_patchset}" ]] || ! has "${pba_patchset_commits[_max_pba_patchset]}" ${sieved_pba_patchset_commits[@]}; then
			ewarn "The PBA patchset is only supported for Wine Git commit range: ['${pba_patchset_commits[0]}'-'${pba_patchset_commits[_max_pba_patchset]}')"
			ewarn "The PBA patchset cannot be applied on Wine Git commit: '${WINE_GIT_COMMIT_HASH}'"
			_pba_error=1
		fi
	fi

	unset -v pba_patchset_commits sieved_pba_patchset_commits

	if ((_pba_error)); then
		[[ "${WINE_PV}" != "9999" ]] && ewarn "The PBA patchset is unsupported for package: =${P}"
		ewarn "USE +pba will be omitted for this build."
		return 1
	fi

	ewarn "Applying the wine-pba patchset."
	ewarn "Note: this third-party patchset is not officially supported!"

	eapply "${_pba_patchset_directory}/${_pba_patchset}"
}

# @FUNCTION: wine_add_stock_gentoo_patches
# @DESCRIPTION:
# This function adds all required Gentoo stock patches to the ebuild PATCHES array
# variable and to the (Wine package specific) PATCHES_BIN array variable.
wine_add_stock_gentoo_patches() {
	(($# == 0)) || die "${FUNCNAME[0]}(): invalid number of arguments: ${#} (0)"

	local _patch_directory="${WORKDIR}/${WINE_EBUILD_COMMON_P%/}/patches"

	PATCHES+=(
		"${_patch_directory}/wine-1.8_winecfg_detailed_version.patch"
		"${_patch_directory}/wine-1.8-multislot-apploader.patch" #310611
		"${_patch_directory}/wine-1.5.26-winegcc.patch" #260726
		"${_patch_directory}/wine-1.6-memset-O3.patch" #480508
	)

	case "${WINE_PV}" in
		1.8|1.8.[12]|1.9.[0-8]|9999)
			PATCHES+=( "${_patch_directory}/wine-1.9.9-sysmacros.patch" );; #580046
		*)
			;;
	esac

	case "${WINE_PV}" in
		1.8|1.8.[1-3]|1.9.[0-8]|1.9.1[0-2]|9999)
			PATCHES+=( "${_patch_directory}/wine-1.9.13-gnutls-3.5-compat.patch" ) #587028
			;;
		*)
			;;
	esac

	use truetype && case "${WINE_PV}" in
		1.8*|1.9*|2.0.[12]|2.0.[12]-rc[1-9]|2.[0-9]|2.1[1-7]|9999)
			PATCHES+=(
				"${_patch_directory}/wine-2.18-freetype-2.8.1-segfault.patch"    #631676
				"${_patch_directory}/wine-2.18-freetype-2.8.1-drop-glyphs.patch" #631676
			)
			PATCHES_BIN+=( "${_patch_directory}/wine-2.18-freetype-2.8.1-implement_minimum_em_size_required_by_opentype_1.8.2.patch" ) #631376
			;;
		*)
			;;
	esac
	use osmesa && case "${WINE_PV}" in
		1.8*|1.9*|2.0.[1-4]|2.0.[1-4]-rc[1-9]|2.0.5-rc1|2.[0-6]|9999)
			PATCHES+=( "${_patch_directory}/wine-2.7-osmesa-configure_support_recent_versions.patch" ) #429386
			;;
		*)
			;;
	esac

	use cups && case "${WINE_PV}" in
		1.8|1.8.[1-3]|1.9.[0-9]|1.9.1[0-3]|9999)
			# https://bugs.winehq.org/show_bug.cgi?id=40851
			PATCHES+=( "${_patch_directory}/wine-1.9.14-cups-2.2-cupsgetppd-build-fix.patch" )
			;;
		*)
			;;
	esac

	use pcap && case "${WINE_PV}" in
		1.8*|1.9*|2.0.[1-2]|2.0.[1-2]-rc[1-9]|2.[0-9]|2.1[0-2]|9999)
			# https://bugs.winehq.org/show_bug.cgi?id=40851
			PATCHES+=( "${_patch_directory}/wine-2.13-fix_build_with_newer_pcap.patch" )
			;;
		*)
			;;
	esac

	use gstreamer && case "${WINE_PV}" in
		# https://bugs.winehq.org/show_bug.cgi?id=31836
		1.8.[2-7])
			PATCHES+=( "${_patch_directory}/wine-1.8-gstreamer-1.0_"{01,02,03,04,05,06,07,09,10,11}".patch" )
			;;
		1.9.[23])
			PATCHES+=( "${_patch_directory}/wine-1.8-gstreamer-1.0_"{07,08,09,10,11}".patch" )
			;;
		1.9.4)
			PATCHES+=( "${_patch_directory}/wine-1.8-gstreamer-1.0_"{10,11}".patch" )
			;;
		1.8|1.8.1|1.9.[01]|9999)
			PATCHES+=( "${_patch_directory}/wine-1.8-gstreamer-1.0_"{01,02,03,04,05,06,07,08,09,10,11}".patch" )
			;;
		*)
			;;
	esac
}

# @FUNCTION: wine_add_locale_docs
# @USAGE: <locale>
# @DESCRIPTION:
# Adds Wine documentation, for the specified <locale>, to the standard ebuild variable DOCS.
wine_add_locale_docs() {
	(($# == 1)) || die "${FUNCNAME[0]}(): invalid number of arguments: ${#} (1)"

	local _locale_doc="documentation/README.${1}"
	[[ ! -e "S{S}/${_locale_doc}" ]] || DOCS+=( "${_locale_doc}" )
}

# @FUNCTION: wine_fix_gentoo_multilib_support
# @DESCRIPTION:
# This function fixes Gentoo Portage multilib support, applied to all Wine versions.
# See: #395615 - combines both versions of the multilib-portage.patch
wine_fix_gentoo_multilib_support() {
	(($# == 0)) || die "${FUNCNAME[0]}(): invalid number of arguments: ${#} (0)"

	local _arch
	for _arch in "m32" "m64"; do
		# shellcheck disable=SC1004,SC2016
		sed -i '/CXX="\$CXX -'"${_arch}"'"/a \
		CFLAGS="$CFLAGS -'"${_arch}"'"\
		LDFLAGS="$LDFLAGS -'"${_arch}"'"\
		CXXFLAGS="$CXXFLAGS -'"${_arch}"'"' configure.ac || die "sed failed"
	done
}

# @FUNCTION: wine_src_prepare_generate_64bit_manpages
# @DESCRIPTION:
# This functions ensures that 64-bit Wine manpages are generated.
# This functions provides support for a pure 64-bit Wine / Wine Staging build.
wine_src_prepare_generate_64bit_manpages() {
	(($# == 0)) || die "${FUNCNAME[0]}(): invalid number of arguments: ${#} (0)"

	#617864 Generate wine64 man pages for 64-bit bit only installation
	find "${S%/}/loader" -type f -name "wine.*man.in" -exec sh -c 'mv "${1}" "${1/\/wine./\/wine64.}"' sh "{}" \; \
		|| die "find (mv) failed"
	sed -i -e '\|wine\.[^[:blank:]]*man\.in|{s|wine\.|wine64\.|g}' "${S%/}/loader/Makefile.in" \
		|| die "sed failed"
}

# @FUNCTION: wine_src_disable_specfied_tools
# @USAGE: <tool1> ... [toolN]
# @DESCRIPTION:
# This function disables building the specified Wine builtin tool(s),
# e.g. if they are not supported by the current USE flag settings.
	wine_src_disable_specfied_tools() {
	(($# >= 1))  || die "${FUNCNAME[0]}(): invalid number of arguments: ${#} (1-)"

	local _tool
	for _tool; do
		sed -i -e '\|WINE_CONFIG_TOOL(_tools/'"${_tool}"',[^[:blank:]]*)$|d' "${S%/}/configure.ac" \
			|| die "sed failed"
	done
}

# @FUNCTION: wine_src_disable_unused_locale_man_files
# @DESCRIPTION:
# This function disables generating manpages for any unused locales.
wine_src_disable_unused_locale_man_files() {
	(($# == 0))  || die "${FUNCNAME[0]}(): invalid number of arguments: ${#} (0)"

	local _makefile_in
	find "${S}" -type f -name "Makefile.in" -exec egrep -q "^MANPAGES" "{}" \; -printf '%p\0' 2>/dev/null \
	| while IFS= read -r -d '' _makefile_in; do
		l10n_for_each_disabled_locale_do _wine_src_disable_man_file "${_makefile_in}" ""
	done
}

# @FUNCTION: wine_symlink_64bit_manpages
# @DESCRIPTION:
# This functions symbolically links the standard Wine manpage files, to the 64-bit variants.
# This functions provides support for a pure 64-bit Wine / Wine Staging build.
wine_symlink_64bit_manpages() {
	(($# == 0)) || die "${FUNCNAME[0]}(): invalid number of arguments: ${#} (0)"

	# Symlink wine manpage - for all active locales
	local _manpage _manpage_target="wine64.1"
	while IFS= read -r -d '' _manpage; do
		dosym "${_manpage_target}" "${_manpage/%${_manpage_target}/${_manpage_target/64/}}"
	done < <(find "${WINE_MANDIR}" -type f -name "${_manpage_target}" -printf '%p\0' 2>/dev/null)
}

# @FUNCTION: wine_make_variant_wrappers
# @DESCRIPTION:
# This functions creates wrapper files, for the binary files, for the Wine variant being built.
# This wrapper files support linking to the out-of-tree Wine variant executables and wrapper scripts.
wine_make_variant_wrappers() {
	(($# == 0)) || die "${FUNCNAME[0]}(): invalid number of arguments: ${#} (0)"

	local _binary_file _binary_file_base _binary_file_extension
	while IFS= read -r -d '' _binary_file; do
		_binary_file_base="${_binary_file%%.*}"
		_binary_file_extension="${_binary_file#${_binary_file_base}}"
		make_wrapper "${_binary_file_base}-${WINE_VARIANT}${_binary_file_extension}" "${WINE_PREFIX}/bin/${_binary_file}"
	done < <(find "${D%/}/${WINE_PREFIX}/bin" -mindepth 1 -maxdepth 1 \( -type f -o -type l \) -printf '%f\0' 2>/dev/null)
}

# EXPORT_FUNCTIONS function definitions

# @FUNCTION: wine_pkg_pretend
# @DESCRIPTION:
# This ebuild phase function tests oss sound system support.
wine_pkg_pretend() {
	if use oss && ! use kernel_FreeBSD && ! has_version '>=media-sound/oss-4'; then
		eerror "You cannot build ${CATEGORY}/${PN} with USE=+oss without having support from a FreeBSD kernel"
		eerror "or >=media-sound/oss-4 (only available through an Overlay)."
		die "USE=+oss currently unsupported on this system."
	fi
}

# @FUNCTION: wine_pkg_setup
# @DESCRIPTION:
# This ebuild phase function performs various compiler version and env variable checks.
wine_pkg_setup() {
	_wine_env_vcs_variable_prechecks || die "_wine_env_vcs_variable_prechecks() failed"
	_wine_build_environment_prechecks || die "_wine_build_environment_prechecks() failed"
}

# @FUNCTION: wine_src_configure
# @DESCRIPTION:
# This ebuild phase function runs some active compilation tests.
# This function then calls the multilib-minimal_src_configure phase.
wine_src_configure() {
	_wine_gcc_specific_pretests || die "_wine_gcc_specific_pretests() failed"
	_wine_generic_compiler_pretests || die "_wine_generic_compiler_pretests() failed"

	export LDCONFIG="/bin/true"
	use custom-cflags || strip-flags

	multilib-minimal_src_configure
}

# @FUNCTION: wine_multilib_src_test
# @DESCRIPTION:
# This ebuild phase function runs the Wine test suite.
	wine_multilib_src_test() {
	# FIXME: win32-only; wine64 tests fail with "could not find the Wine loader"
	[[ "${ABI}" == "x86" ]] || return 1

	if [[ "$(id -u)" == "0" ]]; then
		ewarn "Skipping tests since they cannot be run under the root user."
		ewarn "To run the test ${WINE_PN} suite, add userpriv to FEATURES in make.conf"
		return 1
	fi

	WINEPREFIX="${T}/.wine-${ABI}" Xemake test
}

# @FUNCTION: wine_pkg_postinst
# @DESCRIPTION:
# This ebuild phase function registers the new Wine variant.
# This function also updates the XDG Mime database.
# This function prints various USE flag and Wine version specific warning messages.
wine_pkg_postinst() {
	_wine_register_new_variant

	xdg_mimeinfo_database_update

	if ! use gecko; then
		ewarn "Without Wine Gecko, Wineprefixes will not have a default"
		ewarn "implementation of iexplore.  Many older windows applications"
		ewarn "rely upon the existence of an iexplore implementation, so"
		ewarn "you will likely need to install an external one, using winetricks."
	fi
	if ! use mono; then
		ewarn "Without Wine Mono, Wineprefixes will not have a default"
		ewarn "implementation of .NET.  Many windows applications rely upon"
		ewarn "the existence of a .NET implementation, so you will likely need"
		ewarn "to install an external one, using winetricks."
	fi

	((_WINE_IS_STAGING)) || return

	use amd64 && case "${WINE_PV}" in
		1.9.[6-9]|1.9.1[0-9]|1.9.2[0-3]|2.*)
			einfo "This version of Wine Staging has a very experimental Vulkan translation layer."
			einfo "This optional runtime support requires package: >=media-libs/vulkan-loader-1.0.30"
			;;
		*)
			;;
	esac
	case "${WINE_PV}" in
		1.9.[6-9])
			ewarn "This version of Wine Staging does not support the CSMT patchset."
			;;
		*)
			;;
	esac
}

# @FUNCTION: wine_pkg_prerm
# @DESCRIPTION:
# This ebuild phase function deregisters the currently Wine variant.
wine_pkg_prerm() {
	_wine_deregister_current_variant
}

# @FUNCTION: wine_pkg_postrm
# @DESCRIPTION:
# This ebuild phase function updates the XDG Mime database.
wine_pkg_postrm() {
	xdg_mimeinfo_database_update
}

fi
