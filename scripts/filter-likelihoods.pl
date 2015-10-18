#!/usr/bin/perl
=pod
usage: 
  exp_timit_bcnc/bin/filter-likelihoods.pl active-nc-states.txt < loglike.txt
=cut

my $ACTIVE_STATES = shift @ARGV || die "specify active nc state list";

my %active_states;
open(IN,$ACTIVE_STATES);
while ($active_state_list=<IN>) {
    @parts = split(/\s+/,$active_state_list);
    $uttid=shift @parts;
    $active_states{$uttid} = $active_state_list;
}
close(IN);

while ($line=<STDIN>) {
    chomp $line;

    if ($line=~/^([^\s]+).*\[/) { # grab a matching log likelihood list 
        $uttid = $1;
        $active_state_list = $active_states{$uttid};
        if ($active_state_list !~ /$uttid/) {
            die "state list is mismatched: '$uttid'\n".  "ASTATELIST: $active_state_list";
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

    if ($active_state_list=~s/(\[[^\]]+\])//) { 
        # get the active state list for this current frame
        $cframe_active_state=$1;
        $cframe_active_state =~ s/\[//;
        $cframe_active_state =~ s/\]//;
        $cframe_active_state =~ s/^\s+//;
        $cframe_active_state =~ s/\s+$//;
    
        @cstatelist=sort { $a <=> $b; } split(/\s+/,$cframe_active_state);
        
    } else {
        die "frame mismatch on $active_state_list";
    }

    #my $minval=$loglikes[0];
    #for ($c=0;$c<=$#loglikes;$c++) {
    #    if ($loglikes[$c]<$minval) { $minval=$loglikes[$c]; }
    #}
    
    my $minval=0;
    my @tcstatelist=@cstatelist;

    # find worst log likelihood among activated states
    while ($#tcstatelist>=0) {
        my $tcstate = shift @tcstatelist;
        if ($loglikes[$tcstate]<$minval) { $minval = $loglikes[$tcstate]; }
    }

    for ($c=0;$c<=$#loglikes;$c++) {
        if ($#cstatelist>=0 && $c == $cstatelist[0]) {
            # active, leave this alone
            shift @cstatelist;  # skip to next active one
        } else {
            $loglikes[$c] = $minval;
        }
    }  

    $oline=join(" ", @loglikes);
    if ($endfr) { $oline = $oline." ]"; }
    print "  $oline \n";
}


close(IN);
