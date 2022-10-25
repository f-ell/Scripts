## Description
This is a collection of (mainly) Shell and Perl scripts. Most of the shorter
scripts were designed with personal use in mind and, as such, lack extensive
documentation as well as sophisticated dependency / error handling.  

#### Noteworthy Scripts
* [`g`](https://gitlab.com/fell_/Scripts/-/blob/master/source/perl/g)
\- Compact syntax for frequently used git commands
* [`nff`](https://gitlab.com/fell_/Scripts/-/tree/master/source/shell/nff)
\- (Neo)Vim Fuzzy Finder
  * automatically open one or more files in (Neo)Vim, each file in its own
  buffer
  * interactive selection for patterns that match more than one file
* [`pkmnt`](https://gitlab.com/fell_/Scripts/-/blob/master/source/perl/pkmnt)
\- perl-keepass-mount
  * auto-mount partition and open Keepass database
  * automatic unmounting when script exits
  * uses newest connected filesystem by default
* [`ssm`](https://gitlab.com/fell_/Scripts/-/blob/master/source/shell/system_monitors/ssm)
\- Simple System Monitor
  * sends critical priority dunst notification when battery is low |
    temperatures are high
  * measures any combination of battery percentage, CPU-, GPU temperature
  * configurable percentage and temperatures
* [`sysload`](https://gitlab.com/fell_/Scripts/-/blob/master/source/perl/system_monitors/sysload)
\- Simple script for measuring CPU and memory utilization

