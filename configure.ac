#                                               -*- Autoconf -*-
# Run autoreconf -fi to generate a configure script from this file.

AC_PREREQ([2.69])
AC_INIT([i3status], [2.13], [https://github.com/i3/i3status/issues])
# For AX_EXTEND_SRCDIR
AX_ENABLE_BUILDDIR
AM_INIT_AUTOMAKE([foreign subdir-objects -Wall no-dist-gzip dist-bzip2])
# Default to silent rules, use V=1 to get verbose compilation output.
AM_SILENT_RULES([yes])
# Make it possible to disable maintainer mode to disable re-generation of build
# system files.
AM_MAINTAINER_MODE([enable])
AC_CONFIG_SRCDIR([i3status.c])
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_MACRO_DIR([m4])

dnl Verify macros defined in m4/ such as AX_SANITIZERS are not present in the
dnl output, i.e. are replaced as expected. This line results in a better error
dnl message when using aclocal < 1.13 (which does not understand
dnl AC_CONFIG_MACRO_DIR) without passing the -I m4 parameter.
m4_pattern_forbid([AX_SANITIZERS])

# Verify we are using GNU make because we use '%'-style pattern rules in
# Makefile.am, which are a GNU make extension. Pull requests to replace
# '%'-style pattern rules with a more portable alternative are welcome.
AX_CHECK_GNU_MAKE
AS_VAR_IF([_cv_gnu_make_command], [""], [AC_MSG_ERROR([the i3status Makefile.am requires GNU make])])

AX_EXTEND_SRCDIR

AS_IF([test -d ${srcdir}/.git],
      [
        VERSION="$(git -C ${srcdir} describe --tags --abbrev=0)"
        I3STATUS_VERSION="$(git -C ${srcdir} describe --tags --always) ($(git -C ${srcdir} log --pretty=format:%cd --date=short -n1), branch \\\"$(git -C ${srcdir} describe --tags --always --all | sed s:heads/::)\\\")"
        # Mirrors what libi3/is_debug_build.c does:
        is_release=$(test $(echo "${I3STATUS_VERSION}" | cut -d '(' -f 1 | wc -m) -lt 10 && echo yes || echo no)
      ],
      [
        VERSION="$(cut -d '-' -f 1 ${srcdir}/I3STATUS_VERSION | cut -d ' ' -f 1)"
        I3STATUS_VERSION="$(sed -e 's/@<:@\"?\\@:>@/\\&/g' ${srcdir}/I3STATUS_VERSION)"
        is_release="$(grep -q non-git ${srcdir}/I3STATUS_VERSION && echo no || echo yes)"
      ])
AC_SUBST([I3STATUS_VERSION], [$I3STATUS_VERSION])
AC_DEFINE_UNQUOTED([I3STATUS_VERSION], ["${I3STATUS_VERSION}"], [i3status version])

AX_CODE_COVERAGE

dnl is_release must be lowercase because AX_CHECK_ENABLE_DEBUG calls m4_tolower
dnl on its fourth argument.
AX_CHECK_ENABLE_DEBUG([yes], , [UNUSED_NDEBUG], [$is_release])

AC_PROG_CC_C99

# For strnlen() and vasprintf().
AC_USE_SYSTEM_EXTENSIONS

# Checks for typedefs, structures, and compiler characteristics.
AC_CHECK_HEADER_STDBOOL
dnl The error message should include the specific type which could not be
dnl found, but I do not see a way to achieve that.
AC_CHECK_TYPES([mode_t, off_t, pid_t, size_t, ssize_t], , [AC_MSG_FAILURE([cannot find required type])])

# Checks for library functions.
AC_FUNC_FORK
AC_FUNC_LSTAT_FOLLOWS_SLASHED_SYMLINK
AC_FUNC_STRNLEN
AC_CHECK_FUNCS([atexit dup2 ftruncate getcwd gettimeofday localtime_r memchr memset mkdir rmdir setlocale socket strcasecmp strchr strdup strerror strncasecmp strndup strrchr strspn strstr strtol strtoul], , [AC_MSG_FAILURE([cannot find the $ac_func function, which i3status requires])])

# Checks for libraries.

AX_PTHREAD

AC_SEARCH_LIBS([floor], [m], , [AC_MSG_FAILURE([cannot find the required floor() function despite trying to link with -lm])])

AC_SEARCH_LIBS([shm_open], [rt])

AC_CANONICAL_HOST

PKG_CHECK_MODULES([CONFUSE], [libconfuse])
PKG_CHECK_MODULES([YAJL], [yajl])

case $host_os in
	linux*)
	PKG_CHECK_MODULES([NLGENL], [libnl-genl-3.0])
	PKG_CHECK_MODULES([ALSA], [alsa])
	PKG_CHECK_MODULES([PULSE], [libpulse])
	;;
	netbsd*)
	AC_SEARCH_LIBS([prop_string_create], [prop])
	;;
