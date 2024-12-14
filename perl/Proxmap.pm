package Proxmap;

use Exporter qw(import);
our @EXPORT = qw(sort);

use feature qw(signatures postderef);

# Perform proxmap sort and return a sorted version of $array (not in place).
our sub sort ( $array, $mapKey ) {
  my @mapped = map( { $mapKey->() } $array->@* )
    ;    # compute mapped values aot - mapKey may be expensive

  my @proxMap = (0) x scalar( $array->@* );
  my @sorted  = (-1) x scalar( $array->@* );

  # use proxMap for hit counting to reduce storage requirements
  $proxMap[ $mapped[$_] ]++ foreach 0 .. $array->$#*;
  $proxMap[ $_ - 1 ] = $proxMap[$_] - $proxMap[ $_ - 1 ]
    foreach reverse( 1 .. $#proxMap );

  for my $i ( 0 .. $array->$#* ) {
    my $last  = $proxMap[ $mapped[$i] + 1 ] - 1;
    my $index = (
      grep( { $sorted[$_] == -1 || $sorted[$_] > $array->[$i] }
        $proxMap[ $mapped[$i] ] .. $last ) )[0]
      ;    # doesn't short circuit, but runs in constant time due bucketing

    @sorted[ $index, $index + 1 .. $last ] =
      ( $array->[$i], @sorted[ $index .. $last ] );
  }

  return \@sorted;
}

1;
