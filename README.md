## Description
Collection of (mainly) Perl and Shell scripts written by me.  
All the larger scripts *should* include proper dependency- and error handling, 
as well as built-in documentation on how to use them.

#### Noteworthy Scripts
* [`g`](https://gitlab.com/fell_/Scripts/-/blob/master/source/perl/g)
\- Compact syntax for frequently used Git commands
  * pseudo-wrapper around Git
  * translate short syntax to full Git command
  * includes default actions and convenience features, e.g.:
    * run's `git status -s` without any arguments
    * a URL written as `username/repo` will expand to `https://github.com/user/repo`,
    when prefixed with '`%`'
* [`nff`](https://gitlab.com/fell_/Scripts/-/tree/master/source/shell/nff)
\- (Neo)Vim Fuzzy Finder
  * automatically open one or more files in (Neo)Vim
  * interactive selection using fzf or fzy for patterns that match more than one
  file
* [`pkmnt`](https://gitlab.com/fell_/Scripts/-/blob/master/source/perl/pkmnt)
\- Perl-KeePass-mount
  * select most recently connected filesystem (or command-line argument) and
    mount in userspace
  * automatically determine database location beneath mountpoint
  * open KeePass with database file
  * unmount partition after script exit, unless partition was mounted beforehand
* [`ssm`](https://gitlab.com/fell_/Scripts/-/blob/master/source/shell/system_monitors/ssm)
\- Simple System Monitor
  * sends critical priority dunst notification when battery is low |
    temperatures are high
  * measures any combination of battery percentage, CPU-, GPU temperature
  * configurable percentage and temperatures
* [`sysload`](https://gitlab.com/fell_/Scripts/-/blob/master/source/perl/system_monitors/sysload)
\- Simple script for measuring CPU and memory utilization
