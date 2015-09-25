package MMT::Util::Common;

use Modern::Perl;


sub executeShell {
    my ($cmd, $realtimePrinting) = @_;

    open(my $FH, $cmd);
    my @sb;
    while (<$FH>) {
        push @sb, $_."\n";
        print $_ if $realtimePrinting;
    }
    close($FH);
    return \@sb;
}

sub printTime {
    my ($startTime) = @_;
    my $elapsed = time() - $startTime; #All in seconds.

    return sprintf("%02d:%02d:%02d",(gmtime($elapsed))[2,1,0]);
}

1;
