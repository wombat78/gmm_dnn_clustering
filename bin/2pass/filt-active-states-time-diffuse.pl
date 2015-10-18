#!/usr/bin/perl
=pod
=cut
my $NUMFRAMES=shift @ARGV || 0;

sub cleanup {
    my $list=shift @_;
    @numbers= sort { $a <=> $b } split(/\s+/,$list);
    my %l;
    foreach $number (@numbers) {
        $l{$number} = 1;
    }
    $nlist = join(" ",sort { $a <=> $b;} keys %l);
    return $nlist;
};

sub process {
    my $line= shift @_; 
    chomp $line;
    $line =~ s/^([^\s+]+)//;
    $uttid=$1;
    $line =~ s/^\s*\[//;
    $line =~ s/\]\s*$//;
    @frames=split(/\]\s+\[/,$line);

    @nframes=@frames;
    for ($c=0;$c<=$#frames;$c++) {
        $l=$c-$NUMFRAMES;
        if ($l<0) { $l=0; }
        $r=$c+$NUMFRAMES;
        if ($r>$#frames) { $r=$#frames; }
        for ($i=$l;$i<=$r;$i++) {
            $nframes[$c]=$nframes[$c]." ".$frames[$i];
        }
        $nframes[$c] = &cleanup($nframes[$c]);
    }
    $ret="$uttid ";
    foreach $frame (@nframes) {
        $ret=$ret." [ $frame ] ";
    }
    return $ret;
}


while ($line=<STDIN>) {
    print &process($line)."\n";
}
