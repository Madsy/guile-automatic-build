guile-automatic-build - Mads Elvheim 2016

About guile-automatic-build
-------------------------------------------------------------------------------

guile-automatic-build is a single bash script for cross-compiling GNU/Guile
for Windows. It checks out a commit (referenced by tag or commit hash) from
the git.sv.gnu.org repository and builds it with the MinGW-w64 toolchain.
Currently this script is only tested on Ubuntu Thrusty 14.04 and Debian 8 Jessie

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

The default host compiler prefix which is passed on as the --host option to
configure is i686-w64-mingw32, which is the prefix for the 32-bit version of
MinGW when using MinGW-w64. If you use a different version of MinGW, you can
override the --build by setting the ${HOST_CC} environment variable.
As a precaution, the first thing the script does is to ensure that all the
host toolchain tools exist. For example, i686-w64-mingw32-gcc,
i686-w64-mingw32-g++, i686-w64-mingw32-cpp, i686-w64-mingw32-as and so on.

Dependencies
-------------------------------------------------------------------------------

The library dependencies for the Windows build is a part of this source,
however you should ensure that you have all the tools required. Below is a list
of packages, with the names from Ubuntu and Debian. The libraries are only required
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
Texinfo v5 breaks. Texinfo 4.13 is now bundled with the build script and used
during the builds, but without being installed system-wide.
All of the libraries required for the host build (Windows build) are built
in isolation for every commit/tag you build. This ensures reproducability.


How the build script works
-------------------------------------------------------------------------------

We're going to use the tag "v2.0.9" as an example here, and the process
described below is still true for any tag or commit. Just replace any occurance
of "guile-v2.0.9" with any other tag or commit hash, and everything
still applies.

When you start the script with

    $ ./build-commit v2.0.9

then git clone is run if the Guile repo does not exist under the ./guile-git
directory. Then we call git archive to get a tar.gz file containing our branch
or tag. This archive is then decompressed in the ./builds directory.

In this example, when we have the Guile sources under ./builds/guile-v2.0.9,
all the host library dependencies are built, in addition to a specific texinfo
version. The order is significant, as some libraries depends on libiconv, and
so on. The library sources are decompressed from
./deps and into ./builds/guile-v2.0.9/deps_win. They are all built with
--prefix set to ./binaries/guile-v2.0.9, which is the base directory of the
final tar.gz.

After texinfo and all the host library dependencies are finished, we build
Guile for the build system, i.e Linux if your machine runs a Linux distro.
This is because Guile bootstraps itself, and a cross-compiled binary can't
run on the build system. So we need a "build" version of Guile which can
compile the "host" version of Guile.

The build version of Guile is built inside ./builds/guile-v2.0.9/build-linux,
and "../configure" is run after ./builds/guile-v2.0.9/build-linux is made the
current directory. In other words, an out-of-source build. The finished build
version of guile is found in ./builds/guile-v2.0.9/build-linux/meta/guile and
never moved out of there, as we don't call `make install` here.

Now we can build the host version of Guile, and it is built with the same
process as the build version, only the directory is
./builds/guile-v2.0.9/build-win. To tell autoconf and automake about our build
version of Guile, we pass the path to the
./builds/guile-v2.0.9/build-linux/meta/guile binary via the GUILE_FOR_BUILD
environment variable. The --prefix used here is ./binaries/guile-v2.0.9/guile,
which puts the library binaries and other programs one level below guile's
prefix.

After the host version (Windows .exe) of Guile is built, almost everything we
need is found under ./binaries/guile-v2.0.9. The additional files for starting
guile on Windows and the test suite are copied over.

The final step is to run `tar` on ./binaries/guile-v2.0.9 to create
./binaries/guile-v2.0.9/guile-v2.0.9.tar.gz

The final layout for ./binaries/guile-v2.0.9 looks like this:

    bin <-- binaries from the libraries and shared libraries (.dll) if any (*)
    guile <-- Guile's main directory
    include <-- includes from the libraries
    lib <-- .a, .dll.a and libtool .la libraries for linking
    share <-- misc files installed by the libraries

The guile directory looks like this:

    bin <-- guile.exe run-guile.bat and run-tests.bat lives here
    include <-- headers for guile if you want to embed guile in an application
    lib <-- libguile lives here, as well as all of guile's compiled modules
    share <-- all of guile's .scm sources lives here (not compiled)

(*) Guile is now built statically and has no external .dll dependencies 

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
Fixed by using texinfo 4.13 during the build. This is taken
care of by the build script itself. As a second solution it is possible
to build Guile with
    
    --enable-maintainer-mode

as an option to ./configure

