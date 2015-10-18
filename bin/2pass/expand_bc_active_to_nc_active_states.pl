#!/usr/bin/perl
=pod

usage:

    expand <bcnc_map> <active_bc_states>

=cut

my $FN_bcnc_map = shift @ARGV;
my $FN_active_states = shift @ARGV || "-";

my %map;

open(IN,$FN_bcnc_map);
while ($line=<IN>) {
    chomp $line;
    @tokens=split(/\s+/,$line);
#     shift @tokens;  # ignore first token - fix for new version
    $src=shift @tokens;
    $map{$src} = " ".join(" ",@tokens);
}
close(IN);

#print keys %map;
#foreach $src (sort { $a <=> $b;} keys %map) {
#    print "$src -> $map{$src}\n";
#}
#exit 0;


sub sort_indices {
    my $line = shift @_;
    $line=~s/^\s+//;
    $line=~s/\s+$//;

    my %bits ;
    my @parts = split(/\s+/,$line);
    foreach $part (@parts) { $bits{$part} = 1;}
        
    $line = join( " " , sort { $a <=> $b; } keys %bits);
    return $line;
}

open(IN,$FN_active_states);
while (<IN>) {
    s/\[/ [ /;
    s/\]/ ] /;
    s/ /  /g;
    s/ ([0-9]+) /" ".$map{$1}." "/ge;
    s/\[([^\]]+)\]/" [ ".&sort_indices($1)." ] "/ge;
    print $_;
}
close(IN);

