#!/usr/bin/perl
use strict;
use warnings;
use Time::Piece;
use Time::Seconds;

if (@ARGV != 1) {
    print "Usage: $0 filename\n";
    exit;
}

my $filename = $ARGV[0];

if (!-e $filename) {
    print "File '$filename' does not exist.\n";
    exit;
}

open my $fh, '<', $filename or die "Could not open '$filename' $!\n";
my @lines = <$fh>;
close $fh;

my ($start, $end);

for my $line (@lines) {
    if ($line =~ /Execution of DCDFTBMD begun \w\w\w (.*)/) {
	$start = Time::Piece->strptime($1, "%b %d %H:%M:%S %Y");
	    #$start = Time::Piece->strptime($1, "%a %b %d %H:%M:%S %Y");
    }
    elsif ($line =~ /Execution of DCDFTBMD terminated normally \w\w\w (.*)/) {
	$end = Time::Piece->strptime($1, "%b %d %H:%M:%S %Y");
	    #$end = Time::Piece->strptime($1, "%a %b %d %H:%M:%S %Y");
    }
}

if (!defined $start || !defined $end) {
    print "Could not find start and/or end time in '$filename'.\n";
    exit;
}

my $diff = $end - $start;
my $days = int($diff->seconds / (24 * 60 * 60));
my $hours = ($diff->hours % 24);
my $minutes = ($diff->minutes % 60);
my $seconds = ($diff->seconds % 60);

printf("Run time (dd:hh:mm:ss): %02d:%02d:%02d:%02d\n", $days, $hours, $minutes, $seconds);
printf("Total in seconds: %d\n", $diff->seconds);
