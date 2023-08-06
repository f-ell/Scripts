## Description
Personal collection of (mainly) Perl and Shell scripts.  
All the larger scripts *should* include proper dependency- and error handling, 
as well as built-in documentation on how to use them.

#### Which scripts are worth checking out?
* [`g`](https://gitlab.com/fell_/Scripts/-/blob/master/source/perl/g)
\- Compact syntax for frequently used Git commands (**deprecated**)
  * **NOTE**: this script is deprecated, see [here](https://gitlab.com/fell_/g)
  for a revised version
  * pseudo-wrapper around Git
  * translate short syntax to full Git command
  * includes default actions and convenience features, e.g.:
    * runs `git status -s` without any arguments
    * a URL written as `%user/repo` (note the '%'-prefix) will expand to
    `https://github.com/user/repo`
* [`nff`](https://gitlab.com/fell_/Scripts/-/tree/master/source/shell/nff)
\- (Neo)Vim Fuzzy Finder
  * automatically open one or more files in (Neo)Vim
  * interactive fuzzy-finder-selection for patterns that match more than one
  file
    * supports [fzf](https://github.com/junegunn/fzf), [fzy](https://github.com/jhawthorn/fzy),
    and [zf](https://github.com/natecraddock/zf)
  * uses [fd](https://github.com/sharkdp/fd) for faster searches
* [`pkmnt`](https://gitlab.com/fell_/Scripts/-/blob/master/source/perl/pkmnt)
\- Perl-KeePass-mount
  * select most recently connected filesystem (or command-line argument) and
  mount in userspace
  * automatically determine database location beneath mountpoint
  * open KeePass with database file
  * unmount partition after script exit, if partition was not mounted before
* [`ssm`](https://gitlab.com/fell_/Scripts/-/blob/master/source/shell/system_monitors/ssm)
\- Simple System Monitor
  * sends critical priority dunst notification when battery is low |
  temperatures are high
  * measures any combination of battery percentage, CPU-, GPU temperature
  * configurable percentage and temperatures
* [`sysload`](https://gitlab.com/fell_/Scripts/-/blob/master/source/perl/system_monitors/sysload)
\- Simple script for measuring CPU and memory utilization
