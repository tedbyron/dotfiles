#!/usr/bin/env perl

use strict;
use warnings;

my ($dp, $width, $height, $opts, $current, $clock, $sync, $hpart, $vpart, $refresh);
my $preferred = "";
sub flush() {
    print "    Option \"PreferredMode\" \"$preferred\"\n" if ($preferred);
    print "EndSection\n" if ($dp);
    $preferred = "";
    $dp = "";
}

open(my $F, "xrandr --verbose |") or die $!;

while(<$F>) {
    chomp;
    if (/^(\S+) (\S+)/) {
        flush();
        $dp = $2 eq "connected" && $1;
        next unless $dp;
        print "Section \"Monitor\"\n";
        print "    Identifier \"$dp\"\n";
        next;
    }
    next unless $dp;
    if (/^\s+(\d+)x(\d+)\s+\S*\s+(\d+\.?\d*)\S+\s+([-+]HSync\s+[-+]VSync)\s*(.*)/i) {
        $width = $1; $height = $2; $clock = $3; $sync = lc $4; $opts = $5;
        $current = $opts =~ /current/;
        if ($opts !~ /preferred/) {
            flush();
            next;
        }
    }
    if (/^\s+h: width\s+(\d+)\s+start\s+(\d+)\s+end\s+(\d+)\s+total\s+(\d+)/) {
        $hpart = "$1 $2 $3 $4";
    }
    if (/^\s+v: height\s+(\d+)\s+start\s+(\d+)\s+end\s+(\d+)\s+total\s+(\d+).*?\bclock\s+(\d+)/) {
        $vpart = "$1 $2 $3 $4";
        $refresh = $5;
        my $mode = "${width}x${height}_${refresh}";
        print "    Modeline    \"$mode\" $clock $hpart $vpart $sync   ($width x $height @ $refresh)\n";
        if ($current) {
            $preferred = $mode;
        }
    }
}
flush();
close($F);
