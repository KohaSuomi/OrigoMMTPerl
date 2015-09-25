package MMT::Objects::Item;

use Modern::Perl;

use Encode;

use MMT::Util::Common;
use TranslationTables::material_code_to_itype;
use TranslationTables::branch_translation;
use TranslationTables::location_translation;
use TranslationTables::ykl_translation;

use MMT::Objects::BaseObject;
use base qw(MMT::Objects::BaseObject);

=head1 SYNOPSIS
Container for item fields. Accessors use validators to make sure data is valid.

@PARAM1 ARRAYRef, The .csv-row parsed to columns
=cut
sub constructor {
    my ($class, $controller, $columns) = @_;
    my $s = {};
    bless($s, $class);
    $s->{controller} = $controller; #Create a temporary reference to the controller containing all the repositories
    $s->{c} = $columns;

    eval {
    ##Column mapping rules
    $s->itemnumber(0);         #1 ID
    $s->barcode(1);            #2 Viivakoodi
    $s->biblionumber(2);       #3 TeosID
    $s->homebranch(4);         #5 Kotipiste
    $s->holdingbranch(5);      #6 Piste
    $s->permanent_location(6); #7 Kotiosasto
    $s->itemcallnumber(2,      #3 TeosID
                       6,      #7 Kotiosasto
                       16);    #17 Luokka
    $s->statuses(10,           #11 Tila -> AuktNiteentila.csv
                 17,           #18 Lainauskielto
                 31,           #32 Uusimiskielto
                 32,           #33 Varauskielto
                 39);          #40 Kadonnut
    $s->price(22);             #23 Hankintahinta
    $s->replacementprice(23);  #24 Korvaushinta
    $s->itemnotes(26,          #27 LainausHuomautus
                  27);         #28 PalautusHuomautus
    $s->dateadded(33);         #34 LisaysPvm
    $s->datereceived(33);      #34 LisaysPvm
    $s->datelastseen(35);      #36 HavaintoPvm
    $s->issues(48);            #49 LkmLainaYht
    $s->itype();               #From MarcRepository
    };
    if ($@) {
        if ($@ eq 'BADPARAM') {
            
        }
        else {
            print $@;
        }
    }

    delete $s->{controller}; #remove the excess references.
    delete $s->{c};
    return $s;
}

