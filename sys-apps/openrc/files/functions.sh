# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

#
# If we are running under OpenRC we should use that code.
#
if [ -n "${RC_LIBEXECDIR}" ]; then
	. "${RC_LIBEXECDIR}"/sh/functions.sh
else
RC_GOT_FUNCTIONS="yes"

#
# this function was lifted from openrc. It returns 0 if the argument  or
# the value of the argument is "yes", "true", "on", or "1" or 1
# otherwise.
#
yesno()
{
	[ -z "$1" ] && return 1

	case "$1" in
		[Yy][Ee][Ss]|[Tt][Rr][Uu][Ee]|[Oo][Nn]|1) return 0;;
		[Nn][Oo]|[Ff][Aa][Ll][Ss][Ee]|[Oo][Ff][Ff]|0) return 1;;
	esac

	local value=
	eval value=\$${1}
	case "$value" in
		[Yy][Ee][Ss]|[Tt][Rr][Uu][Ee]|[Oo][Nn]|1) return 0;;
		[Nn][Oo]|[Ff][Aa][Ll][Ss][Ee]|[Oo][Ff][Ff]|0) return 1;;
		*) vewarn "\$$1 is not set properly"; return 1;;
	esac
}

#
#    hard set the indent used for e-commands.
#    num defaults to 0
# This is a private function.
#
_esetdent()
{
	local i="$1"
	(( i < 0 )) && (( i = 0 ))
	RC_INDENTATION=$(printf "%${i}s" '')
}

