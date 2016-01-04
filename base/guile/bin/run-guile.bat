@echo off
setlocal enabledelayedexpansion
set GUILE_BASEDIR_RELATIVE=..\..
set GUILE_BASEDIR_ABSOLUTE=

pushd %GUILE_BASEDIR_RELATIVE%
set GUILE_BASEDIR_ABSOLUTE=%CD%
popd

IF NOT DEFINED "%GUILE_LOAD_COMPILED_PATH%" (
echo "Setting up environment.."
set "GUILE_LOAD_COMPILED_PATH=%GUILE_BASEDIR_ABSOLUTE%\guile\lib\guile\2.0\ccache;%GUILE_BASEDIR_ABSOLUTE%\guile\lib\guile\2.0\site-ccache"
set "GUILE_LOAD_PATH=%GUILE_BASEDIR_ABSOLUTE%\guile\bin\test-suite;%GUILE_BASEDIR_ABSOLUTE%\guile\bin\test-suite\tests;%GUILE_BASEDIR_ABSOLUTE%\guile\share\guile\2.0;%GUILE_BASEDIR_ABSOLUTE%\guile\share\guile\site\2.0;%GUILE_BASEDIR_ABSOLUTE%\guile\share\guile\site;%GUILE_BASEDIR_ABSOLUTE%\guile\share\guile"
set "GUILE_SYSTEM_EXTENSIONS_PATH=%GUILE_BASEDIR_ABSOLUTE%\lib;%GUILE_BASEDIR_ABSOLUTE%\guile\lib;%GUILE_BASEDIR_ABSOLUTE%\guile\lib\guile\2.0\extensions"
set "PATH=%PATH%;%GUILE_BASEDIR_ABSOLUTE%\lib;%GUILE_BASEDIR_ABSOLUTE%\bin"
echo "Guile base directory: !GUILE_BASEDIR_ABSOLUTE!"
echo "Guile load path (compiled files): !GUILE_LOAD_COMPILED_PATH!"
echo "Guile load path: !GUILE_LOAD_PATH!"
echo "Guile system extension path: !GUILE_SYSTEM_EXTENSIONS_PATH!"
echo "Path: !PATH!"
) ELSE (
echo "Environment already set up"
)

guile.exe %*