#!/usr/bin/perl
=pod

usage:

    cat activations | expand <bcnc_map> 

=cut
my $FN_bcnc_map = shift @ARGV;

my %map;

open(IN,$FN_bcnc_map);
while ($line=<IN>) {
    chomp $line;
    @tokens=split(/\s+/,$line);
    shift @tokens;  # ignore first token
    $src=shift @tokens;
    $map{$src} = join(" ",@tokens);
}
close(IN);

sub sort_indices {
    my $line = shift @_;
    $line=~s/^\s+//;
    $line=~s/\s+$//;

    $line=join(" ",sort { $a <=> $b; } split(/\s+/,$line));
    return $line;
}

while (<>) {
    s/ ([0-9]+) /" ".$map{$1}." "/ge;
    s/\[([^\]]+)\]/" [ ".&sort_indices($1)." ] "/ge;
    print $_;
}

