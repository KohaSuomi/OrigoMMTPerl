package MMT::Biblios::MarcRepair;

use Modern::Perl;

use MMT::MARC::Field;
use MMT::MARC::Subfield;

my $statistics = {};
$statistics->{cleanEmptyField} = 0;
$statistics->{convertAanikirjaItemtype} = 0;
$statistics->{removeTitlelessRecords} = 0;

sub run {
    my ($r) = @_;

    if ($r->isDeleted()) {
        next;
    }

    eval {
    removeTitlelessRecords($r);
    cleanEmptyFields($r);
    convertAanikirjaItemtype($r);
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

sub cleanEmptyFields {
    my ($r) = @_;

    if (my $fia = $r->fields()) {
        foreach my $fi (@$fia) {
            if ( (my $sfa = $fi->getAllSubfields()) ) {
                unless (  scalar(@$sfa) > 0 ) {
                    $r->deleteField( $fi );
                    $statistics->{cleanEmptyField}++;
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

sub convertAanikirjaItemtype {
    my ($r, $materialType) = @_;

    if ($materialType eq 'Aanikirja') {
        my $sf007 = $r->getUnrepeatableSubfield('007','a');
        unless ($sf007) {
            print("Record '".$r->docId()."' has no field 007!\n");
            return '';
        }
        $statistics->{convertAanikirjaItemtype}++;

        my $specificMaterialDesignation = substr($sf007->content(),1,1);
        if ($specificMaterialDesignation eq 'u' || $specificMaterialDesignation eq 'd') {
            return 'CD';
        }
        elsif ($specificMaterialDesignation eq 's') {
            return 'KA';
        }
        else {
            print("Record '".$r->docId()."' has unknown field 007/01 specific material designation!\n");
            return "";
        }
    }

    return $materialType;
}

sub printStatistics {
    my $count = 0;
    my $report = "\n\nMarcRepair statistics\n";
    for my $action (sort keys %$statistics) {
        $report .= $action.':'.$statistics->{$action}.'   '."\n";
        
        $count += $statistics->{$action};
    }
    print($report . 'TOTAL:' . $count) . "\n\n";
}


return 1; #to make compiler happy happy
