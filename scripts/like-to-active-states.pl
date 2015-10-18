#!/usr/bin/perl
# finds the most likely clusters - clusters are numbered from 1

$ACTIVE=$ARGV[0] || 4;


$prev=0;
while (<>) {
    chomp;
    if (/\[/) {
        $utt=$_;
        $utt=~s/\s*\[//;
        if ($prev) { print "\n"; }
        $prev=1;
        print "$utt ";
    } else {
        $nlikes=~s/\]//;
        $nlikes=$_." ";
        $c=0;
        $nlikes=~s/([\-0-9.]+) /$1.",".(++$c)." "/ge;
        @v=sort { $b <=> $a } split(/\s+/,$nlikes);
        #splice @v,0,$ACTIVE;
        # print "DBG: @v\n";
        @v2=splice @v,0,($ACTIVE+1);
        $T=join(" ",@v2);
        $T=~s/[\-0-9\.]+,//g;
        print " [ $T ] ";
    }
    
}
