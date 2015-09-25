package MMT::Biblios::MarcRepair;

use Modern::Perl;

use MMT::MARC::Field;
use MMT::MARC::Subfield;

my $statistics = {};
$statistics->{cleanEmpty520} = 0;
$statistics->{removeTitlelessRecords} = 0;

sub run {
    my ($r) = @_;

    if ($r->isDeleted()) {
        next;
    }

    eval {
    removeTitlelessRecords($r);
    cleanEmpty520($r);
    };
    if ($@) {
        if ($@ =~ /FAIL/) {
            return undef;
        }
        else {
            die $@;
        }
    }
    return 1;
}

sub cleanEmpty520 {
    my ($r) = @_;

    if (my $fia = $r->fields('520')) {
        foreach my $fi (@$fia) {
            if ( (my $sfa = $fi->getAllSubfields()) ) {
                unless (  scalar(@$sfa) > 0 ) {
                    $r->deleteField( $fi );
                    $statistics->{cleanEmpty520}++;
                    next;
                }
            }
        }
    }
}

sub removeTitlelessRecords {
    my $r = shift;

    foreach (210,222,240,242,245,246) {
        if (my $fia = $r->fields($_) ) {
            return 1; #Looking for records with none of these fields, eg titleless records. Happy to have found a title!
        }
    }
    #No title found so DESTROYING this bastard!
    print("Record '".$r->docId()."' has no title, so removing it.\n");

    $statistics->{removeTitlelessRecords}++;
    die 'FAIL';
}

sub printStatistics {
    my $count = 0;
    my $report = "MarcRepair statistics\n";
    for my $action (sort keys %$statistics) {
        $report .= $action.':'.$statistics->{$action}.'   ';
        
        $count += $statistics->{$action};
    }
    print($report . 'TOTAL:' . $count);
}


return 1; #to make compiler happy happy
