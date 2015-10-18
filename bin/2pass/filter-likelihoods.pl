#!/usr/bin/perl
=pod
usage: 
  exp_timit_bcnc/bin/filter-likelihoods.pl [options] active-nc-states.txt < loglike.txt

   --save-activations [filename]
=cut

# parse options
use Getopt::Long;
GetOptions(\%opts,
    'save-activations|s=s'
);

$ACTIVATION_COUNTS_FILE="";
if ($opts{'save-activations'}) {
    print STDERR "save to $opts{'save-activations'}\n"    ;
    $ACTIVATION_COUNTS_FILE=$opts{'save-activations'};
}

$nc_tokens=0;
$total_frames=0;
$tot_tokens=0;


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
    $line=~s/\s+$//; 

    my @loglikes = split(/\s+/,$line);

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

    $tot_tokens=$tot_tokens+($#loglikes+1);
    $nc_tokens=$nc_tokens + (1+$#cstatelist);
    ++$total_frames;

    #my $minval=$loglikes[0];
    #for ($c=0;$c<=$#loglikes;$c++) {
    #    if ($loglikes[$c]<$minval) { $minval=$loglikes[$c]; }
    #}
    
#    my $minval=0;
#$    my @tcstatelist=@cstatelist;
#    for ($c=0;$c<=$#loglikes;$c++) {
#        if ($#tcstatelist>=0 && $c == $tcstatelist[0]) {
#            # active, leave this alone
#            shift @tcstatelist;  # skip to next active one
#
#            if ($loglikes[$c]<$minval) { $minval = $loglikes[$c]; }
#        } else {
#            #######$loglikes[$c] = $minval-1;
#        }
#    }

    for ($c=0;$c<=$#loglikes;$c++) {
        if ($#cstatelist>=0 && $c == $cstatelist[0]) {
            # active, leave this alone
            shift @cstatelist;  # skip to next active one
        } else {
            $loglikes[$c] = -9999;
        }
    }  

    $oline=join(" ", @loglikes);
    if ($endfr) { $oline = $oline." ]"; }
    print "  $oline \n";
}

# print out activation info
if ($ACTIVATION_COUNTS_FILE) {
    open(FACT,">$ACTIVATION_COUNTS_FILE");
    $activation_perc = 0;
    if ($tot_tokens>0) {
        $activation_perc = 100.0*$nc_tokens/$tot_tokens;
    }
    print FACT "narrow-cluster activations: $nc_tokens over $total_frames ($activation_perc)\n";
    print FACT "activation percent: $activation_perc\n";
    close(FACT);
}

close(IN);