sub itemnumber {
    my ($s, $c1) = @_;

    unless ($s->{c}->[$c1]) {
        print $s->_error("No mandatory column '1 ID'");
        die "BADPARAM";
    }
    $s->{itemnumber} = $s->{c}->[$c1];
}
sub barcode {
    my ($s, $c1) = @_;

    unless ($s->{c}->[$c1]) {
        print $s->_error("Missing column '2 Viivakoodi'");
    }
    $s->{barcode} = $s->{c}->[$c1];
}
sub biblionumber {
    my ($s, $c1) = @_;

    unless ($s->{c}->[$c1]) {
        print $s->_error("No mandatory column '3 TeosID'");
        die "BADPARAM";
    }
    $s->{biblionumber} = $s->{c}->[$c1];
}
sub homebranch {
    my ($s, $c1) = @_;
    my $homebranchId = $s->{c}->[$c1];

    unless ($homebranchId) {
        print $s->_error("No mandatory column '5 Kotipiste'");
        die "BADPARAM";
    }

    my $homebranch = TranslationTables::branch_translation::translatePiste($homebranchId);

    if (!$homebranch) {
        $s->{homebranch} = 'KONVERSIO';
    }
    else {
        $s->{homebranch} = $homebranch;
    }
}
sub holdingbranch {
    my ($s, $c1) = @_;
    my $holdingbranchId = $s->{c}->[$c1];

    unless ($holdingbranchId) {
        print $s->_errorPk("Missing column '$c1'");
    }

    my $holdingbranch = TranslationTables::branch_translation::translatePiste($holdingbranchId);

    if (!$holdingbranch) {
        $s->{holdingbranch} = 'KONVERSIO';
    }
    else {
        $s->{holdingbranch} = $holdingbranch;
    }
}
sub permanent_location {
    my ($s, $c1) = @_;
    my $homeDepartmentId = $s->{c}->[$c1];

    unless ($homeDepartmentId) {
        print $s->_errorPk("Missing column '7 Kotiosasto'");
    }

    my $permanent_location = TranslationTables::location_translation::location($homeDepartmentId);

    if (!$permanent_location) {
        $s->{permanent_location} = 'KONVERSIO';
    }
    else {
        $s->{permanent_location} = $permanent_location;
    }
}
sub itemcallnumber {
    my ($s, $c1, $c2, $c3) = @_;
    my $biblionumber = $s->{c}->[$c1];
    my $homeDepartmentId = $s->{c}->[$c2];
    my $yklClass = $s->{c}->[$c3];

    unless (defined($homeDepartmentId)) {
        print $s->_errorPk("Missing column '7 Kotiosasto'");
    }
    my $departmentCode = TranslationTables::location_translation::code($homeDepartmentId);
    $departmentCode = 'KONVERSIO' unless $departmentCode;

    unless (defined($yklClass)) {
        print $s->_errorPk("Missing column '17 Luokka'");
        $yklClass = 'KONVERSIO';
    }

    my $marcRepoRow = $s->{controller}->{repositories}->{MarcRepository}->fetch($biblionumber);
    my $signum = $marcRepoRow->[1] if ($marcRepoRow);
    $signum = 'KONVERSIO' unless $signum;

    $s->{itemcallnumber} = "$departmentCode $yklClass $signum";
}
sub statuses {
    my ($s, @c) = @_;
    my $status = $s->{c}->[  $c[0]  ];
    my $circulationBlocked = ($s->{c}->[  $c[1]  ] =~ m/true/i) ? 1 : 0;
    my $renewalBlocked = ($s->{c}->[  $c[2]  ] =~ m/true/i) ? 1 : 0;
    my $reserveBlocked = ($s->{c}->[  $c[3]  ] =~ m/true/i) ? 1 : 0;
    my $lost = ($s->{c}->[  $c[4]  ] =~ m/true/i) ? 1 : 0;


    if ($circulationBlocked || $renewalBlocked || $reserveBlocked) {
        $s->{notforloan} = 1;
    }
    if ($status == 1 || $lost) { #Kad Kadonnut
        $s->{itemlost} = 1;
    }
    if ($status == 2) { #Kor Korjattavana
        $s->{damaged} = 3
    }
    elsif ($status == 3) { #Poi Poistoesitys
        $s->{itemnotes} .= " : Poistoesitys";
    }
    elsif ($status == 4) { #Näy	Näyttelyssä
        $s->{itemnotes} .= Encode::decode('utf8', " : Origossa - Näyttelyssä");
    }
    elsif ($status == 5) { #Vai Vaihdossa
        $s->{itemnotes} .= Encode::decode('utf8', " : Origossa - Vaihdossa");
    }
    elsif ($status == 6) { #Väl	Välivarastossa
        $s->{itemnotes} .= Encode::decode('utf8', " : Origossa - Välivarastossa");
        $s->{permanent_location} = 'VVA';
    }
    elsif ($status == 8) { #Sel Selvitettävät
        $s->{itemnotes} .= Encode::decode('utf8', " : Origossa - Selvitettävät");
    }
    elsif ($status == 9) { #Tak Takahuone
        $s->{itemnotes} .= Encode::decode('utf8', " : Origossa - Takahuone");
    }
    elsif ($status == 11) { #Kie Pois kierrosta
        $s->{withdrawn} = 1;
    }
}
sub price {
    my ($s, $c1) = @_;

    unless (defined($s->{c}->[$c1])) {
        print $s->_error("Missing column '$c1'");
    }
    $s->{price} = $s->{c}->[$c1];
}
sub replacementprice {
    my ($s, $c1) = @_;

    unless (defined($s->{c}->[$c1])) {
        print $s->_error("Missing column '$c1'");
    }
    $s->{replacementprice} = $s->{c}->[$c1];
}
sub itemnotes {
    my ($s, $c1, $c2) = @_;
    my $checkoutNote = $s->{c}->[$c1];
    my $checkinNote = $s->{c}->[$c2];

    $checkinNote = '' unless $checkinNote;
    $checkoutNote = '' unless $checkoutNote;

    $s->_addNote($checkinNote) if ($checkinNote);
    $s->_addNote($checkoutNote) if ($checkoutNote);
}
sub dateadded {
    my ($s, $c1) = @_;

    unless (defined($s->{c}->[$c1])) {
        print $s->_error("Missing column '$c1'");
    }
    $s->{dateaccessioned} = $s->{c}->[$c1];
}
sub datereceived {
    my ($s, $c1) = @_;

    unless (defined($s->{c}->[$c1])) {
        print $s->_error("Missing column '$c1'");
    }
    $s->{datereceived} = $s->{c}->[$c1];
}
sub datelastseen {
    my ($s, $c1) = @_;

    unless (defined($s->{c}->[$c1])) {
        print $s->_error("Missing column '$c1'");
    }
    $s->{datelastseen} = $s->{c}->[$c1];
}
sub issues {
    my ($s, $c1) = @_;

    unless (defined($s->{c}->[$c1])) {
        print $s->_error("Missing column '$c1'");
    }
    $s->{issues} = $s->{c}->[$c1];
}
sub itype {
    my ($s) = @_;
    my $marcRepoRow = $s->{controller}->{repositories}->{MarcRepository}->fetch( $s->{biblionumber} );
    my $itype = $marcRepoRow->[2] if ($marcRepoRow);
    $itype = 'NO_BIBLIO' unless $itype;
    $s->{itype} = $itype;
}

1;
