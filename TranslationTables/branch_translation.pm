package TranslationTables::branch_translation;

use Modern::Perl;

our $kirkasKunnat = {
    248 => 'KIT_KES', #1 Kesälahden kunnankirjasto
    260 => 'KIT_KIT', #2 Kiteen kaupunginkirjasto
    707 => 'RAA_RAA', #3 Rääkkylän kunnankirjasto
    848 => 'TOH_TOH', #5 Tohmajärven kunnankirjasto
};

our $kirkasPisteet = {
    1 => "KIT_KES", #KE Kesälahden kirjasto
    2 => "KIT_KIT", #KI Kiteen pääkirjasto
    3 => "TOH_KAU", #KA Kiteen kirjastoauto
    4 => "KIT_PUH", #KP Puhoksen kirjasto
    5 => "KONVERSIO", #KT Terveyskeskuksen kirjasto
    6 => "RAA_RAA", #RP Rääkkylän pääkirjasto
    9 => "RAA_RAS", #RR Rasivaaran kirjasto
    10 => "TOH_VAR", #VK Tohmajärven kirjasto /Värtsilä
    11 => "KIT_ARP", #AR Arppen koulu
    12 => "KIT_KIL", #LU Kiteen lukio
    13 => "KIT_KKK", #OP K-K:n kansalaisopisto
    14 => "KONVERSIO", #VA Varasto/siirtolaina
    20 => "TOH_TOH", #PK Tohmajärven pääkirjasto
    23 => "TOH_KAU", #AU Tohmajärven kirjastoauto
    27 => "TOH_KAU", #KA Kirkas-auto
};

sub translatePiste {
    my ($code) = @_;

    my $value = $kirkasPisteet->{$code} if defined($code);
    unless ($value) {
        print "Missing branch translation code '$code'\n";
        return;
    }
    return $value;
}

sub translateKunta {
    my ($code) = @_;

    my $value = $kirkasKunnat->{$code} if defined($code);
    unless ($value) {
        print "Missing municipality translation code '$code'\n";
        return;
    }
    return $value;
}

1;