esac

dnl TODO: check for libbsd for GNU/kFreeBSD

# Checks for programs.
AC_PROG_AWK
AC_PROG_CPP
AC_PROG_INSTALL
AC_PROG_MAKE_SET
AC_PROG_RANLIB
AC_PROG_LN_S

AC_PATH_PROG([PATH_ASCIIDOC], [asciidoc], [no])
AS_IF([test x"$PATH_ASCIIDOC" = x"no"],
      [AC_MSG_ERROR([asciidoc is required for generating man pages])])
AC_PATH_PROG([PATH_XMLTO], [xmlto], [no])
AS_IF([test x"$PATH_XMLTO" = x"no"],
      [AC_MSG_ERROR([xmlto is required for generating man pages])])

AM_PROG_AR

AX_FLAGS_WARN_ALL
AX_CHECK_COMPILE_FLAG([-Wunused-value], [AX_APPEND_FLAG([-Wunused-value], [AM_CFLAGS])])
AC_SUBST(AM_CFLAGS)

# Checks for header files.
AC_CHECK_HEADERS([fcntl.h float.h inttypes.h limits.h locale.h netinet/in.h paths.h stddef.h stdint.h stdlib.h string.h sys/param.h sys/socket.h sys/time.h unistd.h], , [AC_MSG_FAILURE([cannot find the $ac_header header, which i3status requires])])

AC_CONFIG_FILES([Makefile man/asciidoc.conf])
AC_CONFIG_FILES([travis/run-tests.pl], [chmod +x travis/run-tests.pl])

# Enable address sanitizer for non-release builds. The performance hit is a
# 50% increase of wallclock time for the testsuite on my machine.
if test x$is_release = xyes; then
	default_sanitizers=
else
	default_sanitizers=address
fi
AX_SANITIZERS(, [$default_sanitizers], [AC_DEFINE([I3STATUS_ASAN_ENABLED], [], [Enable ASAN])])

AC_OUTPUT

in_git_worktree=`git rev-parse --is-inside-work-tree 2>/dev/null`
if [ "$in_git_worktree" = "true" ]; then
	git_dir=`git rev-parse --git-dir 2>/dev/null`
	srcdir=`dirname "$git_dir"`
	exclude_dir=`pwd | sed "s,^$srcdir,,g"`
	if ! grep -q "^$exclude_dir" "$git_dir/info/exclude"; then
		echo "$exclude_dir" >> "$git_dir/info/exclude"
	fi
fi

echo \
"--------------------------------------------------------------------------------
build configured:

AS_HELP_STRING([i3status version:], [`echo ${I3STATUS_VERSION} | sed 's,\\\\,,g'`])
AS_HELP_STRING([is release version:], [${is_release}])

AS_HELP_STRING([enable debug flags:], [${ax_enable_debug}])
AS_HELP_STRING([code coverage:], [${CODE_COVERAGE_ENABLED}])
AS_HELP_STRING([enabled sanitizers:], [${ax_enabled_sanitizers}])

To compile, run:

  cd `pwd` && make -j8
--------------------------------------------------------------------------------"