#
#    increase the indent used for e-commands.
#
eindent()
{
	local i="$1"
	(( i > 0 )) || (( i = RC_DEFAULT_INDENT ))
	_esetdent $(( ${#RC_INDENTATION} + i ))
}

#
#    decrease the indent used for e-commands.
#
eoutdent()
{
	local i="$1"
	(( i > 0 )) || (( i = RC_DEFAULT_INDENT ))
	_esetdent $(( ${#RC_INDENTATION} - i ))
}

#
#    use the system logger to log a message
#
esyslog()
{
	local pri=
	local tag=

	if [[ -x /usr/bin/logger ]] ; then
		pri="$1"
		tag="$2"

		shift 2
		[[ -z "$*" ]] && return 0

		/usr/bin/logger -p "${pri}" -t "${tag}" -- "$*"
	fi

	return 0
}

#
#    show an informative message (without a newline)
#
einfon()
{
	[[ ${RC_QUIET_STDOUT} == "yes" ]] && return 0
	[[ ${RC_ENDCOL} != "yes" && ${LAST_E_CMD} == "ebegin" ]] && echo
	echo -ne " ${GOOD}*${NORMAL} ${RC_INDENTATION}$*"
	LAST_E_CMD="einfon"
	return 0
}

#
#    show an informative message (with a newline)
#
einfo()
{
	einfon "$*\n"
	LAST_E_CMD="einfo"
	return 0
}

#
#    show a warning message (without a newline) and log it
#
ewarnn()
{
	return 0
}

#
#    show a warning message (with a newline) and log it
#
ewarn()
{
	if [[ ${RC_QUIET_STDOUT} == "yes" ]] ; then
		echo " $*"
	else
		[[ ${RC_ENDCOL} != "yes" && ${LAST_E_CMD} == "ebegin" ]] && echo
		echo -e " ${WARN}*${NORMAL} ${RC_INDENTATION}$*"
	fi

	local name="rc-scripts"
	[[ $0 != "/sbin/runscript.sh" ]] && name="${0##*/}"
	# Log warnings to system log
	esyslog "daemon.warning" "${name}" "$*"

	LAST_E_CMD="ewarn"
	return 0
}

#
#    show an error message (without a newline) and log it
#
eerrorn()
{
	return 0
}

#
#    show an error message (with a newline) and log it
#
eerror()
{
	if [[ ${RC_QUIET_STDOUT} == "yes" ]] ; then
		echo " $*" >/dev/stderr
	else
		[[ ${RC_ENDCOL} != "yes" && ${LAST_E_CMD} == "ebegin" ]] && echo
		echo -e " ${BAD}*${NORMAL} ${RC_INDENTATION}$*"
	fi

	local name="rc-scripts"
	[[ $0 != "/sbin/runscript.sh" ]] && name="${0##*/}"
	# Log errors to system log
	esyslog "daemon.err" "rc-scripts" "$*"

	LAST_E_CMD="eerror"
	return 0
}

#
#    show a message indicating the start of a process
#
ebegin()
{
	local msg="$*" dots spaces="${RC_DOT_PATTERN//?/ }"
	[[ ${RC_QUIET_STDOUT} == "yes" ]] && return 0

	if [[ -n ${RC_DOT_PATTERN} ]] ; then
		dots="$(printf "%$((COLS - 3 - ${#RC_INDENTATION} - ${#msg} - 7))s" '')"
		dots="${dots//${spaces}/${RC_DOT_PATTERN}}"
		msg="${msg}${dots}"
	else
		msg="${msg} ..."
	fi
	einfon "${msg}"
	[[ ${RC_ENDCOL} == "yes" ]] && echo

	LAST_E_LEN="$(( 3 + ${#RC_INDENTATION} + ${#msg} ))"
	LAST_E_CMD="ebegin"
	return 0
}

#
#    indicate the completion of process, called from eend/ewend
#    if error, show errstr via efunc
#
#    This function is private to functions.sh.  Do not call it from a
#    script.
#
_eend()
{
	local retval="${1:-0}" efunc="${2:-eerror}" msg
	shift 2

	if [[ ${retval} == "0" ]] ; then
		[[ ${RC_QUIET_STDOUT} == "yes" ]] && return 0
		msg="${BRACKET}[ ${GOOD}ok${BRACKET} ]${NORMAL}"
	else
		if [[ -c /dev/null ]] ; then
			rc_splash "stop" &>/dev/null &
		else
			rc_splash "stop" &
		fi
		if [[ -n $* ]] ; then
			${efunc} "$*"
		fi
		msg="${BRACKET}[ ${BAD}!!${BRACKET} ]${NORMAL}"
	fi

	if [[ ${RC_ENDCOL} == "yes" ]] ; then
		echo -e "${ENDCOL}  ${msg}"
	else
		[[ ${LAST_E_CMD} == ebegin ]] || LAST_E_LEN=0
		printf "%$(( COLS - LAST_E_LEN - 6 ))s%b\n" '' "${msg}"
	fi

	return ${retval}
}

#
#    indicate the completion of process
#    if error, show errstr via eerror
#
eend()
{
	local retval="${1:-0}"
	shift

	_eend "${retval}" eerror "$*"

	LAST_E_CMD="eend"
	return ${retval}
}

#
#    indicate the completion of process
#    if error, show errstr via ewarn
#
ewend()
{
	local retval="${1:-0}"
	shift

	_eend "${retval}" ewarn "$*"

	LAST_E_CMD="ewend"
	return ${retval}
}

# v-e-commands honor RC_VERBOSE which defaults to no.
# The condition is negated so the return value will be zero.
veinfo()
{
	[[ ${RC_VERBOSE} != "yes" ]] || einfo "$@";
}

veinfon()
{
	[[ ${RC_VERBOSE} != "yes" ]] || einfon "$@";
}

vewarn()
{
	[[ ${RC_VERBOSE} != "yes" ]] || ewarn "$@";
}

veerror()
{
	[[ ${RC_VERBOSE} != "yes" ]] || eerror "$@";
}

vebegin()
{
	[[ ${RC_VERBOSE} != "yes" ]] || ebegin "$@";
}

veend()
{
	[[ ${RC_VERBOSE} == "yes" ]] && { eend "$@"; return $?; }
	return ${1:-0}
}

vewend()
{
	[[ ${RC_VERBOSE} == "yes" ]] && { ewend "$@"; return $?; }
	return ${1:-0}
}

veindent()
{
	[[ ${RC_VERBOSE} != "yes" ]] || eindent;
}

veoutdent()
{
	[[ ${RC_VERBOSE} != "yes" ]] || eoutdent;
}

#
#    prints the current libdir {lib,lib32,lib64}
#
get_libdir()
{
	if [[ -n ${CONF_LIBDIR_OVERRIDE} ]] ; then
		CONF_LIBDIR="${CONF_LIBDIR_OVERRIDE}"
	elif [[ -x /usr/bin/portageq ]] ; then
		CONF_LIBDIR="$(/usr/bin/portageq envvar CONF_LIBDIR)"
	fi
	echo "${CONF_LIBDIR:=lib}"
}

#
#   return 0 if gentoo=param was passed to the kernel
#
#   EXAMPLE:  if get_bootparam "nodevfs" ; then ....
#
get_bootparam()
{
	local x copt params retval=1

	[[ ! -r /proc/cmdline ]] && return 1

	for copt in $(< /proc/cmdline) ; do
		if [[ ${copt%=*} == "gentoo" ]] ; then
			params=$(gawk -v PARAMS="${copt##*=}" '
				BEGIN {
					split(PARAMS, nodes, ",")
					for (x in nodes)
						print nodes[x]
				}')

			# Parse gentoo option
			for x in ${params} ; do
				if [[ ${x} == "$1" ]] ; then
#					echo "YES"
					retval=0
				fi
			done
		fi
	done

	return ${retval}
}

#
#   return 0 if any of the files/dirs are newer than
#   the reference file
#
#   EXAMPLE: if is_older_than a.out *.o ; then ...
is_older_than()
{
	local x=
	local ref="$1"
	shift

	for x in "$@" ; do
		[[ ${x} -nt ${ref} ]] && return 0
		[[ -d ${x} ]] && is_older_than "${ref}" "${x}"/* && return 0
	done

	return 1
}

##############################################################################
#                                                                            #
# This should be the last code in here, please add all functions above!!     #
#                                                                            #
# *** START LAST CODE ***                                                    #
#                                                                            #
##############################################################################

#
# Override defaults with user settings ...
[[ -f /etc/conf.d/rc ]] && source /etc/conf.d/rc

# Check /etc/conf.d/rc for a description of these ...
declare -r svclib="/lib/rcscripts"
declare -r svcdir="${svcdir:-/var/lib/init.d}"
svcmount="${svcmount:-no}"
svcfstype="${svcfstype:-tmpfs}"
svcsize="${svcsize:-1024}"

#
# Default values for e-message indentation and dots
#
RC_INDENTATION=''
RC_DEFAULT_INDENT=2
#RC_DOT_PATTERN=' .'
RC_DOT_PATTERN=''

#
# Internal variables
#

# Dont output to stdout?
RC_QUIET_STDOUT="${RC_QUIET_STDOUT:-no}"
RC_VERBOSE="${RC_VERBOSE:-no}"

# Should we use color?
RC_NOCOLOR="${RC_NOCOLOR:-no}"
# Can the terminal handle endcols?
RC_ENDCOL="yes"

#
# Default values for rc system
#
RC_TTY_NUMBER="${RC_TTY_NUMBER:-12}"
RC_PARALLEL_STARTUP="${RC_PARALLEL_STARTUP:-no}"
RC_NET_STRICT_CHECKING="${RC_NET_STRICT_CHECKING:-no}"
RC_USE_FSTAB="${RC_USE_FSTAB:-no}"
RC_USE_CONFIG_PROFILE="${RC_USE_CONFIG_PROFILE:-yes}"
RC_FORCE_AUTO="${RC_FORCE_AUTO:-no}"
RC_DEVICES="${RC_DEVICES:-auto}"
RC_DOWN_INTERFACE="${RC_DOWN_INTERFACE:-yes}"
RC_VOLUME_ORDER="${RC_VOLUME_ORDER:-raid evms lvm dm}"

if [[ -z ${EBUILD} ]] ; then
	# Setup a basic $PATH.  Just add system default to existing.
	# This should solve both /sbin and /usr/sbin not present when
	# doing 'su -c foo', or for something like:  PATH= rcscript start
	PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/sbin:${PATH}"

	# Cache the CONSOLETYPE - this is important as backgrounded shells don't
	# have a TTY. rc unsets it at the end of running so it shouldn't hang
	# around
	if [[ -z ${CONSOLETYPE} ]] ; then
		export CONSOLETYPE="$( /sbin/consoletype 2>/dev/null )"
	fi
	if [[ ${CONSOLETYPE} == "serial" ]] ; then
		RC_NOCOLOR="yes"
		RC_ENDCOL="no"
	fi

	for arg in "$@" ; do
		case "${arg}" in
			# Lastly check if the user disabled it with --nocolor argument
			--nocolor|-nc)
				RC_NOCOLOR="yes"
				;;
		esac
	done

	setup_defaultlevels

	# If we are not /sbin/rc then ensure that we cannot change level variables
	if [[ -n ${BASH_SOURCE} \
		&& ${BASH_SOURCE[${#BASH_SOURCE[@]}-1]} != "/sbin/rc" ]] ; then
		declare -r BOOTLEVEL DEFAULTLEVEL SOFTLEVEL
	fi
else
	# Should we use colors ?
	if [[ $* != *depend* ]] ; then
		# Check user pref in portage
		RC_NOCOLOR="$(portageq envvar NOCOLOR 2>/dev/null)"
		[[ ${RC_NOCOLOR} == "true" ]] && RC_NOCOLOR="yes"
	else
		# We do not want colors during emerge depend
		RC_NOCOLOR="yes"
		# No output is seen during emerge depend, so this is not needed.
		RC_ENDCOL="no"
	fi
fi

if [[ -n ${EBUILD} && $* == *depend* ]] ; then
	# We do not want stty to run during emerge depend
	COLS=80
else
	# Setup COLS and ENDCOL so eend can line up the [ ok ]
	COLS="${COLUMNS:-0}"		# bash's internal COLUMNS variable
	(( COLS == 0 )) && COLS="$(set -- `stty size 2>/dev/null` ; echo "$2")"
	(( COLS > 0 )) || (( COLS = 80 ))	# width of [ ok ] == 7
fi

if [[ ${RC_ENDCOL} == "yes" ]] ; then
	ENDCOL=$'\e[A\e['$(( COLS - 8 ))'C'
else
	ENDCOL=''
fi

# Setup the colors so our messages all look pretty
if [[ ${RC_NOCOLOR} == "yes" ]] ; then
	unset GOOD WARN BAD NORMAL HILITE BRACKET
else
	GOOD=$'\e[32;01m'
	WARN=$'\e[33;01m'
	BAD=$'\e[31;01m'
	HILITE=$'\e[36;01m'
	BRACKET=$'\e[34;01m'
	NORMAL=$'\e[0m'
fi

##############################################################################
#                                                                            #
# *** END LAST CODE ***                                                      #
#                                                                            #
# This should be the last code in here, please add all functions above!!     #
#                                                                            #
##############################################################################

fi

# vim:ts=4
