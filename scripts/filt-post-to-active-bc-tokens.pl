#!/usr/bin/perl

sub remove_post {
    my $line=shift @_;
    $line=~s/([0-9\.]+) ([e\-0-9\.]+)/$1 /g;
    return $line;
}

while (<>) {
    s/(\[[^\]]+\])/&remove_post($1)/ge;
    print $_;
}

