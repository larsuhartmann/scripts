#!/usr/bin/env perl

# find-undoc-knobs.pl - list knobs that aren't mentioned in the KNOBS file.
#
# ----------------------------------------------------------------------------
# "THE BEER-WARE LICENSE" (Revision 42):
# <lars@chaotika.org> wrote this file. As long as you retain this notice you
# can do whatever you want with this stuff. If we meet some day, and you think
# this stuff is worth it, you can buy me a beer in return Lars Hartmann
# ----------------------------------------------------------------------------
#
use strict;
use warnings;
use File::Find;

my (%mknobs, @uknobs, %fknobs, $fh);
my $knobsfile = "/home/lars/projekte/freebsd-ports/KNOBS";

# read in any knobs used in any Makefile or .mk file. (knobname as
# key, files it appears in as value of as array member.
@ARGV = qw(.) unless @ARGV;
find sub
{
    if ( $_ eq "Makefile" || m/.mk$/ ) {
        my $file = $_;
        open($fh, $file) || die "$_: $!";
            /WITH(?:OUT)?_([A-Z0-9]+)/ && push @{$mknobs{$1}}, $File::Find::name
                for <$fh>;
        close($fh);
    }
}, @ARGV;

# read knobs from file KNOBS into array
open($fh, $knobsfile) || die "$knobsfile: $!";
%fknobs = map{ ($_, "") } map { /^([A-Z0-9]+)/ && $1 } <$fh>;
close($fh);

@uknobs = sort{ @{$mknobs{$b}} <=> @{$mknobs{$a}} }
    grep{! exists $fknobs{$_}} keys %mknobs;

for (@uknobs) {
    printf "$_ (%d)\n", scalar(@{$mknobs{$_}});
    for (@{$mknobs{$_}}) {
        print "\t".$_."\n";
    }
}
