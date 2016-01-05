guile-automatic-build - Mads Elvheim 2016

About guile-automatic-build
-------------------------------------------------------------------------------

guile-automatic-build is a single bash script for cross-compiling GNU/Guile
for Windows. It checks out a commit (referenced by tag or commit hash) from
the git.sv.gnu.org repository and builds it with the MinGW-w64 toolchain.
Currently this script is only tested on Ubuntu 14.04.

License
-------------------------------------------------------------------------------
As this script patches up the GNU Guile code and Guile is under GPL, this
script should be considered to be under the GPL license as well

How to use
-------------------------------------------------------------------------------

By calling:

    $ ./build-commit v2.0.9

You tell the script to build the commit with the tag "v2.0.9".
By calling:

    $ ./build-commit 204336c37754f38a69949cdad50c7c0b904dea93

You tell the script to build the commit with that hash.
In addition, you can call ./list-tags to display the tags in master. It's just
a shorthand for:

    $ git -C guile-git tag -l

Dependencies
-------------------------------------------------------------------------------

The library dependencies for the Windows build is a part of this source,
however you should ensure that you have all the tools required. Below is a list
of packages, with the names from Ubuntu 14.04. The libraries are only required
for the native guile build:

	git
    mingw-w64
    mingw-w64-tools
    build-essential
    binutils-mingw-w64
    make
    automake
    autoconf
    texinfo
    lzip
    flex
    bison
    gettext
    gettext-base
    libtool (and libtool-bin on Debian)
    libgettextpo-dev
    libgmp-dev
    libffi-dev
    libunistring-dev
    libreadline6-dev
    libgc-dev
    gcc
    g++

Note that building older versions of guile (prior 2.0.8) requires
an old version of texinfo due to syntax errors in the guile
documentation files. Texinfo 4.13a should work. Anything after
Texinfo v5 breaks.

Known bugs
-------------------------------------------------------------------------------

Below is a list over bugs in various versions of guile which the script
automatically patches for you:

Guile 2.0.11 ./libguile/stime.c incorrectly thinks that MinGW has support for
clock_getcpuclockid().
Fixed by making the conditional macro HAVE_POSIX_CPUTIME on line 132 to not
trigger on MinGW builds with libwinpthread. This is done with a check
for WIN_PTHREADS_TIME_H.

Guile 2.0.8 ./lib/msvc-inval.c incorrectly used "cdecl"
but where they mean "__cdecl"
Fixed by replacing all instances of "cdecl" with "__cdecl"

Guile 2.0.0 and some other versions have a too old gnulib
which makes ./libs/stdio.h bail on line 477 with "gets: no such function".
Fixed by removing the line provoking macro,

    _GL_WARN_ON_USE (gets, "gets is a security hole - use fgets instead");

Guile 2.0.0 and some other versions have syntax error in the documentation
texi file, which texinfo 5 aborts on.
Some possible fixes:
1.) Use texinfo 4.13a or earlier
2.) Fix the errors manually
3.) Bypass the texi generation by specifying:
    
    --enable-maintainer-mode

to ./configure

Note that the texinfo bug is not automatically patched/fixed by
this script yet.
I might add a manual build of texinfo 4.13a later.

