#!/usr/bin/perl
#
# converts likelihoods into an activation map
#

# return corresponding ll with best activation

$MAX=shift @ARGV || 5;

sub pick_max {
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
    $best=shift @best;
    $best=~s/::/,/;
    return " $best ";
    #foreach $entry (@best) {
    #    ($ll,$index) = split(/::/,$entry);
    #    $indices= $indices." ".$index." ";
    #} 
#   # $indices= join(" ",sort { $a <=> $b; } split(/\s+/,$indices) );
#   # return $indices;
    #$llindex= join(" ",sort { $a <=> $b; } split(/\s+/,$indices) );
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
    
   $ll = $_; 
   chomp $ll;
   $ll =~ s/^\s+//;
   $ll =~ s/\s+$//;

   @loglikelihoods = split(/\s+/,$ll);
   $max_idx_list = &pick_max(@loglikelihoods);
    print " [ $max_idx_list ] ";
    if ($enfr) { print "\n"; }
}

