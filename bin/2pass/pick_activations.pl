#!/usr/bin/perl
#
# converts likelihoods into an activation map
#

$MAX=shift @ARGV || 5;

sub pick_max {
    my $MAX= shift @_;
    my @ll = @_;

    my @ll1;
    for ($c=0;$c<=$#ll;$c++) {
        push @ll1, $ll[$c]."::".$c;
    }

    @best = sort { 
        ($a1,$a2) = split(/::/,$a);
        ($b1,$b2) = split(/::/,$b);
        return $b1 <=> $a1; 
    } @ll1;

    splice @best,$MAX;
    
    # return the indices of the best MAX log likelihoods
    $indices="";
    foreach $entry (@best) {
        ($ll,$index) = split(/::/,$entry);
        $indices= $indices." ".$index." ";
    } 
    $indices= join(" ",sort { $a <=> $b; } split(/\s+/,$indices) );
    return $indices;
}

while (<STDIN>) {
   if (/^([^\s]+)\s*\[/) {
        $utt=$1;
        chomp;
        s/\[//;
        print $utt;
        next;
   }

    $enfr = 0;
    if (/\]/) { $enfr = 1; }
    if ($en_fr) { # activate all on last frame
        $id_list="";
        for ($c=0;$c<=$#loglikelihoods;$c++) { $id_list = $id_list." $c "; }
    } else { # activate only highest $MAX
    
    $ll = $_; 
    chomp $ll;
    $ll =~ s/^\s+//;
    $ll =~ s/\s+$//;
    
        @loglikelihoods = split(/\s+/,$ll);
        $id_list = &pick_max($MAX,@loglikelihoods);
    }
    print " [ $id_list ] ";
    if ($enfr) { print "\n"; }
}

