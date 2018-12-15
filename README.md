guile-automatic-build - Mads Elvheim 2016

About guile-automatic-build
-------------------------------------------------------------------------------

guile-automatic-build is a single bash script for cross-compiling GNU/Guile
for Windows. It checks out a commit (referenced by tag or commit hash) from
the git.sv.gnu.org repository and builds it with the MinGW-w64 toolchain.
Currently this script is verified to run on:

* Ubuntu Trusty 14.04
* Debian 8 Jessie
* Debian 9 Stretch

But it should work on all Linux-flavors with a bash-like shell given that all
the library and tool dependencies are met.

License
-------------------------------------------------------------------------------
As this script patches up the GNU Guile code and Guile is under GPL, this
script should be considered to be under the GPL license as well. (same GPL
licence and version as Guile)

Additional Contributors
-------------------------------------------------------------------------------
Kai-Martin Knaak
James Larrowe

How to use
-------------------------------------------------------------------------------

By calling:

    $ ./build-release 2.0.14

You tell the script to build the release "2.0.14".

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

How the build script works
-------------------------------------------------------------------------------

We're going to use the tag "2.0.14" as an example here, and the process
described below is still true for any tag or commit. Just replace any occurance
of "guile-2.0.14" with any other tag or commit hash, and everything
still applies.

When you start the script with

    $ ./build-commit 2.0.14

In this example, when we have the Guile sources under ./builds/guile-2.0.14,
all the host library dependencies are built, in addition to a specific texinfo
version. The order is significant, as some libraries depends on libiconv, and
so on. The library sources are decompressed from
./deps and into ./builds/guile-2.0.14/deps_win. They are all built with
--prefix set to ./binaries/guile-2.0.14, which is the base directory of the
final tar.gz.

After texinfo and all the host library dependencies are finished, we build
Guile for the build system, i.e Linux if your machine runs a Linux distro.
This is because Guile bootstraps itself, and a cross-compiled binary can't
run on the build system. So we need a "build" version of Guile which can
compile the "host" version of Guile.

The build version of Guile is built inside ./builds/guile-2.0.14/build-linux,
and "../configure" is run after ./builds/guile-2.0.14/build-linux is made the
current directory. In other words, an out-of-source build. The finished build
version of guile is found in ./builds/guile-2.0.14/build-linux/meta/guile and
never moved out of there, as we don't call `make install` here.

Now we can build the host version of Guile, and it is built with the same
process as the build version, only the directory is
./builds/guile-2.0.14/build-win. To tell autoconf and automake about our build
version of Guile, we pass the path to the
./builds/guile-2.0.14/build-linux/meta/guile binary via the GUILE_FOR_BUILD
environment variable. The --prefix used here is ./binaries/guile-2.0.14/guile,
which puts the library binaries and other programs one level below guile's
prefix.

After the host version (Windows .exe) of Guile is built, almost everything we
need is found under ./binaries/guile-2.0.14. The additional files for starting
guile on Windows and the test suite are copied over.

The final step is to run `tar` on ./binaries/guile-2.0.14 to create
./binaries/guile-2.0.14/guile-2.0.14.tar.gz

The final layout for ./binaries/guile-2.0.14 looks like this:

    bin <-- binaries from the libraries and shared libraries (.dll) if any
    guile <-- Guile's main directory
    include <-- includes from the libraries
    lib <-- .a, .dll.a and libtool .la libraries for linking
    share <-- misc files installed by the libraries

The ./binaries/guile-2.0.14/guile directory looks like this:

    bin <-- guile.exe run-guile.bat and run-tests.bat lives here
    include <-- headers for guile if you want to embed guile in an application
    lib <-- libguile lives here, as well as all of guile's compiled modules
    share <-- all of guile's .scm sources lives here (not compiled)

