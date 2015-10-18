#!/usr/bin/perl
=pod
usage: 
  exp_timit_bcnc/bin/filter-likelihoods.pl active-nc-states.txt < loglike.txt
=cut

my $ACTIVE_STATES = shift @ARGV || die "specify active nc state list";

my %active_states;
print STDERR "reading from $ACTIVE_STATES\n";
open(IN,$ACTIVE_STATES);
while ($active_state_list=<IN>) {
    @parts = split(/\s+/,$active_state_list);
    $uttid=shift @parts;
    $active_states{$uttid} = $active_state_list;
}
close(IN);

while ($line=<STDIN>) {
    chomp $line;

    if ($line=~/^([^\s]+)\s*\[/) { # grab a matching log likelihood list 
        $uttid = $1;
        $active_state_list = $active_states{$uttid};
        $active_state_list =~ s/^\s*//;
        $active_state_list =~ s/\s*$//;
        @best_state_sequence = split(/\s+/,$active_state_list);
        shift @best_state_sequence; # kill off the uttid
        if ($active_state_list !~ /$uttid/) {
            die "state list is mismatched: $uttid\n".  "ASTATELIST: $active_state_list";
        }
        print "$line\n";
        #print "$active_state_list\n";
        next;
    }
    $line=~s/^\s+//; 
    $line=~s/\s+$//; 


    # check for last frame
    $endfr=0;
    if ($line =~s/\]//) { $endfr =1; }
    @loglikes = split(/\s+/,$line);

    if ($#best_state_sequence>=0) {
        $best_state = shift @best_state_sequence;
    } else {
        die "frame mismatch on $active_state_list";
    }

    $oline="$loglikes[$best_state],$best_state ";
    if ($endfr) { $oline = $oline." ]"; }
    print "  $oline \n";
}


close(IN);
