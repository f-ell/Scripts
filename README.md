## Description
This is a collection of, mainly, Shell and Perl scripts, some more useful than
others and with some redundancy where I rewrote scripts in a different language.
Most of the scripts were designed with personal use in mind and thus don't
contain extensive documentation or sophisticated dependency- and error-handling.

Noteworthy scripts to take a look at:
* [nff](https://gitlab.com/fell_/Scripts/-/blob/main/source/nff) - (Neo)Vim Fuzzy Finder (run
`nff -h | --help` for further information)

## Notes
The source directory is not properly organized at the moment. The only script
that's not self-contained is `nff`, which 'relies' on `exclude.nff`. All other
scripts can be used without any other file-dependencies.
