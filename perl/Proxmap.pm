package Proxmap;

use warnings;
use strict;

use Exporter qw(import);
our @EXPORT = qw(psort);

use feature    qw(signatures);
use List::Util qw(first);

=item psort $list, $mapKey
Z<>

Returns a reference to a sorted version of C<$list>. C<$mapKey> is used to
compute the bucket each key maps to (locally setting C<$_>).

The the sort is B<not> performed in place.

=cut

our sub psort ( $list, $mapKey ) {
  my @bucket  = (0) x scalar( $list->@* );
  my @proxmap = (0) x scalar( $list->@* );       # also used for hit counting
  my @out     = (undef) x scalar( $list->@* );

  for my $i ( 0 .. $list->$#* ) {
    local $_ = $list->[$i];
    $bucket[$i] = $mapKey->();
    $proxmap[ $bucket[$i] ]++;
  }

  my $sum = 0;
  for ( 0 .. $#proxmap ) {
    if ( $proxmap[$_] == 0 ) {
      $proxmap[$_] = undef;
      next;
    }

    ( $proxmap[$_], $sum ) = ( $sum, $sum + $proxmap[$_] );
  }

  for my $i ( 0 .. $list->$#* ) {
    my $end =
      first( sub { !defined( $out[$_] ) }, $proxmap[ $bucket[$i] ] .. $#out );
    my $j = first( sub { !defined( $out[$_] ) || $out[$_] > $list->[$i] },
      $proxmap[ $bucket[$i] ] .. $end );

    @out[ $j, $j + 1 .. $end ] = ( $list->[$i], @out[ $j .. $end ] );
  }

  return \@out;
}

1;
