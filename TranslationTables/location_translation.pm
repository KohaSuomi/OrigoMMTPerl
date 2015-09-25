package TranslationTables::location_translation;

use Modern::Perl;

our $kirkas = {
    1 => ["PKA", "AIK"], #A	Aikuisten osasto
    2 => ["PK K", "REF"], #K	Käsikirjasto
    3 => ["PK KO", "KOT"], #KO	Kotiseutukokoelma
    4 => ["PKL", "LAP"], #L	Lasten osasto
    5 => ["PKN", "NUO"], #N	Nuorten osasto
    6 => ["Nuortenaikuisten osasto", "Nuortenaikuisten"], #osasto	NA	Nuortenaikuisten osasto
    7 => ["Siirtolaina", "Siirtolaina"], #S	Siirtolaina
    8 => ["Varasto", "Varasto"], #VA	Varasto
    9 => ["Lasten varasto", "Lasten"], #varasto	VL	Lasten varasto
    10 => ["PK NV", "NUV"], #VN	Nuorten varasto
    11 => ["Lehtiosasto", "Lehtiosasto"], #LE	Lehtiosasto
    12 => ["Kirjaston henkilökunta", "Kirjaston henkilökunta"], #KH	Kirjaston henkilökunta
    13 => ["Nuorten käsikirjasto", "Nuorten käsikirjasto"], #NK Nuorten käsikirjasto
    14 => ["PK O", "OHE"], #O	Oheislukemisto
    15 => ["Varasto", "Varasto"], #V	Varasto
    16 => ["Käsikirjasto, varasto", "Käsikirjasto, varasto"], #VK	Käsikirjasto, varasto
    17 => ["Varasto, leikekokoelma", "Varasto, leikekokoelma"], #VX	Varasto, leikekokoelma
    18 => ["Kuvakirjaosasto", "Kuvakirjaosasto"], #KU	Kuvakirjaosasto
    19 => ["PK O", "OHE"], #OL	Oheislukemistot
    20 => ["Siirtolaina:aikuiset", "Siirtolaina:aikuiset"], #SA	Siirtolaina:aikuiset
    21 => ["Siirtolaina:lapset", "Siirtolaina:lapset"], #SL	Siirtolaina:lapset
    22 => ["Kirjasto", "Kirjasto"], #K	Kirjasto
    23 => ["Koulukirjasto", "Koulukirjasto"], #N	Koulukirjasto
    24 => ["Varasto/siirtolaina", "Varasto/siirtolaina"], #S	Varasto/siirtolaina
    25 => ["Varasto, lasten ja nuor", "Varasto, lasten ja nuor"], #VL	Varasto, lasten ja nuorten kir
    30 => ["PKM", "MUS"], #M	Musiikkiosasto
    31 => ["PK", "AV"], #VAR	A:V	Aikuiset, varasto
    32 => ["PK LE", "LEH"], #SA	Lehtiosasto, aikakau
    33 => ["Lehtiosasto, sano", "Lehtiosasto, sano"], #SS	Lehtiosasto, sanomal
    34 => ["L", "L"], #L	L
    35 => ["V", "V"], #V	V
    39 => ["Kotipalvelu", "Kotipalvelu"], #KP	Kotipalvelu
};

=head
Get the branch + shelving location identifier PKA, PKL, ...
=cut
sub code {
    my ($code) = @_;
    if (defined($code)) {
        my $a = $kirkas->{$code};

        unless ($a) {
            print "Missing location translation code '$code'\n";
            return;
        }

        return $a->[0] if $a;
    }
}
=head
Get the permanent_location
=cut
sub location {
    my ($code) = @_;
    if (defined($code)) {
        my $a = $kirkas->{$code};

        unless ($a) {
            print "Missing location translation code '$code'\n";
            return;
        }

        return $a->[1] if $a;
    }
}

1;
